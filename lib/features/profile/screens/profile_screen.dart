import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_codes.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Профиль',
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
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.red.shade100,
                      child: Text(
                        (auth.user?.username.isNotEmpty == true
                                ? auth.user!.username[0].toUpperCase()
                                : '?'),
                        style: TextStyle(fontSize: 36, color: Colors.red.shade400),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '@${auth.user?.username ?? '?'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (auth.user?.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'На платформе с ${_formatDate(auth.user!.createdAt)}',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
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
                      'Смена пароля',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _currentPasswordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Текущий пароль',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPasswordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Новый пароль',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPasswordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Подтвердите новый пароль',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isChangingPassword ? null : _changePassword,
                        child: Text(_isChangingPassword ? 'Смена...' : 'Изменить пароль'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordCtrl.text;
    final newPass = _newPasswordCtrl.text;
    final confirm = _confirmPasswordCtrl.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Новые пароли не совпадают')),
      );
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      await dio.post(
        '/auth/change-password',
        data: {
          'current_password': current,
          'new_password': newPass,
          'confirm_password': confirm,
        },
      );
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароль изменён')),
        );
      }
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'] as String?;
      final code = e.response?.data?['code'] as String?;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translateApiCode(code ?? 'UNKNOWN', detail ?? 'Ошибка при смене пароля'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }
}
