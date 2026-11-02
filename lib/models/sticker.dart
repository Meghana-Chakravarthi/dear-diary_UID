class Sticker {
  final String emoji;
  double dx;
  double dy;
  double scale;

  Sticker({
    required this.emoji,
    required this.dx,
    required this.dy,
    this.scale = 1.0,
  });

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      emoji: json['emoji']?.toString() ?? '✨',
      dx: (json['dx'] as num?)?.toDouble() ?? 0.0,
      dy: (json['dy'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'dx': dx,
      'dy': dy,
      'scale': scale,
    };
  }
}
