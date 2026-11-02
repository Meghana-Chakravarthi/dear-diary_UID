import 'package:flutter/material.dart';

import '../models/mood.dart';
import '../widgets/fade_route.dart';
import 'diary_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MoodPickerScreen extends StatelessWidget {
  const MoodPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodList = Mood.defaultMoods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secret Diary'),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(context, fadeRoute(const HistoryScreen()));
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(context, fadeRoute(const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFF3E5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your diary will open to match ✨',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    alignment: WrapAlignment.center,
                    children: moodList.map((mood) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            fadeRoute(DiaryScreen(mood: mood)),
                          );
                        },
                        child: Hero(
                          tag: 'mood-${mood.name}',
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: mood.color,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: mood.dark.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(mood.emoji, style: const TextStyle(fontSize: 42)),
                                const SizedBox(height: 8),
                                Text(
                                  mood.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
