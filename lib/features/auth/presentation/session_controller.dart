import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/session_storage.dart';
import '../../../shared/models/user_profile.dart';
import '../../lists/presentation/lists_controller.dart';
import '../../products/presentation/products_controller.dart';
import '../data/auth_repository.dart';

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, SessionState>(
      SessionController.new,
    );

class SessionState {
  const SessionState({
    this.token,
    this.user,
  });

  final String? token;
  final UserProfile? user;

  bool get isAuthenticated => token != null && user != null;

  SessionState copyWith({
    String? token,
    UserProfile? user,
  }) {
    return SessionState(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class SessionController extends AsyncNotifier<SessionState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);
  SessionStorage get _storage => ref.read(sessionStorageProvider);

  @override
  Future<SessionState> build() async {
    final token = _storage.readToken();
    if (token == null || token.isEmpty) {
      return const SessionState();
    }

    try {
      final user = await _repository.fetchProfile();
      return SessionState(token: token, user: user);
    } catch (_) {
      await _storage.clear();
      return const SessionState();
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _repository.signInWithGoogle();
      await _storage.saveToken(session.token);
      _invalidateAuthenticatedProviders();
      return SessionState(token: session.token, user: session.user);
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      await _storage.saveToken(session.token);
      _invalidateAuthenticatedProviders();
      return SessionState(token: session.token, user: session.user);
    });
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _repository.registerWithEmail(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await _storage.saveToken(session.token);
      _invalidateAuthenticatedProviders();
      return SessionState(token: session.token, user: session.user);
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
    await _storage.clear();
    _invalidateAuthenticatedProviders();
    state = const AsyncData(SessionState());
  }

  void _invalidateAuthenticatedProviders() {
    ref.invalidate(listsControllerProvider);
    ref.invalidate(productsControllerProvider);
  }
}
