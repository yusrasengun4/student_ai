import 'user_model.dart';

class DailyInputModel {
  final double studyHours;
  final double selfStudyHours;
  final double onlineClassesHours;
  final double sleepHours;
  final double socialMediaHours;
  final double gamingHours;
  final int    exerciseMinutes;
  final int    caffeineIntakeMg;
  final int    mentalHealthScore;
  final String internetQuality;
  final int    upcomingDeadline;

  const DailyInputModel({
    required this.studyHours,
    required this.selfStudyHours,
    required this.onlineClassesHours,
    required this.sleepHours,
    required this.socialMediaHours,
    required this.gamingHours,
    required this.exerciseMinutes,
    required this.caffeineIntakeMg,
    required this.mentalHealthScore,
    required this.internetQuality,
    required this.upcomingDeadline,
  });

  Map<String, dynamic> toJson(UserModel user) => {
    'student_id':            user.id,        // 🔥 kayıt için eklendi
    'age':                   user.age,
    'gender':                user.gender,
    'academic_level':        user.academicLevel,
    'part_time_job':         user.partTimeJob,
    'study_hours':           studyHours,
    'self_study_hours':      selfStudyHours,
    'online_classes_hours':  onlineClassesHours,
    'sleep_hours':           sleepHours,
    'social_media_hours':    socialMediaHours,
    'gaming_hours':          gamingHours,
    'exercise_minutes':      exerciseMinutes,
    'caffeine_intake_mg':    caffeineIntakeMg,
    'mental_health_score':   mentalHealthScore,
    'internet_quality':      internetQuality,
    'upcoming_deadline':     upcomingDeadline,
  };
}

class DailyRecordModel {
  final String date;
  final double predictedScore;
  final String burnoutRisk;
  final double productivityScore;
  final double focusIndex;

  const DailyRecordModel({
    required this.date,
    required this.predictedScore,
    required this.burnoutRisk,
    required this.productivityScore,
    required this.focusIndex,
  });

  factory DailyRecordModel.fromJson(Map<String, dynamic> json) => DailyRecordModel(
    date:              json['date'],
    predictedScore:    (json['predicted_score']    as num).toDouble(),
    burnoutRisk:        json['burnout_risk'],
    productivityScore: (json['productivity_score'] as num).toDouble(),
    focusIndex:        (json['focus_index']        as num).toDouble(),
  );
}