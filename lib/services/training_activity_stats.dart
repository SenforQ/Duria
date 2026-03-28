import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingActivitySource {
  TrainingActivitySource._();

  static const String myPlan = 'my_plan';
  static const String dailyCheckin = 'daily_checkin';
  static const String todaySport = 'today_sport';
  static const String recommendedCourse = 'recommended_course';
}

class TrainingActivityStatsController extends ChangeNotifier {
  TrainingActivityStatsController._();

  static final TrainingActivityStatsController instance =
      TrainingActivityStatsController._();

  void notifyStatsChanged() => notifyListeners();
}

class TrainingWeekAggregate {
  const TrainingWeekAggregate({
    required this.sessionCount,
    required this.totalMinutes,
    required this.totalKcal,
    required this.minutesByDayIndex,
    required this.daysWithActivityWeekday,
    required this.checkInStreakDays,
    required this.prevWeekMinutes,
  });

  static const TrainingWeekAggregate empty = TrainingWeekAggregate(
    sessionCount: 0,
    totalMinutes: 0,
    totalKcal: 0,
    minutesByDayIndex: <int>[0, 0, 0, 0, 0, 0, 0],
    daysWithActivityWeekday: <int>{},
    checkInStreakDays: 0,
    prevWeekMinutes: 0,
  );

  final int sessionCount;
  final int totalMinutes;
  final int totalKcal;
  final List<int> minutesByDayIndex;
  final Set<int> daysWithActivityWeekday;
  final int checkInStreakDays;
  final int prevWeekMinutes;

  String get weekOverWeekLabel {
    if (prevWeekMinutes <= 0) {
      if (totalMinutes <= 0) {
        return '0%';
      }
      return 'New cycle';
    }
    final pct =
        ((totalMinutes - prevWeekMinutes) / prevWeekMinutes * 100).round();
    final sign = pct >= 0 ? '+' : '';
    return '$sign$pct%';
  }
}

class TrainingActivityStatsService {
  static const String _kLog = 'duria_training_activity_log_v1';

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _weekStartMonday(DateTime now) {
    final d = DateTime(now.year, now.month, now.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static int kcalForMinutes(int minutes) =>
      (minutes * 5).clamp(0, 1 << 20).toInt();

  static Future<List<Map<String, dynamic>>> _readLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLog);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> _writeLog(List<Map<String, dynamic>> log) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLog, jsonEncode(log));
  }

  static Future<void> recordSession({
    required int minutes,
    required String source,
    DateTime? at,
  }) async {
    if (minutes <= 0) {
      return;
    }
    final when = at ?? DateTime.now();
    final log = await _readLog();
    log.add(<String, dynamic>{
      'date': _dateKey(when),
      'minutes': minutes,
      'kcal': kcalForMinutes(minutes),
      'source': source,
      'ts': when.millisecondsSinceEpoch,
    });
    if (log.length > 500) {
      log.removeRange(0, log.length - 500);
    }
    await _writeLog(log);
    TrainingActivityStatsController.instance.notifyStatsChanged();
  }

  static Future<void> recordTodaySportDayIfNeeded({
    required int minutes,
  }) async {
    if (minutes <= 0) {
      return;
    }
    final today = _dateKey(DateTime.now());
    final log = await _readLog();
    final exists = log.any(
      (Map<String, dynamic> e) =>
          e['source'] == TrainingActivitySource.todaySport &&
          e['date'] == today,
    );
    if (exists) {
      return;
    }
    await recordSession(
      minutes: minutes,
      source: TrainingActivitySource.todaySport,
    );
  }

  static Future<int> loadCheckInStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_checkin_streak') ?? 0;
  }

  static Future<TrainingWeekAggregate> loadWeekAggregate(DateTime now) async {
    final log = await _readLog();
    final streak = await loadCheckInStreak();
    final weekStart = _weekStartMonday(now);
    final prevWeekStart = weekStart.subtract(const Duration(days: 7));

    final List<int> minutesByDay = List<int>.filled(7, 0);
    final Set<int> weekdays = <int>{};
    var sessionCount = 0;
    var totalMinutes = 0;
    var totalKcal = 0;
    var prevWeekMinutes = 0;

    for (final Map<String, dynamic> e in log) {
      final dateStr = e['date']?.toString() ?? '';
      final m = (e['minutes'] as num?)?.toInt() ?? 0;
      final k = (e['kcal'] as num?)?.toInt() ?? kcalForMinutes(m);
      DateTime? d;
      try {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          d = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (_) {
        d = null;
      }
      if (d == null) {
        continue;
      }

      final dayStart = DateTime(d.year, d.month, d.day);
      if (!dayStart.isBefore(weekStart) &&
          dayStart.isBefore(weekStart.add(const Duration(days: 7)))) {
        sessionCount++;
        totalMinutes += m;
        totalKcal += k;
        final idx = dayStart.difference(weekStart).inDays;
        if (idx >= 0 && idx < 7) {
          minutesByDay[idx] += m;
          weekdays.add(dayStart.weekday);
        }
      }
      if (!dayStart.isBefore(prevWeekStart) && dayStart.isBefore(weekStart)) {
        prevWeekMinutes += m;
      }
    }

    return TrainingWeekAggregate(
      sessionCount: sessionCount,
      totalMinutes: totalMinutes,
      totalKcal: totalKcal,
      minutesByDayIndex: List<int>.from(minutesByDay),
      daysWithActivityWeekday: Set<int>.from(weekdays),
      checkInStreakDays: streak,
      prevWeekMinutes: prevWeekMinutes,
    );
  }
}
