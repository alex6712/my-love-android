import 'package:flutter/material.dart';
import '../models/album.dart';

class EditAlbumDialog extends StatefulWidget {
  final Album? album;

  const EditAlbumDialog({super.key, this.album});

  @override
  State<EditAlbumDialog> createState() => _EditAlbumDialogState();
}

class _EditAlbumDialogState extends State<EditAlbumDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late bool _isPrivate;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.album?.title ?? '');
    _descCtrl = TextEditingController(text: widget.album?.description ?? '');
    _isPrivate = widget.album?.isPrivate ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.album != null ? 'Редактировать альбом' : 'Новый альбом'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Описание'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Приватный'),
            value: _isPrivate,
            onChanged: (v) => setState(() => _isPrivate = v),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'title': _titleCtrl.text,
            'description': _descCtrl.text.isEmpty ? null : _descCtrl.text,
            'is_private': _isPrivate,
          }),
          child: Text(widget.album != null ? 'Сохранить' : 'Создать'),
        ),
      ],
    );
  }
}
