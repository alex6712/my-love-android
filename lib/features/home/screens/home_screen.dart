import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final statsAsync = ref.watch(homeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildWelcome(auth.user?.username ?? '', isDark),
            const SizedBox(height: 32),
            statsAsync.when(
              data: (stats) => _buildStats(stats, isDark),
              loading: () => _buildStatsSkeleton(isDark),
              error: (_, _) => _buildStatsFallback(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(String username, bool isDark) {
    return Column(
      children: [
        Text(
          'Привет, @$username! 💖',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ).animate().fadeIn().slideY(begin: -20, duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Добро пожаловать в ваш цифровой сад воспоминаний',
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: 16,
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildStats(DashboardStats? stats, bool isDark) {
    final items = [
      _StatItem(
        label: 'Фотографий',
        value: stats?.filesCount.toString() ?? '...',
        icon: Icons.image_outlined,
        color: Colors.pink.shade400,
      ),
      _StatItem(
        label: 'Заметок',
        value: stats?.notesCount.toString() ?? '...',
        icon: Icons.message_outlined,
        color: Colors.purple.shade400,
      ),
      _StatItem(
        label: 'Дней вместе',
        value: '∞',
        icon: Icons.calendar_today_outlined,
        color: Colors.red.shade400,
      ),
      _StatItem(
        label: 'Моментов счастья',
        value: '∞',
        icon: Icons.favorite_outline,
        color: Colors.pink.shade400,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final spacing = 16.0;
        final availableWidth = constraints.maxWidth - spacing * (crossAxisCount - 1);
        final itemWidth = availableWidth / crossAxisCount;
        const minContentHeight = 150.0;
        final aspectRatio = (itemWidth / minContentHeight).clamp(0.85, 1.5);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 32, color: item.color),
                    const SizedBox(height: 12),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 20);
          },
        );
      },
    );
  }

  Widget _buildStatsSkeleton(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final spacing = 16.0;
        final availableWidth = constraints.maxWidth - spacing * (crossAxisCount - 1);
        final itemWidth = availableWidth / crossAxisCount;
        const minContentHeight = 150.0;
        final aspectRatio = (itemWidth / minContentHeight).clamp(0.85, 1.5);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: 4,
          itemBuilder: (_, _) => Card(
            child: Center(
              child: CircularProgressIndicator(color: Colors.red.shade300),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsFallback(bool isDark) {
    return _buildStats(DashboardStats(filesCount: 0, notesCount: 0), isDark);
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
