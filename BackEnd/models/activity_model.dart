class ActivityModel {
  final String id;
  final String type;
  final String foodId;
  final String foodName;
  final String action;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.type,
    required this.foodId,
    required this.foodName,
    required this.action,
    required this.createdAt,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      type: map['type'],
      foodId: map['foodId'],
      foodName: map['foodName'],
      action: map['action'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'foodId': foodId,
      'foodName': foodName,
      'action': action,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}