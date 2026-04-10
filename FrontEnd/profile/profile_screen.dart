import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity_model.dart';
import '../../models/user_model.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    final uid = context.read<AuthProvider>().firebaseUser?.uid;

    if (uid == null) {
      return;
    }

    context.read<UserProvider>().listenUser(uid);
    context.read<ActivityProvider>().listenActivities(uid);
  }

  void _showEditProfileNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng chỉnh sửa hồ sơ đang được hoàn thiện'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.03),
        colorScheme.surface,
      ),
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: user == null
          ? const _ProfileLoadingView()
          : Consumer<ActivityProvider>(
              builder: (_, activityProvider, _) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          children: [
                            _ProfileHeroCard(
                              user: user,
                              onEditPressed: _showEditProfileNotice,
                            ),
                            const SizedBox(height: 18),
                            _ProfileInfoCard(user: user),
                            const SizedBox(height: 18),
                            _ActivitySection(
                              activities: activityProvider.activities,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.user, required this.onEditPressed});

  final UserModel user;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roleColor = user.role == 'admin'
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
        children: [
          _ProfileAvatar(user: user),
          const SizedBox(height: 16),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _TagChip(
                icon: user.role == 'admin'
                    ? Icons.admin_panel_settings_rounded
                    : Icons.person_rounded,
                label: user.role == 'admin' ? 'Quản trị viên' : 'Người dùng',
                backgroundColor: roleColor.withValues(alpha: 0.14),
                foregroundColor: roleColor,
              ),
              _TagChip(
                icon: Icons.verified_user_rounded,
                label: 'Tài khoản đang hoạt động',
                backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
                foregroundColor: colorScheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Chỉnh sửa hồ sơ'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: user.avatarUrl.isNotEmpty
            ? NetworkImage(user.avatarUrl)
            : null,
        child: user.avatarUrl.isEmpty
            ? Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.user});

  final UserModel user;

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
            'Thông tin tài khoản',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Các thông tin chính của tài khoản được hiển thị gọn và dễ đọc hơn.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: user.email,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.badge_rounded,
            label: 'Vai trò',
            value: user.role == 'admin' ? 'Quản trị viên' : 'Người dùng',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tham gia',
            value: user.createdAt == null
                ? 'Chưa có dữ liệu'
                : _formatDate(user.createdAt!),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.fingerprint_rounded,
            label: 'Mã người dùng',
            value: user.uid,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.activities});

  final List<ActivityModel> activities;

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
            'Lịch sử hoạt động',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            activities.isEmpty
                ? 'Bạn chưa có hoạt động nào được ghi nhận.'
                : 'Theo dõi các hành động gần đây trên ứng dụng.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          if (activities.isEmpty)
            _EmptyActivityState()
          else
            ...activities.map((activity) => _ActivityTile(activity: activity)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final ActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = _activityMeta(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: meta.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: meta.foregroundColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(meta.icon, color: meta.foregroundColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.action,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(activity.foodName, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  '${meta.label} • ${_relativeTime(activity.createdAt)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: meta.foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(activity.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Chưa có hoạt động',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Khi bạn bình luận, đánh giá hoặc đặt món, lịch sử sẽ xuất hiện ở đây.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.5,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
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

class _ActivityMeta {
  const _ActivityMeta({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
}

_ActivityMeta _activityMeta(String type) {
  switch (type) {
    case 'review':
      return const _ActivityMeta(
        icon: Icons.star_rounded,
        label: 'Đánh giá',
        backgroundColor: Color(0xFFFFF4DB),
        foregroundColor: Color(0xFFB26A00),
      );
    case 'comment':
      return const _ActivityMeta(
        icon: Icons.chat_bubble_rounded,
        label: 'Bình luận',
        backgroundColor: Color(0xFFE8F1FF),
        foregroundColor: Color(0xFF1565C0),
      );
    default:
      return const _ActivityMeta(
        icon: Icons.shopping_bag_rounded,
        label: 'Đơn hàng',
        backgroundColor: Color(0xFFE9F7EF),
        foregroundColor: Color(0xFF2E7D32),
      );
  }
}

String _formatDate(DateTime dateTime) {
  return '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}/${dateTime.year}';
}

String _formatDateTime(DateTime dateTime) {
  return '${_formatDate(dateTime)} • ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
}

String _relativeTime(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Vừa xong';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes} phút trước';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours} giờ trước';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} ngày trước';
  }
  return _formatDate(dateTime);
}

String _twoDigits(int value) {
  return value.toString().padLeft(2, '0');
}
