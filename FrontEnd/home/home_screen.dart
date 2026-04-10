import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../food/food_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await context.read<AuthProvider>().logout();
      if (!context.mounted) return;
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Đăng xuất thất bại, vui lòng thử lại')),
      );
    }
  }

  void _openFoodList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FoodListScreen()),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.03),
        colorScheme.surface,
      ),
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Đăng xuất',
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout_rounded),
                  ),
          ),
        ],
      ),
      body: user == null
          ? _EmptyHomeState(
              isLoading: authProvider.isLoading || authProvider.isInitializing,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeroCard(
                    user: user,
                    isAdmin: authProvider.isAdmin,
                    onLogout: authProvider.isLoading
                        ? null
                        : () => _handleLogout(context),
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(
                    title: 'Truy cập nhanh',
                    subtitle: 'Đi tới những khu vực bạn dùng nhiều nhất.',
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Danh sách món ăn',
                    description:
                        'Khám phá món ăn theo vùng miền, xem chi tiết và video hướng dẫn.',
                    accentColor: colorScheme.primary,
                    buttonLabel: 'Mở danh sách',
                    onPressed: () => _openFoodList(context),
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.person_rounded,
                    title: 'Hồ sơ cá nhân',
                    description:
                        'Xem thông tin tài khoản và lịch sử hoạt động của bạn.',
                    accentColor: colorScheme.secondary,
                    buttonLabel: 'Xem hồ sơ',
                    onPressed: () => _openProfile(context),
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(
                    title: 'Trạng thái tài khoản',
                    subtitle: 'Thông tin hiện tại của phiên đăng nhập.',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatusCard(
                        icon: authProvider.isAdmin
                            ? Icons.admin_panel_settings_rounded
                            : Icons.verified_user_rounded,
                        title: 'Vai trò',
                        value: authProvider.isAdmin
                            ? 'Quản trị viên'
                            : 'Người dùng',
                        accentColor: authProvider.isAdmin
                            ? const Color(0xFFC62828)
                            : const Color(0xFF1565C0),
                      ),
                      _StatusCard(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: user.email,
                        accentColor: colorScheme.tertiary,
                      ),
                      _StatusCard(
                        icon: Icons.manage_accounts_rounded,
                        title: 'Quyền thao tác',
                        value: authProvider.isAdmin
                            ? 'Có thể thêm món ăn mới'
                            : 'Duyệt và xem nội dung',
                        accentColor: const Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({
    required this.user,
    required this.isAdmin,
    required this.onLogout,
  });

  final UserModel user;
  final bool isAdmin;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roleColor = isAdmin
        ? const Color(0xFFC62828)
        : const Color(0xFF1565C0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              _HomeAvatar(name: user.name, avatarUrl: user.avatarUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${user.name}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : Icons.person_rounded,
                label: isAdmin ? 'Quản trị viên' : 'Người dùng',
                backgroundColor: roleColor.withValues(alpha: 0.14),
                foregroundColor: roleColor,
              ),
              _InfoChip(
                icon: Icons.auto_awesome_rounded,
                label: isAdmin
                    ? 'Có thể quản lý nội dung'
                    : 'Khám phá ẩm thực Việt',
                backgroundColor: colorScheme.surface.withValues(alpha: 0.72),
                foregroundColor: colorScheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isAdmin
                ? 'Bạn đang ở khu vực quản trị. Có thể thêm món ăn và theo dõi nội dung hệ thống.'
                : 'Bắt đầu khám phá món ăn, xem video hướng dẫn và theo dõi hồ sơ của bạn.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.84),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty
            ? Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final String buttonLabel;
  final VoidCallback onPressed;

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
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(buttonLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = (MediaQuery.of(context).size.width - 52) / 2;

    return Container(
      width: width < 170 ? double.infinity : width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
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
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator()
              else
                Icon(
                  Icons.person_off_rounded,
                  size: 42,
                  color: colorScheme.primary,
                ),
              const SizedBox(height: 18),
              Text(
                isLoading
                    ? 'Đang xử lý tài khoản...'
                    : 'Không có dữ liệu người dùng',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isLoading
                    ? 'Vui lòng chờ trong giây lát.'
                    : 'Phiên đăng nhập có thể đã kết thúc. Hãy đăng nhập lại để tiếp tục.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
