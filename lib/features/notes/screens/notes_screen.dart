import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => ref.read(notesProvider.notifier).loadNotes());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final types = [
        null,
        NoteType.wishlist,
        NoteType.dream,
        NoteType.gratitude,
        NoteType.memory,
      ];
      ref
          .read(notesProvider.notifier)
          .loadNotes(type: types[_tabController.index]);
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(notesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Заметки',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Мысли и воспоминания вашей пары',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            FloatingActionButton.small(
              onPressed: () => _showCreateDialog(isDark),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Все'),
            Tab(text: 'Хотелки'),
            Tab(text: 'Мечты'),
            Tab(text: 'Благодарности'),
            Tab(text: 'Воспоминания'),
          ],
          labelColor: Colors.red.shade500,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red.shade500,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.notes.isEmpty
              ? Center(
                  child: Text(
                    'Нет заметок',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(notesProvider.notifier).loadNotes(),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    itemCount:
                        state.notes.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.notes.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _buildNoteCard(state.notes[index], isDark);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(Note note, bool isDark) {
    final iconMap = {
      NoteType.wishlist: Icons.favorite_border,
      NoteType.dream: Icons.nights_stay_outlined,
      NoteType.gratitude: Icons.favorite,
      NoteType.memory: Icons.auto_stories_outlined,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  iconMap[note.type] ?? Icons.note,
                  size: 20,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  note.type.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(note.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                  onPressed: () => _deleteNote(note),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (note.title.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              note.content,
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 20);
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showCreateDialog(bool isDark) {
    final contentCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    var selectedType = NoteType.memory;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Новая заметка'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width > 400
                ? 400
                : MediaQuery.of(context).size.width - 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<NoteType>(
                  initialValue: selectedType,
                  items: NoteType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Тип'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Заголовок (необязательно)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(labelText: 'Содержание'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentCtrl.text.trim().isEmpty) return;
                await ref
                    .read(notesProvider.notifier)
                    .createNote(
                      type: selectedType,
                      content: contentCtrl.text.trim(),
                      title: titleCtrl.text.trim().isEmpty
                          ? null
                          : titleCtrl.text.trim(),
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить заметку?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(notesProvider.notifier).deleteNote(note.id);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
