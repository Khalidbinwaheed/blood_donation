const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret, defineString } = require('firebase-functions/params');
const admin = require('firebase-admin');
const OpenAI = require('openai');

admin.initializeApp();

const githubModelsToken = defineSecret('GITHUB_MODELS_TOKEN');
const openAiApiKey = defineSecret('OPENAI_API_KEY');
const githubModelsModel = defineString('GITHUB_MODELS_MODEL', {
  default: 'openai/gpt-4.1-mini',
});
const githubApiVersion = defineString('GITHUB_API_VERSION', {
  default: '2022-11-28',
});

const SYSTEM_PROMPT = `You are Lifeline Health Helper inside a blood donation and emergency health app.
Give concise, practical guidance about blood donation eligibility, recovery, appointments, and emergencies.
Do not provide medical diagnoses or prescribe medication.
For life-threatening symptoms, tell the user to call local emergency services immediately.
Keep responses under 140 words unless the user asks for detail.`;

const GITHUB_MODELS_URL =
  'https://models.github.ai/inference/chat/completions';

function sanitizeHistory(rawHistory) {
  if (!Array.isArray(rawHistory)) {
    return [];
  }

  return rawHistory
    .slice(-6)
    .filter((item) => item && typeof item === 'object')
    .map((item) => ({
      role: item.role === 'assistant' ? 'assistant' : 'user',
      content: (item.text || item.content || '').toString().slice(0, 1200),
    }))
    .filter((item) => item.content.length > 0);
}

async function chatWithGitHubModels({
  token,
  model,
  apiVersion,
  messages,
}) {
  const response = await fetch(GITHUB_MODELS_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/vnd.github+json',
      'Content-Type': 'application/json',
      'X-GitHub-Api-Version': apiVersion,
      'User-Agent': 'lifeline-blood-donation',
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.4,
      max_tokens: 400,
      stream: false,
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new HttpsError(
      'internal',
      `GitHub Models request failed (${response.status}): ${errorBody.slice(0, 240)}`,
    );
  }

  const payload = await response.json();
  const text = (payload?.choices?.[0]?.message?.content || '').trim();
  if (!text) {
    throw new HttpsError('internal', 'Empty response from GitHub Models.');
  }

  return {
    id: payload.id || `github-${Date.now()}`,
    text,
    model,
    provider: 'github_models',
  };
}

async function chatWithOpenAiFallback({ apiKey, model, messages, userId }) {
  const openai = new OpenAI({ apiKey });
  const completion = await openai.chat.completions.create({
    model,
    temperature: 0.4,
    max_tokens: 400,
    user: userId,
    messages,
  });

  const text = (completion.choices[0]?.message?.content || '').trim();
  if (!text) {
    throw new HttpsError('internal', 'Empty response from OpenAI fallback.');
  }

  return {
    id: completion.id,
    text,
    model,
    provider: 'openai',
  };
}

exports.chatWithOpenAI = onCall(
  {
    secrets: [githubModelsToken, openAiApiKey],
    region: 'us-central1',
    maxInstances: 20,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    const message = (request.data.message || '').toString().trim().slice(0, 1200);
    if (!message) {
      throw new HttpsError('invalid-argument', 'Message is required.');
    }

    const history = sanitizeHistory(request.data.history);
    const requestedModel = (request.data.model || githubModelsModel.value()).toString();
    const messages = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...history,
      { role: 'user', content: message },
    ];

    let result;
    const githubToken = githubModelsToken.value()?.trim();

    if (githubToken) {
      try {
        result = await chatWithGitHubModels({
          token: githubToken,
          model: requestedModel,
          apiVersion: githubApiVersion.value(),
          messages,
        });
      } catch (error) {
        const openAiKey = openAiApiKey.value()?.trim();
        if (!openAiKey) {
          throw error;
        }
        result = await chatWithOpenAiFallback({
          apiKey: openAiKey,
          model: 'gpt-4o-mini',
          messages,
          userId: request.auth.uid,
        });
      }
    } else {
      const openAiKey = openAiApiKey.value()?.trim();
      if (!openAiKey) {
        throw new HttpsError(
          'failed-precondition',
          'No AI provider configured. Set GITHUB_MODELS_TOKEN or OPENAI_API_KEY.',
        );
      }
      result = await chatWithOpenAiFallback({
        apiKey: openAiKey,
        model: requestedModel.includes('/') ? 'gpt-4o-mini' : requestedModel,
        messages,
        userId: request.auth.uid,
      });
    }

    await admin.firestore().collection('users').doc(request.auth.uid).set(
      { lastChatAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true },
    );

    return result;
  },
);
