import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get firebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? avatarUrl,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Không thể tạo tài khoản');
    }

    await user.updateDisplayName(name.trim());

    final userModel = UserModel(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      role: 'user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      avatarUrl: avatarUrl ?? '',
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

    return userModel;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Đăng nhập thất bại');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data() == null) {
      final fallbackUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? email.trim(),
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        avatarUrl: user.photoURL ?? '',
      );

      await _firestore.collection('users').doc(user.uid).set(
            fallbackUser.toMap(),
            SetOptions(merge: true),
          );

      return fallbackUser;
    }

    return UserModel.fromMap(doc.data()!);
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Sai email hoặc mật khẩu';
      case 'network-request-failed':
        return 'Lỗi mạng, vui lòng thử lại';
      default:
        return e.message ?? 'Đã có lỗi xảy ra';
    }
  }
}