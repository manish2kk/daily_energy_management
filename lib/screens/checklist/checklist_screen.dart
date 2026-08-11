import 'package:flutter/material.dart';

import '../../data/app_db.dart';
import '../../utils/category_style.dart';
import 'checklist_item_dialog.dart';

class ChecklistScreen extends StatefulWidget {
  final VoidCallback onChanged;

  const ChecklistScreen({super.key, required this.onChanged});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<Map<String, Object?>> items = [];

  static const defaults = [
    ('Body', 'exercise'),
    ('Website', 'create'),
    ('To customer', 'communicate'),
    ('Scrolling', 'discharge'),
  ];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await AppDb.seedDefaults(defaults);
    items = await AppDb.today();
    if (mounted) setState(() {});
  }

  Future<void> toggle(Map<String, Object?> item) async {
    await AppDb.toggle(item['id'] as int, !(item['completed'] as int == 1));
    await load();
    widget.onChanged();
  }

  Future<Map<String, String>?> _openItemDialog({
    String? title,
    String? category,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => ChecklistItemDialog(
        initialTitle: title,
        initialCategory: category,
      ),
    );
  }

  Future<void> add() async {
    final result = await _openItemDialog();
    if (result == null) return;
    await AppDb.add(result['title']!, result['category']!);
    await load();
    widget.onChanged();
  }

  Future<void> edit(Map<String, Object?> item) async {
    final result = await _openItemDialog(
      title: item['title'] as String,
      category: item['category'] as String,
    );
    if (result == null) return;
    await AppDb.updateItem(
      item['id'] as int,
      result['title']!,
      result['category']!,
    );
    await load();
    widget.onChanged();
  }

  Future<void> delete(Map<String, Object?> item) async {
    await AppDb.deleteItem(item['id'] as int);
    await load();
    widget.onChanged();
  }

  Future<void> showItemActions(Map<String, Object?> item) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
              title: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      await edit(item);
    } else if (action == 'delete') {
      await delete(item);
    }
  }

  void _moveCheckedToBottom() {
    final open = items.where((e) => (e['completed'] as int) != 1).toList();
    final done = items.where((e) => (e['completed'] as int) == 1).toList();
    items = [...open, ...done];
  }

  void onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      _moveCheckedToBottom();
    });
    AppDb.reorder(items.map((e) => e['id'] as int).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist'),
        actions: [
          IconButton(onPressed: add, icon: const Icon(Icons.add)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: add,
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: items.length,
        onReorderItem: onReorderItem,
        buildDefaultDragHandles: false,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: child,
              );
            },
            child: child,
          );
        },
        itemBuilder: (_, i) {
          final item = items[i];
          final id = item['id'] as int;
          final cat = item['category'] as String;
          final checked = item['completed'] as int == 1;
          final brightness = Theme.of(context).brightness;
          final bg = checked
              ? checkedItemColor(brightness: brightness)
              : categoryColor(cat, brightness: brightness);
          final titleColor = checklistTitleColor(brightness: brightness);
          final mutedColor = checklistMutedColor(brightness: brightness);

          return Card(
            key: ValueKey(id),
            color: bg,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Checkbox(
                value: checked,
                onChanged: (_) => toggle(item),
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  color: titleColor,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  decorationColor: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                categoryLabel(cat),
                style: TextStyle(color: mutedColor),
              ),
              onLongPress: () => showItemActions(item),
              trailing: ReorderableDragStartListener(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.drag_handle, color: mutedColor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
