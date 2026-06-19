import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/media/screens/media_gallery_screen.dart';
import '../features/media/screens/album_detail_screen.dart';
import '../features/notes/screens/notes_screen.dart';
import '../features/games/screens/games_screen.dart';
import '../features/couple/screens/couple_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (isAuth && isLoginRoute) return '/';
      if (!isAuth && !isLoginRoute && authState.status != AuthStatus.unknown) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      ShellRoute(
        builder: (_, _, child) => DashboardShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
          GoRoute(
            path: '/media',
            builder: (_, _) => const MediaGalleryScreen(),
            routes: [
              GoRoute(
                path: 'album/:albumId',
                builder: (_, state) => AlbumDetailScreen(
                  albumId: state.pathParameters['albumId']!,
                ),
              ),
            ],
          ),
          GoRoute(path: '/notes', builder: (_, _) => const NotesScreen()),
          GoRoute(path: '/games', builder: (_, _) => const GamesScreen()),
          GoRoute(path: '/couple', builder: (_, _) => const CoupleScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(child: child);
  }
}

class DashboardLayout extends ConsumerWidget {
  final Widget child;
  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final location = GoRouterState.of(context).uri.toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: MediaQuery.of(context).size.width <= 768
          ? SideDrawer(
              username: auth.user?.username ?? '',
              currentPath: location,
              isDark: isDark,
              onNavigate: (path) => context.go(path),
              onLogout: () => ref.read(authProvider.notifier).logout(),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF1C0F29),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF0F2),
                    Color(0xFFFFF0F0),
                    Color(0xFFFDF2F8),
                  ],
                ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (MediaQuery.of(context).size.width > 768)
                Sidebar(
                  username: auth.user?.username ?? '',
                  currentPath: location,
                  isDark: isDark,
                  onNavigate: (path) => context.go(path),
                  onLogout: () => ref.read(authProvider.notifier).logout(),
                ),
              Expanded(
                child: Column(
                  children: [
                    if (MediaQuery.of(context).size.width <= 768)
                      MobileHeader(
                        username: auth.user?.username ?? '',
                        currentPath: location,
                        isDark: isDark,
                        onNavigate: (path) => context.go(path),
                        onLogout: () =>
                            ref.read(authProvider.notifier).logout(),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationContent extends StatelessWidget {
  final String username;
  final String currentPath;
  final bool isDark;
  final void Function(String) onNavigate;
  final VoidCallback onLogout;

  const _NavigationContent({
    required this.username,
    required this.currentPath,
    required this.isDark,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(),
        _buildNav(),
        _buildBottomNav(),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, color: Colors.red.shade500, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Love',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '@$username',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    final items = [
      ('/', 'Главная', Icons.favorite_border),
      ('/media', 'Медиа', Icons.image_outlined),
      ('/notes', 'Заметки', Icons.sticky_note_2_outlined),
      ('/games', 'Игры', Icons.sports_esports_outlined),
      ('/couple', 'Пара', Icons.people_outline),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: items
            .map((item) => _navItem(item.$1, item.$2, item.$3))
            .toList(),
      ),
    );
  }

  Widget _navItem(String path, String label, IconData icon) {
    final active = path == '/'
        ? currentPath == '/'
        : currentPath.startsWith(path);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: active ? Colors.red.shade500 : null,
            foregroundColor: active ? Colors.white : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => onNavigate(path),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 12),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      ('/profile', 'Профиль', Icons.person_outline),
      ('/settings', 'Настройки', Icons.settings_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        children: items
            .map((item) => _navItem(item.$1, item.$2, item.$3))
            .toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Выйти'),
          style: TextButton.styleFrom(
            foregroundColor: isDark
                ? Colors.grey.shade300
                : Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final String username;
  final String currentPath;
  final bool isDark;
  final void Function(String) onNavigate;
  final VoidCallback onLogout;

  const Sidebar({
    super.key,
    required this.username,
    required this.currentPath,
    required this.isDark,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: _NavigationContent(
        username: username,
        currentPath: currentPath,
        isDark: isDark,
        onNavigate: onNavigate,
        onLogout: onLogout,
      ),
    );
  }
}

class SideDrawer extends StatelessWidget {
  final String username;
  final String currentPath;
  final bool isDark;
  final void Function(String) onNavigate;
  final VoidCallback onLogout;

  const SideDrawer({
    super.key,
    required this.username,
    required this.currentPath,
    required this.isDark,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: _NavigationContent(
          username: username,
          currentPath: currentPath,
          isDark: isDark,
          onNavigate: (path) {
            Navigator.of(context).pop();
            onNavigate(path);
          },
          onLogout: () {
            Navigator.of(context).pop();
            onLogout();
          },
        ),
      ),
    );
  }
}

class MobileHeader extends StatelessWidget {
  final String username;
  final String currentPath;
  final bool isDark;
  final void Function(String) onNavigate;
  final VoidCallback onLogout;

  const MobileHeader({
    super.key,
    required this.username,
    required this.currentPath,
    required this.isDark,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const Spacer(),
          Icon(Icons.favorite, color: Colors.red.shade500, size: 24),
          const SizedBox(width: 8),
          const Text('My Love', style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
