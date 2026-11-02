import 'package:flutter/material.dart';

import '../models/entry.dart';
import '../services/storage_service.dart';
import '../widgets/fade_route.dart';
import 'diary_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<Entry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.from(StorageService.instance.entries);
  }

  Future<void> _refreshEntries() async {
    setState(() {
      _entries = List.from(StorageService.instance.entries)
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _deleteEntry(int index, Entry entry) async {
    final deletedIndex = index;
    setState(() {
      _entries.removeAt(index);
    });
    await StorageService.instance.deleteEntryAt(
      StorageService.instance.entries.indexWhere((item) => item.date == entry.date && item.text == entry.text),
    );
    await _refreshEntries();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Diary entry deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final restored = entry;
            StorageService.instance.entries.insert(deletedIndex, restored);
            await StorageService.instance.saveEntries();
            await _refreshEntries();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Diary 📖')),
      body: SafeArea(
        child: _entries.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('📔', style: TextStyle(fontSize: 52)),
                    SizedBox(height: 12),
                    Text(
                      'No entries yet.',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Write your first one from the mood picker.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Dismissible(
                    key: ValueKey('${entry.date.millisecondsSinceEpoch}-${entry.text}-$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete entry?'),
                          content: const Text('This entry will be removed from your diary.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      return shouldDelete ?? false;
                    },
                    onDismissed: (_) async => _deleteEntry(index, entry),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: entry.mood.color,
                      child: ListTile(
                        leading: Text(entry.mood.emoji, style: const TextStyle(fontSize: 32)),
                        title: Text(
                          '${entry.date.day}/${entry.date.month}/${entry.date.year} • ${entry.mood.name}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          entry.text.isEmpty ? '(stickers only)' : entry.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          entry.stickers.map((sticker) => sticker.emoji).take(3).join(),
                          style: const TextStyle(fontSize: 20),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            fadeRoute(
                              DiaryScreen(
                                mood: entry.mood,
                                readOnly: true,
                                entry: entry,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
