import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/entry.dart';
import '../models/mood.dart';
import '../models/sticker.dart';
import '../services/storage_service.dart';

class DiaryScreen extends StatefulWidget {
  final Mood mood;
  final bool readOnly;
  final Entry? entry;

  const DiaryScreen({
    super.key,
    required this.mood,
    this.readOnly = false,
    this.entry,
  });

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _open;
  final TextEditingController _textController = TextEditingController();
  final List<Sticker> _stickers = [];
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _open = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _opened = true);
      }
    });

    if (widget.entry != null) {
      _textController.text = widget.entry!.text;
      _stickers.addAll(widget.entry!.stickers);
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && !widget.readOnly) {
        _open.forward();
      } else {
        setState(() => _opened = true);
      }
    });
  }

  @override
  void dispose() {
    _open.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _addSticker(String emoji) {
    final random = math.Random();
    setState(() {
      _stickers.add(
        Sticker(
          emoji: emoji,
          dx: 40 + random.nextDouble() * 160,
          dy: 40 + random.nextDouble() * 200,
          scale: 1.0,
        ),
      );
    });
  }

  Future<void> _saveEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _stickers.isEmpty) {
      return;
    }

    await StorageService.instance.addEntry(
      Entry(
        mood: widget.mood,
        text: text,
        date: DateTime.now(),
        stickers: List<Sticker>.from(_stickers),
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to your diary 💌')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.mood;
    final date = widget.entry?.date ?? DateTime.now();

    return Scaffold(
      backgroundColor: mood.color,
      appBar: AppBar(
        backgroundColor: mood.dark,
        foregroundColor: Colors.white,
        title: Text('${mood.emoji} Feeling ${mood.name}'),
        actions: [
          if (!widget.readOnly)
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _saveEntry,
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(blurRadius: 8, color: Colors.black26),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: LinesPainter(mood.dark)),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TextField(
                              controller: _textController,
                              readOnly: widget.readOnly,
                              maxLines: null,
                              expands: true,
                              style: GoogleFonts.caveat(
                                textStyle: const TextStyle(
                                  fontSize: 24,
                                  height: 1.5,
                                ),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Dear diary...',
                              ),
                            ),
                          ),
                          ..._stickers.map(_buildSticker),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!widget.readOnly)
                  Container(
                    height: 64,
                    color: Colors.white.withValues(alpha: 0.6),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const ['⭐', '🌸', '🦋', '🌈', '💖', '🎀', '🍓', '☁️', '🔥', '🌙', '🐱', '✨']
                          .map(
                            (emoji) => InkWell(
                              onTap: () => _addSticker(emoji),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                if (!widget.readOnly)
                  const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'Tap to add • drag to move • pinch to resize • hold to delete',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
            if (!widget.readOnly && !_opened)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _open,
                  builder: (_, child) {
                    return Transform(
                      alignment: Alignment.centerLeft,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(-math.pi / 2 * Curves.easeInOut.transform(_open.value)),
                      child: Container(
                        color: mood.dark,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(mood.emoji, style: const TextStyle(fontSize: 90)),
                            const SizedBox(height: 12),
                            const Text(
                              'My Secret Diary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSticker(Sticker sticker) {
    if (widget.readOnly) {
      return Positioned(
        left: sticker.dx,
        top: sticker.dy,
        child: Text(
          sticker.emoji,
          style: TextStyle(fontSize: 40 * sticker.scale),
        ),
      );
    }

    double baseScale = sticker.scale;

    return Positioned(
      left: sticker.dx,
      top: sticker.dy,
      child: GestureDetector(
        onScaleStart: (_) => baseScale = sticker.scale,
        onScaleUpdate: (details) => setState(() {
          sticker.dx += details.focalPointDelta.dx;
          sticker.dy += details.focalPointDelta.dy;
          sticker.scale = (baseScale * details.scale).clamp(0.5, 4.0);
        }),
        onLongPress: () => setState(() => _stickers.remove(sticker)),
        child: Text(
          sticker.emoji,
          style: TextStyle(fontSize: 40 * sticker.scale),
        ),
      ),
    );
  }
}

class LinesPainter extends CustomPainter {
  final Color color;

  const LinesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    for (double y = 40; y < size.height; y += 32) {
      canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinesPainter oldDelegate) => oldDelegate.color != color;
}
