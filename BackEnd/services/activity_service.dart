import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app/models/activity_model.dart';

class ActivityService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addActivity({
    required String uid,
    required ActivityModel activity,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('activities')
        .add(activity.toMap());
  }

  Stream<List<ActivityModel>> getActivities(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}