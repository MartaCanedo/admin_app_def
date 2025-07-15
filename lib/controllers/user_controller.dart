import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }
}
