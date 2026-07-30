import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    print("Saving UID: ${user.uid}");

    await _firestore
        .collection("users")
        .doc(user.uid)
        .set(user.toMap());

    print("Saved Successfully");
  }
}