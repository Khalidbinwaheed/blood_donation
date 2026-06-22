import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class for Auth
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;

  const AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, User? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable override
      user: user ?? this.user,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState());

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Determine user after sign in?
      // actually authStateChanges stream provider should handle user state updates in the app.
      // But we might want to return true/false for UI feedback.
      // The current implementation returns bool.
      await _authRepository.getCurrentUser();
      // Wait a bit to ensure stream updates? Or just trust the repo.

      // We don't necessarily need to update 'user' in state if we rely on the StreamProvider for 'authState' in the UI.
      // But the current AuthState class has a 'user' field.
      // Let's update it to be consistent with previous logic.
      // Note: AuthRepository.getCurrentUser returns AppUser?, but AuthState expects User? (Firebase User).
      // WARN: AuthState definition uses User? from firebase_auth.
      // We should probably update AuthState to use AppUser? or remove it if we use the stream.
      // For now, let's keep the existing UI contract: return true on success.

      // Converting AppUser to Firebase User is n/a.
      // The previous implementation used Firebase User in AuthState.
      // If the UI depends on AuthState.user, we might break it if we don't supply it.
      // EXCEPT: The UI (main.dart) watches `authStateProvider` (stream of AppUser) for routing.
      // The `signIn_screen` checks `ref.read(authViewModelProvider).error`.
      // It seems `AuthState.user` might not be heavily used if `authStateProvider` is used for auth state.
      // Let's check `signIn_screen.dart`: `final authState = ref.watch(authViewModelProvider);`
      // It uses `authState.isLoading`.

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithGoogle();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signInWithBiometrics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _authRepository.authenticateWithBiometrics();
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication was cancelled or unavailable.',
        );
        return false;
      }
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String bloodGroup,
    required String role,
    double? lat,
    double? lng,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        bloodGroup: bloodGroup,
        type: role,
        // Optional fields not in UI
        phoneNumber: '',
        district: '',
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void signOut() async {
    await _authRepository.signOut();
    state = const AuthState();
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});
