class AiCoachItem {
  const AiCoachItem({
    required this.id,
    required this.nickname,
    required this.specialty,
    required this.avatarUrl,
    required this.presetQuestions,
  });

  final String id;
  final String nickname;
  final String specialty;
  final String avatarUrl;
  final List<String> presetQuestions;
}

const List<AiCoachItem> aiCoachItems = <AiCoachItem>[
  AiCoachItem(
    id: 'ai_coach_ethan',
    nickname: 'Coach Ethan',
    specialty: 'Fat Loss & Cardio',
    avatarUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
    presetQuestions: <String>[
      'Can you make me a 7-day fat loss cardio plan?',
      'What heart rate zone should I use for fat burning?',
      'How should I schedule HIIT and low-intensity cardio?',
      'Can you design a 25-minute treadmill workout?',
      'What should I eat before morning cardio?',
    ],
  ),
  AiCoachItem(
    id: 'ai_coach_ryan',
    nickname: 'Coach Ryan',
    specialty: 'Strength Training',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    presetQuestions: <String>[
      'Can you build me a 4-day strength split?',
      'How do I progressively overload safely?',
      'What are the best compound lifts for beginners?',
      'How long should I rest between heavy sets?',
      'Can you check my squat and deadlift routine structure?',
    ],
  ),
  AiCoachItem(
    id: 'ai_coach_leo',
    nickname: 'Coach Leo',
    specialty: 'Core & Mobility',
    avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    presetQuestions: <String>[
      'Can you give me a 15-minute core routine at home?',
      'What mobility drills help with tight hips?',
      'How can I improve my posture during desk work?',
      'Can you make a daily lower-back-friendly stretch plan?',
      'What is the right breathing pattern for core training?',
    ],
  ),
  AiCoachItem(
    id: 'ai_coach_mason',
    nickname: 'Coach Mason',
    specialty: 'HIIT Conditioning',
    avatarUrl: 'https://randomuser.me/api/portraits/men/57.jpg',
    presetQuestions: <String>[
      'Can you create a 20-minute HIIT session for me?',
      'How many HIIT days per week are optimal?',
      'What is a good work/rest ratio for HIIT?',
      'Can you make a low-impact HIIT plan for apartment training?',
      'How do I recover faster after high-intensity workouts?',
    ],
  ),
  AiCoachItem(
    id: 'ai_coach_noah',
    nickname: 'Coach Noah',
    specialty: 'Running Endurance',
    avatarUrl: 'https://randomuser.me/api/portraits/men/63.jpg',
    presetQuestions: <String>[
      'Can you make an 8-week 5K improvement plan?',
      'How should I combine easy runs, tempo, and intervals?',
      'What cadence range is good for efficient running?',
      'Can you design a weekly running + strength schedule?',
      'What should I do to prevent shin splints?',
    ],
  ),
  AiCoachItem(
    id: 'ai_coach_alex',
    nickname: 'Coach Alex',
    specialty: 'Posture & Rehab',
    avatarUrl: 'https://randomuser.me/api/portraits/men/74.jpg',
    presetQuestions: <String>[
      'Can you suggest a rehab-friendly full-body workout?',
      'What exercises are good for rounded shoulders?',
      'How can I reduce knee pain during training?',
      'Can you build a gentle recovery day routine?',
      'What warm-up sequence helps prevent common injuries?',
    ],
  ),
  AiCoachItem(
    id: 'ai_coach_daniel',
    nickname: 'Coach Daniel',
    specialty: 'Athletic Performance',
    avatarUrl: 'https://randomuser.me/api/portraits/men/81.jpg',
    presetQuestions: <String>[
      'Can you build a speed and power training week?',
      'How do I improve vertical jump and acceleration?',
      'What is a good plyometric progression for intermediates?',
      'Can you design an agility ladder + sprint session?',
      'How should I periodize performance training over 12 weeks?',
    ],
  ),
  AiCoachItem(
    id: 'ai_coach_jason',
    nickname: 'Coach Jason',
    specialty: 'Functional Training',
    avatarUrl: 'https://randomuser.me/api/portraits/men/90.jpg',
    presetQuestions: <String>[
      'Can you create a functional workout for daily movement?',
      'What exercises improve balance and coordination?',
      'How do I train core stability with minimal equipment?',
      'Can you design a 30-minute kettlebell-style session without kettlebells?',
      'What is a good mobility + strength combo routine?',
    ],
  ),
];
