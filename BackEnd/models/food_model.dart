class FoodModel {
  final String id;
  final String name;
  final String region;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final String videoUrl;
  final DateTime? createdAt;
  final String createdBy;

  FoodModel({
    required this.id,
    required this.name,
    required this.region,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.videoUrl,
    this.createdAt,
    required this.createdBy,
  });

  factory FoodModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FoodModel(
      id: documentId,
      name: map['name'] ?? '',
      region: map['region'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'region': region,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}