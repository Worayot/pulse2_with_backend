import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuh_mews/authentication/login/screen/login.dart';
import 'package:tuh_mews/mainpage/navigation.dart';
import 'package:tuh_mews/state/authentication_state/authentication_state.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: ref.read(authenticationProvider).isAuthenticated(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isAuthenticated = snapshot.data!;

        if (isAuthenticated) {
          return const NavigationPage();
        }

        return const LoginPage();
      },
    );
  }
}
