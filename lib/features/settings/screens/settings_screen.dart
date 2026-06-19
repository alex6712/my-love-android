import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тема оформления',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _themeOption('Светлая', Icons.light_mode_outlined, ThemeModeOption.light, themeState.mode, isDark, (v) => ref.read(themeProvider.notifier).setTheme(v)),
                    _themeOption('Тёмная', Icons.dark_mode_outlined, ThemeModeOption.dark, themeState.mode, isDark, (v) => ref.read(themeProvider.notifier).setTheme(v)),
                    _themeOption('Системная', Icons.settings_brightness_outlined, ThemeModeOption.system, themeState.mode, isDark, (v) => ref.read(themeProvider.notifier).setTheme(v)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    String label,
    IconData icon,
    ThemeModeOption option,
    ThemeModeOption selectedMode,
    bool isDark,
    ValueChanged<ThemeModeOption> onChanged,
  ) {
    return RadioListTile<ThemeModeOption>(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
      value: option,
      groupValue: selectedMode,
      onChanged: (v) => onChanged(v!),
      activeColor: Colors.red.shade400,
    );
  }
}
