import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/food_model.dart';
import '../services/food_service.dart';
import '../services/storage_service.dart';

class FoodProvider extends ChangeNotifier {
  final FoodService foodService;
  final StorageService storageService;

  FoodProvider({required this.foodService, required this.storageService});

  List<FoodModel> _foods = [];
  List<FoodModel> _filteredFoods = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _submitErrorMessage;
  String _selectedRegion = 'Tất cả';

  List<FoodModel> get foods => _foods;
  List<FoodModel> get filteredFoods => _filteredFoods;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get submitErrorMessage => _submitErrorMessage;
  String get selectedRegion => _selectedRegion;

  Future<void> fetchFoods() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _foods = await foodService.getFoods();
      _applyRegionFilter(_selectedRegion);
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách món ăn';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByRegion(String region) {
    _selectedRegion = region;
    _applyRegionFilter(region);
    notifyListeners();
  }

  void _applyRegionFilter(String region) {
    if (region == 'Tất cả') {
      _filteredFoods = [..._foods];
    } else {
      _filteredFoods = _foods.where((food) => food.region == region).toList();
    }
  }

  Future<bool> addFood({
    required String name,
    required String region,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    required String videoUrl,
    required String createdBy,
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    try {
      _isSubmitting = true;
      _submitErrorMessage = null;
      notifyListeners();

      String imageUrl = '';

      if (imageFile != null || imageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await storageService.uploadFoodImage(
          file: imageFile,
          bytes: imageBytes,
          fileName: fileName,
        );
      }

      if (imageFile != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final safeName = name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .replaceAll(RegExp(r'^-|-$'), '');

        imageUrl = await storageService.uploadFoodImage(
          file: imageFile,
          fileName: '${safeName}_$timestamp.jpg',
        );
      }

      final docId = name
          .toLowerCase()
          .replaceAll(
            RegExp(
              r'[^a-z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]+',
            ),
            '-',
          )
          .replaceAll(RegExp(r'-+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');

      final food = FoodModel(
        id: '${docId}_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        region: region.trim(),
        description: description.trim(),
        ingredients: ingredients,
        steps: steps,
        imageUrl: imageUrl,
        videoUrl: videoUrl.trim(),
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );

      await foodService.addFood(food);
      await fetchFoods();

      return true;
    } catch (e) {
      _submitErrorMessage = 'Không thể thêm món ăn';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFood(String id) async {
    try {
      _isSubmitting = true;
      _submitErrorMessage = null;
      notifyListeners();

      await foodService.deleteFood(id);
      await fetchFoods();
      return true;
    } catch (e) {
      _submitErrorMessage = 'Không thể xóa món ăn';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
