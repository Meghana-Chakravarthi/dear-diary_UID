import 'mood.dart';
import 'sticker.dart';

class Entry {
  final Mood mood;
  final String text;
  final DateTime date;
  final List<Sticker> stickers;

  const Entry({
    required this.mood,
    required this.text,
    required this.date,
    required this.stickers,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    final moodName = json['mood']?.toString() ?? 'Happy';
    final stickerList = (json['stickers'] as List<dynamic>? ?? const [])
        .map((item) => Sticker.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return Entry(
      mood: Mood.fromName(moodName),
      text: json['text']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      stickers: stickerList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood.name,
      'text': text,
      'date': date.toIso8601String(),
      'stickers': stickers.map((sticker) => sticker.toJson()).toList(),
    };
  }
}
