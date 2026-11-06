import 'package:dio/dio.dart';

import '../domain/app_member.dart';

class AuthRepository {
  final Dio dio;

  const AuthRepository(this.dio);

  Future<AppMember> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/api/members/login',
        data: {'identifier': identifier, 'password': password},
      );

      return AppMember.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw AuthException(data['message'].toString());
      }

      throw const AuthException('로그인 서버에 연결할 수 없습니다.');
    }
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
