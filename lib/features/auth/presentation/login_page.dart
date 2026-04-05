import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  String _mode = 'login';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    final session = ref.watch(sessionControllerProvider);
    final isLoading = session.isLoading;
    final isRegister = _mode == 'register';

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF2F8FF),
              Color(0xFFE9FFF3),
              Color(0xFFF6F7FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C7BE5).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFF2C7BE5),
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Compre mais rápido, sem atrito.',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Entre com email e senha para testar agora, ou use Google quando sua configuração OAuth estiver pronta.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5A6475),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'login',
                              icon: Icon(Icons.login_rounded),
                              label: Text('Entrar'),
                            ),
                            ButtonSegment(
                              value: 'register',
                              icon: Icon(Icons.person_add_alt_1_rounded),
                              label: Text('Criar conta'),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (value) {
                            setState(() => _mode = value.first);
                          },
                        ),
                        const SizedBox(height: 20),
                        if (isRegister) ...[
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: isRegister
                              ? TextInputAction.next
                              : TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        if (isRegister) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordConfirmationController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar senha',
                              prefixIcon: Icon(Icons.verified_user_outlined),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: isLoading ? null : _submitEmailPassword,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(isRegister
                                  ? Icons.person_add_alt_1_rounded
                                  : Icons.login_rounded),
                          label: Text(isRegister ? 'Criar conta' : 'Entrar'),
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('ou'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => ref
                                  .read(sessionControllerProvider.notifier)
                                  .signInWithGoogle(),
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Text('Entrar com Google'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitEmailPassword() async {
    final controller = ref.read(sessionControllerProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_mode == 'register') {
      await controller.registerWithEmail(
        name: _nameController.text.trim(),
        email: email,
        password: password,
        passwordConfirmation: _passwordConfirmationController.text,
      );
      return;
    }

    await controller.signInWithEmail(email: email, password: password);
  }
}
