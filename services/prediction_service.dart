import '../models/daily_record_model.dart';
import '../models/prediction_model.dart';
import '../models/user_model.dart';
import '../models/weekly_stats_model.dart';
import 'api_service.dart';

class PredictionService {
  static Future<PredictionModel> predict(
      DailyInputModel input,
      UserModel user,
      ) async {
    final data = await ApiService.post('/predict', input.toJson(user));
    return PredictionModel.fromJson(data);
  }

  static Future<List<DailyRecordModel>> getLast7Days(int studentId) async {
    final data = await ApiService.get('/history/$studentId');
    return (data as List)
        .map((e) => DailyRecordModel.fromJson(e))
        .toList();
  }

  // 🔥 YENİ: Haftalık istatistikleri tek çağrıyla getir
  static Future<WeeklyStatsModel> getWeeklyStats(int studentId) async {
    final data = await ApiService.get('/weekly/$studentId');
    return WeeklyStatsModel.fromJson(data);
  }
}