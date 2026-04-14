import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static Future<UserModel> login(String email, String password) async {
    final data = await ApiService.post('/auth/login', {
      'email':    email,
      'password': password,
    });
    return UserModel.fromJson(data);
  }

  static Future<UserModel> register({
    required String email,
    required String password,
    required int    age,
    required String gender,
    required String academicLevel,
    required int    partTimeJob,
  }) async {
    final data = await ApiService.post('/auth/register', {
      'email':          email,
      'password':       password,
      'age':            age,
      'gender':         gender,
      'academic_level': academicLevel,
      'part_time_job':  partTimeJob,
    });
    return UserModel.fromJson(data);
  }
}