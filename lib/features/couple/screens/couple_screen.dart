import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/couple.dart';
import '../providers/couple_provider.dart';

class CoupleScreen extends ConsumerStatefulWidget {
  const CoupleScreen({super.key});

  @override
  ConsumerState<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends ConsumerState<CoupleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(coupleProvider.notifier).loadCouple());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coupleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Пара',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Управление отношениями',
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.coupleInfo?.partnerId != null
                    ? _buildCoupleInfo(state.coupleInfo!, isDark)
                    : _buildNoCouple(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupleInfo(CoupleInfo info, bool isDark) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.red.shade100,
                  child: Icon(Icons.favorite, size: 48, color: Colors.red.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  'Вместе с @${info.partnerUsername ?? '?'}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                ),
                if (info.relationshipDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Вместе с ${DateFormat('dd.MM.yyyy').format(info.relationshipDate!)}',
                    style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _setRelationshipDate(info),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(info.relationshipDate != null ? 'Изменить дату' : 'Установить дату'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _confirmUnfriend(),
                  icon: const Icon(Icons.person_remove_outlined, size: 18, color: Colors.red),
                  label: const Text('Разорвать связь', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 20),
      ],
    );
  }

  Widget _buildNoCouple(bool isDark) {
    final usernameCtrl = TextEditingController();

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'У вас пока нет пары',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Отправьте запрос своей половинке',
                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: usernameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Имя пользователя',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (usernameCtrl.text.trim().isEmpty) return;
                        await ref.read(coupleProvider.notifier).sendRequest(usernameCtrl.text.trim());
                        usernameCtrl.clear();
                      },
                      child: const Text('Отправить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _setRelationshipDate(CoupleInfo info) {
    showDatePicker(
      context: context,
      initialDate: info.relationshipDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ru'),
    ).then((date) {
      if (date != null) {
        ref.read(coupleProvider.notifier).setRelationshipDate(date);
      }
    });
  }

  void _confirmUnfriend() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Разорвать связь?'),
        content: const Text('Вы уверены? Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(coupleProvider.notifier).unfriend();
            },
            child: const Text('Разорвать', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
