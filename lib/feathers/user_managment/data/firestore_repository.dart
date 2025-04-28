import 'package:blood_donation/feathers/user_managment/Domain/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  FirestoreRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<List<AppUser>> loadDonors() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'Donor')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => AppUser.fromMap(doc.data()))
            .toList());
  }

    Stream<List<AppUser>> loadSpecificBloodGroupDonors( String bloodGroup) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'Donor')
        .where('bloodGroup', isEqualTo: bloodGroup)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => AppUser.fromMap(doc.data()))
            .toList());
  }

    Stream<List<AppUser>> loadSimilarBloodGroups( String bloodGroup) {
    return FirebaseFirestore.instance
        .collection('emails')
        .where('type', isEqualTo: 'Donor')
        .where('bloodGroup', isEqualTo: bloodGroup)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => AppUser.fromMap(doc.data()))
            .toList());
  }
}
