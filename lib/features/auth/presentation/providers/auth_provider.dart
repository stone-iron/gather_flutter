import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/api_client.dart';
import '../../data/auth_repository.dart';
import '../../domain/app_member.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authProvider = NotifierProvider<AuthController, AppMember?>(
  AuthController.new,
);

class AuthController extends Notifier<AppMember?> {
  static const memberKey = 'logged_in_member';

  @override
  AppMember? build() {
    Future.microtask(restoreLogin);
    return null;
  }

  Future<void> restoreLogin() async {
    final storage = ref.read(secureStorageProvider);
    final savedMember = await storage.read(key: memberKey);

    if (savedMember == null || savedMember.isEmpty) {
      return;
    }

    try {
      final json = jsonDecode(savedMember) as Map<String, dynamic>;
      state = AppMember.fromJson(json);
    } catch (_) {
      await storage.delete(key: memberKey);
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final member = await repository.login(
      identifier: identifier,
      password: password,
    );

    final storage = ref.read(secureStorageProvider);

    await storage.write(
      key: memberKey,
      value: jsonEncode(member.toJson()),
    );

    state = member;
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);

    await storage.delete(key: memberKey);
    state = null;
  }
}