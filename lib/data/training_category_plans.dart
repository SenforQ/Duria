import 'library_training_plan.dart';

LibraryTrainingStep _s(String n, int m, String d) =>
    LibraryTrainingStep(name: n, minutes: m, detail: d);

List<LibraryTrainingPlan> plansForTrainingCategoryTitle(String categoryTitle) {
  switch (categoryTitle) {
    case 'Full-body fitness':
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: 'Full-body circuit · Starter',
          level: 'Beginner',
          totalMinutes: 28,
          steps: <LibraryTrainingStep>[
            _s('Dynamic warm-up', 6,
                'Arm circles, lunge twists, ankle mobility.'),
            _s('Bodyweight squat', 8,
                '3 × 12 reps; thighs parallel to the floor.'),
            _s('Knee push-up', 8, '3 × 10 reps; straight line from head to heels.'),
            _s('Static stretch', 6, 'Hamstrings and chest, 30s each.'),
          ],
        ),
        LibraryTrainingPlan(
          name: 'Full-body sculpt · Progress',
          level: 'Intermediate',
          totalMinutes: 36,
          steps: <LibraryTrainingStep>[
            _s('Jump rope / jumping jacks', 5,
                'Raise heart rate; land softly.'),
            _s('Dumbbell compound press', 12,
                '3 × 10; stack shoulder, elbow, wrist.'),
            _s('Walking lunge', 10, '10 steps each leg × 3 sets.'),
            _s('Dead bug', 5, '3 × 12; low back pressed to floor.'),
            _s('Cool-down', 4, 'Deep breathing and upper-body stretch.'),
          ],
        ),
      ];
    case 'Running & cardio':
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: 'Easy run · Cardio base',
          level: 'Beginner',
          totalMinutes: 30,
          steps: <LibraryTrainingStep>[
            _s('Walk warm-up', 5, 'Gradually build to brisk walk.'),
            _s('Easy jog', 20, 'Talk-test pace; nasal inhale if comfortable.'),
            _s('Cool-down walk', 5, 'Heart rate down before stopping.'),
          ],
        ),
        LibraryTrainingPlan(
          name: 'Intervals · Build pace',
          level: 'Intermediate',
          totalMinutes: 35,
          steps: <LibraryTrainingStep>[
            _s('Dynamic warm-up', 6, 'High knees and butt kicks, 2 rounds each.'),
            _s('Interval run', 20, '2 min hard + 2 min easy × 5.'),
            _s('Easy jog', 6, 'Comfortable pace.'),
            _s('Calf stretch', 3, 'Wall gastrocnemius stretch.'),
          ],
        ),
      ];
    case 'Fat-burn jumps':
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: 'Tabata jump burn',
          level: 'Intermediate',
          totalMinutes: 24,
          steps: <LibraryTrainingStep>[
            _s('Warm-up', 4, 'Joint circles and light hops.'),
            _s('Jumping jacks', 8, '20s work + 10s rest × 8 rounds.'),
            _s('Squat jump', 8, 'Soft landing; knees track toes.'),
            _s('March in place', 4, 'Regulate breathing.'),
          ],
        ),
        LibraryTrainingPlan(
          name: 'Low-impact cardio',
          level: 'Beginner',
          totalMinutes: 22,
          steps: <LibraryTrainingStep>[
            _s('March in place', 4, 'Swing arms, lengthen stride.'),
            _s('Alternating knee lift', 8, 'Light core brace, steady rhythm.'),
            _s('Side lunge', 6, '10 reps each side × 2 sets.'),
            _s('Stretch', 4, 'Hips and inner thighs.'),
          ],
        ),
      ];
    case 'Stretch & recovery':
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: 'Full-body flexibility · Bedtime',
          level: 'Beginner',
          totalMinutes: 18,
          steps: <LibraryTrainingStep>[
            _s('Cat-cow', 4, 'Segmental spine motion.'),
            _s('Seated forward fold', 5, 'Hamstrings; no bouncing.'),
            _s('Pigeon (easy)', 5, 'Hip opener, both sides.'),
            _s("Child's pose", 4, 'Relax low back and shoulders.'),
          ],
        ),
        LibraryTrainingPlan(
          name: 'Post-workout stretch',
          level: 'Beginner',
          totalMinutes: 15,
          steps: <LibraryTrainingStep>[
            _s('Doorway chest stretch', 4, 'Forearm on frame, lean forward.'),
            _s('Standing quad stretch', 4, 'Use wall; 2 min each leg.'),
            _s('Rear-delt stretch', 4, 'Arm across chest, gentle pull.'),
            _s('Neck side bend', 3, 'Slow tilt, 30s each side.'),
          ],
        ),
      ];
    case 'Warm-up & activation':
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: 'Pre-strength warm-up',
          level: 'Beginner',
          totalMinutes: 12,
          steps: <LibraryTrainingStep>[
            _s('Brisk walk or bike', 4, 'Light sweat.'),
            _s('Band external rotation', 4, '2 × 15; stable scapula.'),
            _s('Bodyweight squat prep', 4, '2 × 10; increase depth gradually.'),
          ],
        ),
        LibraryTrainingPlan(
          name: 'Pre-run activation',
          level: 'Beginner',
          totalMinutes: 10,
          steps: <LibraryTrainingStep>[
            _s('Ankle circles', 2, 'Both directions each side.'),
            _s('Lunge stretch', 4, 'Neutral pelvis, hip flexor focus.'),
            _s('A-skip / quick steps', 4, 'Build cadence gradually.'),
          ],
        ),
      ];
    case 'Core training':
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: 'Core stability base',
          level: 'Beginner',
          totalMinutes: 20,
          steps: <LibraryTrainingStep>[
            _s('Dead bug', 6, '3 × 10; opposite arm and leg.'),
            _s('Side plank', 6, '30s each side × 2.'),
            _s('Bird dog', 5, 'Opposite reach; stable pelvis.'),
            _s('Diaphragmatic breathing', 3, 'Supine, hands on ribs.'),
          ],
        ),
        LibraryTrainingPlan(
          name: 'Core endurance plus',
          level: 'Intermediate',
          totalMinutes: 26,
          steps: <LibraryTrainingStep>[
            _s('Plank', 6, '3 × 40–60s.'),
            _s('Mountain climber', 8, '3 × 20; keep hips level.'),
            _s('Russian twist', 6, 'Optional weight; feet may stay down.'),
            _s('Stretch', 6, 'Abs and QL.'),
          ],
        ),
      ];
    case 'Upper-body strength':
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: 'Push day · Chest, shoulders, triceps',
          level: 'Intermediate',
          totalMinutes: 32,
          steps: <LibraryTrainingStep>[
            _s('Shoulder circles', 4, 'Wake up rotator cuff.'),
            _s('Push-up / machine press', 12, '4 × 8–12.'),
            _s('Dumbbell press', 10, '3 × 10; brace core.'),
            _s('Rope push-down / close push-up', 8,
                'Triceps 3 sets, leave 2 reps in reserve.'),
            _s('Chest & shoulder stretch', 4, 'Doorway or towel assist.'),
          ],
        ),
        LibraryTrainingPlan(
          name: 'Pull day · Back & biceps',
          level: 'Intermediate',
          totalMinutes: 30,
          steps: <LibraryTrainingStep>[
            _s('Band row warm-up', 4, 'Squeeze shoulder blades.'),
            _s('One-arm dumbbell row', 12, '3 × 10 each side.'),
            _s('Reverse fly', 8, 'Rear delts 3 × 12.'),
            _s('Hammer curl', 6, '2 × 12.'),
            _s('Lat stretch', 4, 'Hang or lean from bar.'),
          ],
        ),
      ];
    case 'Full-body stretch':
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: 'Desk neck & back relief',
          level: 'Beginner',
          totalMinutes: 16,
          steps: <LibraryTrainingStep>[
            _s('Thoracic rotation', 4, 'Side-lying, top arm opens.'),
            _s('SCM stretch', 3, 'Side bend neck, light opposite hand.'),
            _s('Seated spinal twist', 4, '30s each side.'),
            _s('Standing side bend', 3, 'Lengthen side waist.'),
            _s('Wrist flex/extend', 2, '5 reps each direction.'),
          ],
        ),
        LibraryTrainingPlan(
          name: 'Lower-body chain stretch',
          level: 'Beginner',
          totalMinutes: 14,
          steps: <LibraryTrainingStep>[
            _s('Standing hamstring stretch', 5, 'Flex foot; neutral pelvis.'),
            _s('Wall calf stretch', 4, 'Back heel down.'),
            _s('Butterfly', 5, 'Knees toward floor, tall spine.'),
          ],
        ),
      ];
    default:
      return <LibraryTrainingPlan>[
        LibraryTrainingPlan(
          name: '$categoryTitle · Basics',
          level: 'Beginner',
          totalMinutes: 20,
          steps: <LibraryTrainingStep>[
            _s('Warm-up', 5, 'Full-body joints and light cardio.'),
            _s('Main block', 10, 'Pick 2–3 moves for today’s goal.'),
            _s('Cool-down stretch', 5, 'Major muscle groups, static holds.'),
          ],
        ),
      ];
  }
}
