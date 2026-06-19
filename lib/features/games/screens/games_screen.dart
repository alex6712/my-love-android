import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Игры',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Мини-игры для вашей пары',
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _buildGameCard(
              title: 'Quiz: Как хорошо ты знаешь свою половинку?',
              description: 'Ответьте на вопросы о предпочтениях друг друга',
              icon: Icons.quiz_outlined,
              color: Colors.purple,
              isDark: isDark,
              onPlay: () => _startQuiz(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onPlay,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: const Text('Играть'),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz() {
    final questions = [
      _QuizQuestion('Какое любимое блюдо твоей половинки?', ['Паста', 'Суши', 'Пицца', 'Борщ'], 0),
      _QuizQuestion('Какой цвет ей/ему нравится больше всего?', ['Красный', 'Синий', 'Розовый', 'Фиолетовый'], 2),
      _QuizQuestion('Что она/он любит делать в выходные?', ['Спать', 'Гулять', 'Читать', 'Смотреть фильмы'], 1),
      _QuizQuestion('Какое её/его любимое время года?', ['Весна', 'Лето', 'Осень', 'Зима'], 0),
      _QuizQuestion('Что бы она/он выбрал(а) на десерт?', ['Торт', 'Мороженое', 'Фрукты', 'Шоколад'], 3),
    ];

    showDialog(
      context: context,
      builder: (ctx) => _QuizDialog(questions: questions),
    );
  }
}

class _QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  _QuizQuestion(this.question, this.options, this.correctIndex);
}

class _QuizDialog extends StatefulWidget {
  final List<_QuizQuestion> questions;

  const _QuizDialog({required this.questions});

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: _showResult ? _buildResult() : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = widget.questions[_currentQuestion];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Вопрос ${_currentQuestion + 1}/${widget.questions.length}',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Text(
          q.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        ...q.options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          final isSelected = _selectedIndex == idx;
          final isCorrect = idx == q.correctIndex;

          Color? bgColor;
          if (_selectedIndex != null) {
            bgColor = isCorrect ? Colors.green.shade100 : (isSelected ? Colors.red.shade100 : null);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIndex == null
                    ? () {
                        setState(() {
                          _selectedIndex = idx;
                          if (idx == q.correctIndex) _score++;
                        });
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) {
                            setState(() {
                              if (_currentQuestion < widget.questions.length - 1) {
                                _currentQuestion++;
                                _selectedIndex = null;
                              } else {
                                _showResult = true;
                              }
                            });
                          }
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(option),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResult() {
    final total = widget.questions.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Результат',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          '$_score из $total',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: _score == total ? Colors.green : (_score > total ~/ 2 ? Colors.orange : Colors.red),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _score == total
              ? 'Идеально! Вы знаете друг друга! 💖'
              : _score > total ~/ 2
                  ? 'Неплохо! Но есть к чему стремиться!'
                  : 'Попробуйте ещё раз!',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
