import 'dart:ui';

class Mood {
  final String name;
  final String emoji;
  final Color color;
  final Color dark;

  const Mood({
    required this.name,
    required this.emoji,
    required this.color,
    required this.dark,
  });

  static const List<Mood> defaultMoods = [
    Mood(
      name: 'Happy',
      emoji: '😄',
      color: Color(0xFFFFD54F),
      dark: Color(0xFFF9A825),
    ),
    Mood(
      name: 'Calm',
      emoji: '😌',
      color: Color(0xFF80DEEA),
      dark: Color(0xFF00ACC1),
    ),
    Mood(
      name: 'Sad',
      emoji: '😔',
      color: Color(0xFF90CAF9),
      dark: Color(0xFF1E88E5),
    ),
    Mood(
      name: 'Angry',
      emoji: '😡',
      color: Color(0xFFEF9A9A),
      dark: Color(0xFFE53935),
    ),
    Mood(
      name: 'Loved',
      emoji: '🥰',
      color: Color(0xFFF8BBD0),
      dark: Color(0xFFD81B60),
    ),
  ];

  static Mood fromName(String value) {
    return defaultMoods.firstWhere(
      (mood) => mood.name == value,
      orElse: () => defaultMoods.first,
    );
  }

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood.fromName(json['name']?.toString() ?? 'Happy');
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emoji': emoji,
      'color': color.toARGB32(),
      'dark': dark.toARGB32(),
    };
  }
}
