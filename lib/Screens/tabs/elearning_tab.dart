import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/waste_category.dart';
import '../../providers/learning_progress_provider.dart';
import 'elearning/waste_detail_screen.dart';

class ElearningTab extends ConsumerWidget {
  const ElearningTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(learningProgressProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'E-Learning',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C2833),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Learn about waste types and how ELIO sorts them',
                style: TextStyle(fontSize: 13, color: Color(0xFF7F8C8D)),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'AI Detect will be available in the Control tab once ESP32 is connected.',
                    ),
                    backgroundColor: Color(0xFF1C2833),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C2833), Color(0xFF2C3E50)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        color: Color(0xFF1D9E75),
                        size: 28,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Detect',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Use ELIO camera to identify waste in real-time',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Waste Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C2833),
                ),
              ),
              const SizedBox(height: 12),
              ...wasteCategories.map(
                (c) => _CategoryCard(
                  category: c,
                  progress: progressAsync.valueOrNull?.categories[c.id]
                          ?.progressPercentage ??
                      0.0,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Facts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C2833),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _factCard(
                    '2.01B',
                    'Tonnes yearly',
                    Icons.public,
                    const Color(0xFF1D9E75),
                  ),
                  const SizedBox(width: 12),
                  _factCard(
                    '91%',
                    'Never recycled',
                    Icons.warning_amber_outlined,
                    const Color(0xFFE74C3C),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _factCard(
                    '250g',
                    'Compost per 1kg',
                    Icons.eco_outlined,
                    const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 12),
                  _factCard(
                    '94%',
                    'ELIO accuracy',
                    Icons.smart_toy_outlined,
                    const Color(0xFF2196F3),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _factCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final WasteCategory category;
  final double progress;
  const _CategoryCard({required this.category, required this.progress});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(category.color));
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WasteDetailScreen(category: category),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C2833),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.examples.length} examples  •  ${category.quiz.length} quiz questions',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
