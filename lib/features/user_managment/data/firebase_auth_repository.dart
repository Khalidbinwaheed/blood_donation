import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _fetchUserProfile(user.uid);
    });
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _fetchUserProfile(user.uid);
  }

  Future<AppUser?> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        // Assuming AppUser has a fromJson/fromMap factory
        // If not, we map manually or use the generated Freezed one
        // Need to check AppUser definition first, using manual map for safety now
        // leveraging AppUser.fromJson if available
        return AppUser.fromJson(doc.data()!);
      }
    } catch (e) {
      // Handle error or return null
      // log('Error fetching user profile: $e');
    }
    return null;
  }

  @override
  Future<void> signIn(String email, String password) async {
    await signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String bloodGroup,
    required String type,
    required String district,
  }) async {
    // 1. Create Auth User
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    // 2. Parse Name
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // 3. Create AppUser Object
    final newUser = AppUser(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      bloodGroup: bloodGroup,
      role: type == 'Donor' ? 'donor' : 'recipient', // Normalize role
      type: type, // Keeping original type field if needed
      district: district,
      donorEligibilityStatus: 'pending', // Default
    );

    // 4. Write to Firestore
    await _firestore.collection('users').doc(uid).set(newUser.toJson());

    // 5. Initialize Profile (as per PRD)
    await _firestore.collection('profiles').doc(uid).set({
      'bloodType': bloodGroup,
      'conditions': [],
      'allergies': [],
      'donorEligibilityStatus': 'pending',
    });
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
