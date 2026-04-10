import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _videoUrlController = TextEditingController();

  final List<String> _regions = ['Bắc', 'Trung', 'Nam'];
  String _selectedRegion = 'Bắc';

  File? _selectedImage;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    if (kIsWeb) {
      final bytes = await file.readAsBytes();

      setState(() {
        _imageBytes = bytes;
      });
    } else {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  List<String> _parseLines(String text) {
    return text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final foodProvider = context.read<FoodProvider>();

    final success = await foodProvider.addFood(
      name: _nameController.text,
      region: _selectedRegion,
      description: _descriptionController.text,
      ingredients: _parseLines(_ingredientsController.text),
      steps: _parseLines(_stepsController.text),
      videoUrl: _videoUrlController.text,
      createdBy: authProvider.currentUser?.uid ?? '',
      imageFile: _selectedImage,
      imageBytes: _imageBytes,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thêm món ăn thành công')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            foodProvider.submitErrorMessage ?? 'Không thể thêm món ăn',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.watch<FoodProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm món ăn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined),
                            Text('Chọn ảnh'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                hintText: 'Ví dụ: Phở bò',
                labelText: 'Tên món ăn',
                validator: (value) =>
                    Validators.validateRequired(value, 'tên món ăn'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRegion,
                decoration: const InputDecoration(labelText: 'Miền'),
                items: _regions
                    .map(
                      (region) =>
                          DropdownMenuItem(value: region, child: Text(region)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedRegion = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Mô tả ngắn về món ăn',
                labelText: 'Mô tả',
                validator: (value) =>
                    Validators.validateRequired(value, 'mô tả'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                maxLines: 5,
                validator: (value) =>
                    Validators.validateMultiLineList(value, 'nguyên liệu'),
                decoration: const InputDecoration(
                  labelText: 'Nguyên liệu',
                  hintText: 'Mỗi dòng là 1 nguyên liệu',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                maxLines: 6,
                validator: (value) => Validators.validateMultiLineList(
                  value,
                  'các bước thực hiện',
                ),
                decoration: const InputDecoration(
                  labelText: 'Cách làm',
                  hintText: 'Mỗi dòng là 1 bước thực hiện',
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _videoUrlController,
                hintText: 'https://youtube.com/...',
                labelText: 'Link video hướng dẫn',
                validator: Validators.validateVideoUrl,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Lưu món ăn',
                isLoading: foodProvider.isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
