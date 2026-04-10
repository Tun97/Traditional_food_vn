import 'package:flutter/material.dart';
import 'package:food_app/services/activity_service.dart';
import 'package:food_app/models/activity_model.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService activityService;

  List<ActivityModel> _activities = [];

  List<ActivityModel> get activities => _activities;

  ActivityProvider({required this.activityService});

  void listenActivities(String uid) {
    activityService.getActivities(uid).listen((data) {
      _activities = data;
      notifyListeners();
    });
  }
}
