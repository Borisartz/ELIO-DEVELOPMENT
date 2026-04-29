import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/waste_category.dart';
import '../../../providers/learning_progress_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final WasteCategory category;
  const QuizScreen({super.key, required this.category});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedOption;

  void _selectAnswer(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = index;
      _isAnswered = true;
      if (index == widget.category.quiz[_currentQuestion].correctIndex) {
        _score++;
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_currentQuestion < widget.category.quiz.length - 1) {
        setState(() {
          _currentQuestion++;
          _isAnswered = false;
          _selectedOption = null;
        });
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    // Persist progress before showing the result dialog.
    ref
        .read(learningProgressProvider.notifier)
        .updateProgress(
          widget.category.id,
          _score,
          widget.category.quiz.length,
        );

    final int total = widget.category.quiz.length;
    final String emoji = _score == total
        ? '🎉'
        : _score >= total / 2
        ? '👍'
        : '📚';
    final String msg = _score == total
        ? 'Perfect Score!'
        : _score >= total / 2
        ? 'Good Job!'
        : 'Keep Learning!';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$emoji Quiz Complete!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / $total',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D9E75),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: const TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.category.quiz[_currentQuestion];
    final Color color = Color(int.parse(widget.category.color));
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.emoji} ${widget.category.title} Quiz'),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestion + 1}/${widget.category.quiz.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D9E75),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentQuestion + 1) / widget.category.quiz.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
            const Spacer(flex: 1),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                q.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 1),
            ...q.options.asMap().entries.map((entry) {
              final int idx = entry.key;
              final String opt = entry.value;
              bool isSelected = _selectedOption == idx;
              bool isCorrect = idx == q.correctIndex;
              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade200;
              Color textColor = const Color(0xFF1C2833);
              if (_isAnswered) {
                if (isCorrect) {
                  bgColor = const Color(0xFFE8F5E9);
                  borderColor = const Color(0xFF4CAF50);
                  textColor = const Color(0xFF2E7D32);
                } else if (isSelected && !isCorrect) {
                  bgColor = const Color(0xFFFFEBEE);
                  borderColor = const Color(0xFFE74C3C);
                  textColor = const Color(0xFFC62828);
                }
              } else if (isSelected) {
                borderColor = color;
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _selectAnswer(idx),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                isSelected || (_isAnswered && isCorrect)
                                ? borderColor
                                : Colors.grey.shade200,
                            child: Text(
                              String.fromCharCode(65 + idx),
                              style: TextStyle(
                                color: isSelected || (_isAnswered && isCorrect)
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (_isAnswered && isCorrect)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4CAF50),
                            )
                          else if (_isAnswered && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: Color(0xFFE74C3C)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
