import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import 'video_screen.dart';

class FoodDetailScreen extends StatelessWidget {
  const FoodDetailScreen({super.key, required this.food});

  final FoodModel food;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final accentColor = _regionColor(food.region, colorScheme);

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.03),
        colorScheme.surface,
      ),
      appBar: AppBar(
        title: Text(food.name),
        actions: [
          if (authProvider.isAdmin)
            IconButton(
              tooltip: 'Xóa món ăn',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FoodHeroCard(food: food, accentColor: accentColor),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Tổng quan',
              subtitle: 'Thông tin nhanh về món ăn và tài nguyên đi kèm.',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatTile(
                    icon: _regionIcon(food.region),
                    label: 'Vùng miền',
                    value: food.region,
                    accentColor: accentColor,
                  ),
                  _StatTile(
                    icon: Icons.photo_library_outlined,
                    label: 'Hình ảnh',
                    value: '${food.imageUrls.length}',
                    accentColor: colorScheme.primary,
                  ),
                  _StatTile(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Nguyên liệu',
                    value: '${food.ingredients.length} mục',
                    accentColor: colorScheme.secondary,
                  ),
                  _StatTile(
                    icon: Icons.format_list_numbered_rounded,
                    label: 'Các bước',
                    value: '${food.steps.length} bước',
                    accentColor: colorScheme.tertiary,
                  ),
                  _StatTile(
                    icon: food.videoUrl.trim().isNotEmpty
                        ? Icons.play_circle_fill_rounded
                        : Icons.video_library_outlined,
                    label: 'Video',
                    value: food.videoUrl.trim().isNotEmpty ? 'Sẵn sàng' : 'Chưa có',
                    accentColor: food.videoUrl.trim().isNotEmpty
                        ? const Color(0xFFC62828)
                        : colorScheme.outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Mô tả',
              subtitle: 'Giới thiệu ngắn gọn về món ăn.',
              child: Text(
                food.description.isEmpty
                    ? 'Món ăn này hiện chưa có mô tả chi tiết.'
                    : food.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Nguyên liệu',
              subtitle: 'Danh sách thành phần cần chuẩn bị.',
              child: food.ingredients.isEmpty
                  ? const _EmptySectionState(
                      icon: Icons.kitchen_outlined,
                      message: 'Chưa có dữ liệu nguyên liệu cho món ăn này.',
                    )
                  : Column(
                      children: food.ingredients
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ChecklistRow(
                                icon: Icons.check_circle_rounded,
                                text: item,
                                accentColor: colorScheme.secondary,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Cách làm',
              subtitle: 'Các bước thực hiện theo thứ tự.',
              child: food.steps.isEmpty
                  ? const _EmptySectionState(
                      icon: Icons.list_alt_rounded,
                      message: 'Chưa có hướng dẫn chế biến cho món ăn này.',
                    )
                  : Column(
                      children: food.steps
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _StepRow(
                                index: entry.key + 1,
                                text: entry.value,
                                accentColor: accentColor,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Video hướng dẫn',
              subtitle: 'Phát video trực tiếp trong ứng dụng.',
              child: food.videoUrl.trim().isEmpty
                  ? const _EmptySectionState(
                      icon: Icons.ondemand_video_outlined,
                      message: 'Món ăn này hiện chưa có video hướng dẫn.',
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoScreen(
                                title: food.name,
                                videoUrl: food.videoUrl,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        label: const Text('Xem video hướng dẫn'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa món ăn'),
        content: const Text('Bạn có chắc muốn xóa món này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await context.read<FoodProvider>().deleteFood(
                food.id,
              );

              if (!context.mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa món ăn')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa thất bại')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FoodHeroCard extends StatelessWidget {
  const _FoodHeroCard({required this.food, required this.accentColor});

  final FoodModel food;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
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
          _FoodGallery(food: food, accentColor: accentColor),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroChip(
                      icon: _regionIcon(food.region),
                      label: food.region,
                      backgroundColor: accentColor.withValues(alpha: 0.14),
                      foregroundColor: accentColor,
                    ),
                    _HeroChip(
                      icon: Icons.photo_library_outlined,
                      label: '${food.imageUrls.length} ảnh',
                      backgroundColor: colorScheme.surface.withValues(alpha: 0.74),
                      foregroundColor: colorScheme.onSurface,
                    ),
                    if (food.videoUrl.trim().isNotEmpty)
                      _HeroChip(
                        icon: Icons.play_circle_fill_rounded,
                        label: 'Có video hướng dẫn',
                        backgroundColor: colorScheme.surface.withValues(
                          alpha: 0.74,
                        ),
                        foregroundColor: colorScheme.onSurface,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  food.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  food.description.isEmpty
                      ? 'Khám phá món ăn truyền thống Việt Nam với phần hình ảnh trực quan hơn.'
                      : food.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.82,
                    ),
                    height: 1.45,
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

class _FoodGallery extends StatefulWidget {
  const _FoodGallery({required this.food, required this.accentColor});

  final FoodModel food;
  final Color accentColor;

  @override
  State<_FoodGallery> createState() => _FoodGalleryState();
}

class _FoodGalleryState extends State<_FoodGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.food.imageUrls;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: imageUrls.isEmpty
            ? _HeroImageFallback(
                food: widget.food,
                accentColor: widget.accentColor,
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _HeroImageFallback(
                          food: widget.food,
                          accentColor: widget.accentColor,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (imageUrls.length > 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          imageUrls.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == _currentIndex ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _currentIndex
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _HeroImageFallback extends StatelessWidget {
  const _HeroImageFallback({required this.food, required this.accentColor});

  final FoodModel food;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.92),
            accentColor.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            const Icon(Icons.fastfood_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 14),
            Text(
              food.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Đặc trưng ẩm thực miền ${food.region}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = (MediaQuery.of(context).size.width - 64) / 2;

    return Container(
      width: width < 150 ? double.infinity : width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.icon,
    required this.text,
    required this.accentColor,
  });

  final IconData icon;
  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.text,
    required this.accentColor,
  });

  final int index;
  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$index',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySectionState extends StatelessWidget {
  const _EmptySectionState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _regionIcon(String region) {
  switch (region) {
    case 'Bắc':
      return Icons.landscape_rounded;
    case 'Trung':
      return Icons.terrain_rounded;
    case 'Nam':
      return Icons.water_rounded;
    default:
      return Icons.grid_view_rounded;
  }
}

Color _regionColor(String region, ColorScheme colorScheme) {
  switch (region) {
    case 'Bắc':
      return const Color(0xFF2E7D32);
    case 'Trung':
      return const Color(0xFFEF6C00);
    case 'Nam':
      return const Color(0xFF1565C0);
    default:
      return colorScheme.primary;
  }
}
