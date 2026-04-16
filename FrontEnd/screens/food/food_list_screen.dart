import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import 'add_food_screen.dart';
import 'food_detail_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  static const List<String> _regions = ['Tất cả', 'Bắc', 'Trung', 'Nam'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _refreshFoods());
  }

  Future<void> _refreshFoods() {
    return context.read<FoodProvider>().fetchFoods();
  }

  Future<void> _openAddFoodScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddFoodScreen()),
    );

    if (result == true && mounted) {
      await _refreshFoods();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foodProvider = context.watch<FoodProvider>();
    final authProvider = context.watch<AuthProvider>();
    final foods = foodProvider.filteredFoods;

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        colorScheme.primary.withOpacity(0.03),
        colorScheme.surface,
      ),
      appBar: AppBar(
        title: const Text('Khám phá món ăn'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _refreshFoods,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: authProvider.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openAddFoodScreen,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm món'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refreshFoods,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  children: [
                    _FoodListHero(
                      totalFoods: foodProvider.foods.length,
                      visibleFoods: foods.length,
                      selectedRegion: foodProvider.selectedRegion,
                      isAdmin: authProvider.isAdmin,
                    ),
                    const SizedBox(height: 16),
                    _RegionFilterCard(
                      regions: _regions,
                      selectedRegion: foodProvider.selectedRegion,
                      visibleFoods: foods.length,
                      onRegionSelected: foodProvider.filterByRegion,
                    ),
                    if (foodProvider.errorMessage != null && foods.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _InlineMessage(
                        icon: Icons.wifi_off_rounded,
                        message: foodProvider.errorMessage!,
                        actionLabel: 'Thử lại',
                        onActionPressed: _refreshFoods,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (foodProvider.isLoading && foodProvider.foods.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, _) => const _FoodCardSkeleton(),
                    childCount: 4,
                  ),
                ),
              )
            else if (foodProvider.errorMessage != null &&
                foodProvider.foods.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: _StateCard(
                    icon: Icons.cloud_off_rounded,
                    title: 'Không thể tải danh sách món ăn',
                    description: foodProvider.errorMessage!,
                    actionLabel: 'Tải lại',
                    onActionPressed: _refreshFoods,
                  ),
                ),
              )
            else if (foods.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: _StateCard(
                    icon: Icons.search_off_rounded,
                    title: 'Không có món ăn phù hợp',
                    description: foodProvider.selectedRegion == 'Tất cả'
                        ? 'Danh sách hiện chưa có dữ liệu. Hãy thử tải lại sau.'
                        : 'Không tìm thấy món ăn thuộc khu vực ${foodProvider.selectedRegion}.',
                    actionLabel: foodProvider.selectedRegion == 'Tất cả'
                        ? 'Tải lại'
                        : 'Xem tất cả',
                    onActionPressed: foodProvider.selectedRegion == 'Tất cả'
                        ? _refreshFoods
                        : () => foodProvider.filterByRegion('Tất cả'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final food = foods[index];
                      return _FoodCard(
                        food: food,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodDetailScreen(food: food),
                            ),
                          );
                        },
                      );
                    },
                    childCount: foods.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FoodListHero extends StatelessWidget {
  const _FoodListHero({
    required this.totalFoods,
    required this.visibleFoods,
    required this.selectedRegion,
    required this.isAdmin,
  });

  final int totalFoods;
  final int visibleFoods;
  final String selectedRegion;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.72),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedRegion == 'Tất cả'
                      ? 'Tinh hoa ẩm thực Việt'
                      : 'Hương vị miền $selectedRegion',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Danh sách món ăn được sắp xếp trực quan hơn, dễ duyệt hơn.',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            selectedRegion == 'Tất cả'
                ? 'Hiện có $totalFoods món ăn trong bộ sưu tập. Kéo xuống để làm mới dữ liệu.'
                : 'Đang hiển thị $visibleFoods món ăn thuộc khu vực $selectedRegion.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: colorScheme.onPrimaryContainer.withOpacity(0.78),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatChip(
                icon: Icons.restaurant_menu_rounded,
                label: 'Tổng món',
                value: '$totalFoods',
              ),
              _HeroStatChip(
                icon: Icons.filter_alt_rounded,
                label: 'Đang xem',
                value: '$visibleFoods',
              ),
              _HeroStatChip(
                icon: isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : Icons.explore_rounded,
                label: isAdmin ? 'Vai trò' : 'Chế độ',
                value: isAdmin ? 'Admin' : 'Người dùng',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.68),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegionFilterCard extends StatelessWidget {
  const _RegionFilterCard({
    required this.regions,
    required this.selectedRegion,
    required this.visibleFoods,
    required this.onRegionSelected,
  });

  final List<String> regions;
  final String selectedRegion;
  final int visibleFoods;
  final ValueChanged<String> onRegionSelected;

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
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lọc theo vùng miền',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đang hiển thị $visibleFoods món ăn',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: regions
                .map(
                  (region) => _RegionChip(
                    label: region,
                    icon: _regionIcon(region),
                    selected: selectedRegion == region,
                    onTap: () => onRegionSelected(region),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary
            : colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onActionPressed,
            child: Text(
              actionLabel,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.food,
    required this.onTap,
  });

  final FoodModel food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _regionColor(food.region, colorScheme);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FoodThumbnail(
                  imageUrl: food.imageUrl,
                  name: food.name,
                  accentColor: accentColor,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(
                            icon: _regionIcon(food.region),
                            label: food.region,
                            backgroundColor: accentColor.withOpacity(0.12),
                            foregroundColor: accentColor,
                          ),
                          if (food.videoUrl.trim().isNotEmpty)
                            _Pill(
                              icon: Icons.play_circle_outline_rounded,
                              label: 'Có video',
                              backgroundColor:
                                  colorScheme.primary.withOpacity(0.08),
                              foregroundColor: colorScheme.primary,
                            ),
                          if (food.imageUrls.length > 1)
                            _Pill(
                              icon: Icons.photo_library_outlined,
                              label: '${food.imageUrls.length} ảnh',
                              backgroundColor:
                                  colorScheme.tertiary.withOpacity(0.10),
                              foregroundColor: colorScheme.tertiary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        food.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        food.description.isEmpty
                            ? 'Chưa có mô tả cho món ăn này.'
                            : food.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(
                            icon: Icons.restaurant_menu_rounded,
                            label: '${food.ingredients.length} nguyên liệu',
                            backgroundColor:
                                colorScheme.secondary.withOpacity(0.10),
                            foregroundColor: colorScheme.secondary,
                          ),
                          _Pill(
                            icon: Icons.format_list_numbered_rounded,
                            label: '${food.steps.length} bước',
                            backgroundColor:
                                colorScheme.tertiary.withOpacity(0.12),
                            foregroundColor: colorScheme.tertiary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodThumbnail extends StatelessWidget {
  const _FoodThumbnail({
    required this.imageUrl,
    required this.name,
    required this.accentColor,
  });

  final String imageUrl;
  final String name;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 96,
        height: 112,
        child: imageUrl.trim().isEmpty
            ? _FoodThumbnailFallback(name: name, accentColor: accentColor)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _FoodThumbnailFallback(
                  name: name,
                  accentColor: accentColor,
                ),
              ),
      ),
    );
  }
}

class _FoodThumbnailFallback extends StatelessWidget {
  const _FoodThumbnailFallback({
    required this.name,
    required this.accentColor,
  });

  final String name;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.90),
            accentColor.withOpacity(0.52),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            const Icon(Icons.fastfood_rounded, color: Colors.white, size: 26),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCardSkeleton extends StatelessWidget {
  const _FoodCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest.withOpacity(0.55);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 112,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBar(width: 96, color: baseColor),
                const SizedBox(height: 12),
                _SkeletonBar(
                  width: double.infinity,
                  height: 18,
                  color: baseColor,
                ),
                const SizedBox(height: 8),
                _SkeletonBar(width: 180, color: baseColor),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SkeletonBar(width: 110, color: baseColor),
                    _SkeletonBar(width: 92, color: baseColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.color,
    this.height = 14,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 34, color: colorScheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
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
