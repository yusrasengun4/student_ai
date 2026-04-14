import 'package:http/http.dart';

import '../models/user_model.dart';
import 'api_service.dart';

class ProfileService {
  static Future<void> update({
    required int    studentId,
    required int    age,
    required String gender,
    required String academicLevel,
    required int    partTimeJob,
  }) async {
    await ApiService.put('/profile/$studentId', {
      'age':            age,
      'gender':         gender,
      'academic_level': academicLevel,
      'part_time_job':  partTimeJob,
    });
  }
}