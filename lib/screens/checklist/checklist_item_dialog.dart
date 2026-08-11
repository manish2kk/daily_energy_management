import 'package:flutter/material.dart';

class ChecklistItemDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialCategory;

  const ChecklistItemDialog({
    super.key,
    this.initialTitle,
    this.initialCategory,
  });

  bool get isEditing => initialTitle != null;

  @override
  State<ChecklistItemDialog> createState() => _ChecklistItemDialogState();
}

class _ChecklistItemDialogState extends State<ChecklistItemDialog> {
  late final TextEditingController _title;
  late String _category;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle ?? '');
    _category = widget.initialCategory ?? 'exercise';
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit checklist item' : 'New checklist item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: const [
              DropdownMenuItem(value: 'exercise', child: Text('Exercise')),
              DropdownMenuItem(value: 'create', child: Text('Create / Build')),
              DropdownMenuItem(value: 'communicate', child: Text('Communicate')),
              DropdownMenuItem(value: 'discharge', child: Text('Discharge')),
            ],
            onChanged: (v) => setState(() => _category = v!),
          ),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
            autofocus: widget.isEditing,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final text = _title.text.trim();
            if (text.isEmpty) return;
            Navigator.pop(context, {
              'title': text,
              'category': _category,
            });
          },
          child: Text(widget.isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
