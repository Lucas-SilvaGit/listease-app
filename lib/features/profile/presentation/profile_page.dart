import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/navigation_frame.dart';
import '../../auth/presentation/session_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final user = session.valueOrNull?.user;

    return NavigationFrame(
      title: 'Perfil',
      currentLocation: '/profile',
      child: session.when(
        data: (_) {
          if (user == null) {
            return const Center(child: Text('Sessão indisponível.'));
          }

          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundImage: user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!),
                        child: user.avatarUrl == null
                            ? Text(user.name.isEmpty ? '?' : user.name.substring(0, 1))
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Color(0xFF697284)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configurações',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Compartilhamento e histórico de preços podem entrar nas próximas versões. Neste MVP o foco é velocidade total para registrar a compra.',
                        style: TextStyle(color: Color(0xFF697284), height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.tonal(
                        onPressed: () => ref.read(sessionControllerProvider.notifier).signOut(),
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
