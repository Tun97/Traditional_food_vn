import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
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
  final _imageUrlsController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _imagePicker = ImagePicker();

  final List<String> _regions = const ['Bắc', 'Trung', 'Nam'];
  final List<_SelectedFoodImage> _selectedImages = [];

  String _selectedRegion = 'Bắc';

  List<String> get _directImageUrls => _parseLines(_imageUrlsController.text);
  List<String> get _ingredientItems => _parseLines(_ingredientsController.text);
  List<String> get _stepItems => _parseLines(_stepsController.text);
  int get _totalImageCount => _directImageUrls.length + _selectedImages.length;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    _imageUrlsController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final foodProvider = context.read<FoodProvider>();
    if (!foodProvider.isExternalUploadConfigured) {
      _showMessage(
        'Chưa cấu hình dịch vụ upload ảnh ngoài. Bạn có thể dán link ảnh trực tiếp.',
      );
      return;
    }

    final files = await _imagePicker.pickMultiImage(
      imageQuality: 88,
      maxWidth: 1600,
    );

    if (!mounted || files.isEmpty) {
      return;
    }

    final nextImages = <_SelectedFoodImage>[];
    for (final file in files) {
      if (kIsWeb) {
        nextImages.add(
          _SelectedFoodImage(
            name: file.name,
            bytes: await file.readAsBytes(),
          ),
        );
      } else {
        nextImages.add(
          _SelectedFoodImage(
            name: file.name,
            file: File(file.path),
          ),
        );
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedImages.addAll(nextImages);
    });
  }

  void _removeImageAt(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  List<String> _parseLines(String text) {
    return text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String? _validateOptionalVideoUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }

    return Validators.validateVideoUrl(text);
  }

  String? _validateOptionalImageUrls(String? value) {
    final urls = _parseLines(value ?? '');
    for (final url in urls) {
      final lower = url.toLowerCase();
      if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
        return 'Mỗi link ảnh phải bắt đầu bằng http:// hoặc https://';
      }
    }

    return null;
  }

  Future<void> _handleSubmit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    if (_selectedImages.isEmpty && _directImageUrls.isEmpty) {
      _showMessage('Hãy thêm ít nhất 1 ảnh bằng link hoặc file.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final foodProvider = context.read<FoodProvider>();

    final success = await foodProvider.addFood(
      name: _nameController.text,
      region: _selectedRegion,
      description: _descriptionController.text,
      ingredients: _ingredientItems,
      steps: _stepItems,
      videoUrl: _videoUrlController.text,
      createdBy: authProvider.currentUser?.uid ?? '',
      imageUrls: _directImageUrls,
      imageFiles: _selectedImages
          .where((item) => item.file != null)
          .map((item) => item.file!)
          .toList(),
      imageBytesList: _selectedImages
          .where((item) => item.bytes != null)
          .map((item) => item.bytes!)
          .toList(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu món ăn thành công')),
      );
      Navigator.pop(context, true);
      return;
    }

    _showMessage(
      foodProvider.submitErrorMessage ?? 'Không thể lưu món ăn.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foodProvider = context.watch<FoodProvider>();

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        colorScheme.primary.withOpacity(0.03),
        colorScheme.surface,
      ),
      appBar: AppBar(
        title: const Text('Thêm món ăn'),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: foodProvider.isSubmitting ? null : _handleSubmit,
          icon: foodProvider.isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(
            foodProvider.isSubmitting ? 'Đang lưu món ăn...' : 'Lưu món ăn',
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroCard(
                title: 'Ảnh món ăn',
                description: foodProvider.isExternalUploadConfigured
                    ? 'Bạn có thể chọn ảnh từ máy để upload lên dịch vụ ảnh ngoài, hoặc dán link ảnh trực tiếp.'
                    : 'App đang ưu tiên lưu link ảnh trực tiếp vào Firestore. Muốn upload file, hãy cấu hình IMAGE_UPLOAD_API_URL.',
                chips: [
                  'Ảnh: $_totalImageCount',
                  'Nguyên liệu: ${_ingredientItems.length}',
                  'Bước nấu: ${_stepItems.length}',
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Nguồn ảnh',
                subtitle:
                    'Bạn có thể trộn cả hai kiểu: link ảnh có sẵn và ảnh tải từ máy.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: foodProvider.isSubmitting
                              ? null
                              : _pickImages,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Chọn ảnh từ máy'),
                        ),
                        if (_selectedImages.isNotEmpty)
                          Chip(
                            avatar: const Icon(
                              Icons.collections_rounded,
                              size: 18,
                            ),
                            label: Text('${_selectedImages.length} ảnh file'),
                          ),
                        if (_directImageUrls.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.link_rounded, size: 18),
                            label: Text('${_directImageUrls.length} link ảnh'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      foodProvider.isExternalUploadConfigured
                          ? 'Ảnh file sẽ được upload lên ${foodProvider.uploadTargetLabel}. Link ảnh sẽ được lưu thẳng vào Firestore.'
                          : 'Hiện tại chưa có dịch vụ upload ảnh ngoài. Bạn vẫn có thể lưu món ngay bằng link ảnh.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return _SelectedImageCard(
                              image: _selectedImages[index],
                              index: index,
                              onRemove: () => _removeImageAt(index),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _imageUrlsController,
                      labelText: 'Link ảnh',
                      hintText:
                          'Mỗi dòng 1 link ảnh\nhttps://example.com/food-1.jpg\nhttps://example.com/food-2.jpg',
                      maxLines: 5,
                      validator: _validateOptionalImageUrls,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Thông tin chính',
                subtitle: 'Tên món, vùng miền và mô tả ngắn cho người dùng.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Tên món ăn',
                      hintText: 'Ví dụ: Bún bò Huế',
                      validator: (value) =>
                          Validators.validateRequired(value, 'tên món ăn'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vùng miền',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _regions
                          .map(
                            (region) => _RegionChip(
                              label: region,
                              selected: _selectedRegion == region,
                              onTap: () {
                                setState(() {
                                  _selectedRegion = region;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      labelText: 'Mô tả ngắn',
                      hintText:
                          'Món ăn nổi bật ở đâu, vị chính là gì, thường dùng vào dịp nào.',
                      maxLines: 4,
                      validator: (value) =>
                          Validators.validateRequired(value, 'mô tả'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Công thức',
                subtitle:
                    'Mỗi dòng là một nguyên liệu hoặc một bước thực hiện.',
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _ingredientsController,
                      labelText: 'Nguyên liệu',
                      hintText:
                          '500g bún\n300g thịt bò\nHành lá\nRau thơm',
                      maxLines: 6,
                      validator: (value) => Validators.validateMultiLineList(
                        value,
                        'nguyên liệu',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _stepsController,
                      labelText: 'Các bước thực hiện',
                      hintText:
                          'Sơ chế nguyên liệu\nNấu nước dùng\nTrình bày và hoàn thiện',
                      maxLines: 7,
                      validator: (value) => Validators.validateMultiLineList(
                        value,
                        'các bước thực hiện',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _videoUrlController,
                      labelText: 'Link video hướng dẫn',
                      hintText: 'https://youtube.com/...',
                      keyboardType: TextInputType.url,
                      validator: _validateOptionalVideoUrl,
                    ),
                  ],
                ),
              ),
              if (foodProvider.submitErrorMessage != null) ...[
                const SizedBox(height: 16),
                _ErrorCard(message: foodProvider.submitErrorMessage!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class _SelectedFoodImage {
  const _SelectedFoodImage({
    required this.name,
    this.file,
    this.bytes,
  });

  final String name;
  final File? file;
  final Uint8List? bytes;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.description,
    required this.chips,
  });

  final String title;
  final String description;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.84),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (item) => Chip(
                    label: Text(item),
                    backgroundColor: colorScheme.surface.withOpacity(0.82),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary
                : colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? colorScheme.onPrimary : colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedImageCard extends StatelessWidget {
  const _SelectedImageCard({
    required this.image,
    required this.index,
    required this.onRemove,
  });

  final _SelectedFoodImage image;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 176,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 128,
            child: image.bytes != null
                ? Image.memory(image.bytes!, fit: BoxFit.cover)
                : image.file != null
                ? Image.file(image.file!, fit: BoxFit.cover)
                : const ColoredBox(color: Colors.black12),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ảnh ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  image.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Bỏ ảnh'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
