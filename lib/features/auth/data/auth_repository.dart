import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/user_profile.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  final clientId = AppConfig.googleServerClientId.isEmpty
      ? null
      : AppConfig.googleServerClientId;

  return GoogleSignIn(
    scopes: const ['email'],
    clientId: kIsWeb ? clientId : null,
    serverClientId: kIsWeb ? null : clientId,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(googleSignInProvider),
  );
});

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final UserProfile user;
}

class AuthRepository {
  AuthRepository(this._dio, this._googleSignIn);

  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  Future<AuthSession> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google idToken not available');
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'id_token': idToken},
      );

      final data = response.data ?? const {};
      return AuthSession(
        token: data['token'] as String,
        user: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      throw Exception(_readApiError(error));
    }
  }

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data ?? const {};
      return AuthSession(
        token: data['token'] as String,
        user: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      throw Exception(_readApiError(error));
    }
  }

  Future<AuthSession> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data ?? const {};
      return AuthSession(
        token: data['token'] as String,
        user: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      throw Exception(_readApiError(error));
    }
  }

  Future<UserProfile> fetchProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/profile');
    final data = response.data ?? const {};
    return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Session cleanup still happens locally even if the Google client fails.
    }
  }

  String _readApiError(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.join(', ');
      }
    }

    return error.message ?? 'Request failed';
  }
}
