import 'daily_record_model.dart';

class WeeklyStatsModel {
  final List<DailyRecordModel> records;
  final double avgScore;
  final double avgProductivity;
  final double avgFocus;
  final int    highBurnoutDays;
  final double scoreTrend;        // pozitif = yükseliş, negatif = düşüş
  final String mostCommonBurnout;

  const WeeklyStatsModel({
    required this.records,
    required this.avgScore,
    required this.avgProductivity,
    required this.avgFocus,
    required this.highBurnoutDays,
    required this.scoreTrend,
    required this.mostCommonBurnout,
  });

  factory WeeklyStatsModel.fromJson(Map<String, dynamic> json) => WeeklyStatsModel(
    records: (json['records'] as List)
        .map((e) => DailyRecordModel.fromJson(e))
        .toList(),
    avgScore:           (json['avg_score']         as num).toDouble(),
    avgProductivity:    (json['avg_productivity']  as num).toDouble(),
    avgFocus:           (json['avg_focus']         as num).toDouble(),
    highBurnoutDays:     json['high_burnout_days'] as int,
    scoreTrend:         (json['score_trend']       as num).toDouble(),
    mostCommonBurnout:   json['most_common_burnout'],
  );
}