import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_state.dart';

part 'app_state_notifier.g.dart';

@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    return const AppState(locale: Locale('en', 'US'), rememberMe: false);
  }

  void updateUsername(String? username) {
    state = state.copyWith(username: username);
  }

  void updateLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  void updateSessionCookie(String? sessionCookie) {
    state = state.copyWith(sessionCookie: sessionCookie);
  }

  void updateRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }
}
