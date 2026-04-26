class WasteCategory {
  final String id;
  final String title;
  final String emoji;
  final String color;
  final String description;
  final List<String> examples;
  final List<String> tips;
  final String aiInfo;
  final List<QuizQuestion> quiz;
  const WasteCategory({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.description,
    required this.examples,
    required this.tips,
    required this.aiInfo,
    required this.quiz,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

const List<WasteCategory> wasteCategories = [
  WasteCategory(
    id: 'organic',
    title: 'Organic Waste',
    emoji: '🌿',
    color: '0xFF4CAF50',
    description:
        'Organic waste is biodegradable material that comes from plants or animals. It can be composted and turned into natural fertilizer.',
    examples: [
      'Food scraps (vegetable peels, fruit rinds)',
      'Leftover cooked food',
      'Coffee grounds and tea bags',
      'Grass clippings and leaves',
      'Eggshells',
    ],
    tips: [
      'Compost at home to reduce landfill waste',
      'Use a sealed bin to prevent odors',
      'Avoid mixing with plastic or metal',
      'Can be turned into biogas energy',
    ],
    aiInfo:
        'ELIO uses YOLOv segmentation to identify organic waste by color, texture, and shape. Green and brown organic matter is detected with 94% accuracy.',
    quiz: [
      QuizQuestion(
        question: 'Which of these is organic waste?',
        options: ['Plastic bottle', 'Banana peel', 'Aluminum can', 'Glass jar'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'What can organic waste be turned into?',
        options: ['Plastic', 'Glass', 'Compost/Fertilizer', 'Metal'],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: 'How should you store organic waste at home?',
        options: [
          'In a plastic bag',
          'In a sealed bin',
          'In the open air',
          'In water',
        ],
        correctIndex: 1,
      ),
    ],
  ),
  WasteCategory(
    id: 'inorganic',
    title: 'Inorganic Waste',
    emoji: '♻️',
    color: '0xFF2196F3',
    description:
        'Inorganic waste includes non-biodegradable materials like plastic, glass, and metal. Most of it can be recycled.',
    examples: [
      'Plastic bottles and containers',
      'Glass jars and bottles',
      'Aluminum cans and foil',
      'Paper and cardboard',
      'Metal scraps',
    ],
    tips: [
      'Rinse containers before recycling',
      'Separate by material type',
      'Flatten cardboard boxes to save space',
      'Check recycling codes on plastics (1-7)',
    ],
    aiInfo:
        'ELIO detects inorganic waste using reflectivity and edge detection. Plastic and metal surfaces have distinct optical signatures that the AI recognizes.',
    quiz: [
      QuizQuestion(
        question: 'What does recycling code "1" mean?',
        options: ['Glass', 'PET Plastic', 'Paper', 'Metal'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'Should you rinse containers before recycling?',
        options: [
          'No',
          'Yes, to remove food residue',
          'Only glass',
          'Only metal',
        ],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'Which is NOT inorganic waste?',
        options: ['Aluminum can', 'Banana leaf', 'Glass bottle', 'Plastic bag'],
        correctIndex: 1,
      ),
    ],
  ),
  WasteCategory(
    id: 'hazardous',
    title: 'Hazardous Waste',
    emoji: '⚠️',
    color: '0xFFE74C3C',
    description:
        'Hazardous waste contains toxic, flammable, or corrosive substances that can harm people and the environment.',
    examples: [
      'Batteries (AA, AAA, lithium)',
      'Electronic waste (phones, cables)',
      'Fluorescent light bulbs',
      'Paint and solvents',
      'Pesticides and herbicides',
    ],
    tips: [
      'Never mix with regular trash',
      'Take to certified disposal centers',
      'Store in original containers',
      'Keep away from children and pets',
    ],
    aiInfo:
        'ELIO identifies hazardous items using shape recognition and warning symbol detection. Battery and electronic shapes are classified with special care.',
    quiz: [
      QuizQuestion(
        question: 'Where should you dispose of old batteries?',
        options: [
          'Regular trash',
          'Recycling bin',
          'Certified disposal center',
          'Compost',
        ],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: 'Is e-waste considered hazardous?',
        options: ['No', 'Only if broken', 'Yes', 'Only laptops'],
        correctIndex: 2,
      ),
      QuizQuestion(
        question: 'How should hazardous waste be stored?',
        options: [
          'In any box',
          'In original containers',
          'In plastic bags',
          'In the fridge',
        ],
        correctIndex: 1,
      ),
    ],
  ),
];
