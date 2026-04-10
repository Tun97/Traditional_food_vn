import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_model.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _foodRef =>
      _firestore.collection('foods');

  Future<List<FoodModel>> getFoods() async {
    final snapshot = await _foodRef.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      return FoodModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<List<FoodModel>> getFoodsByRegion(String region) async {
    final snapshot = await _foodRef
        .where('region', isEqualTo: region)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return FoodModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<FoodModel?> getFoodById(String id) async {
    final doc = await _foodRef.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return FoodModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> addFood(FoodModel food) async {
    await _foodRef.doc(food.id).set(food.toMap());
  }

  Future<void> updateFood(FoodModel food) async {
    await _foodRef.doc(food.id).update(food.toMap());
  }

  Future<void> deleteFood(String id) async {
    await _foodRef.doc(id).delete();
  }
}