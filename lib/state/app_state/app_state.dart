import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state.freezed.dart';
part 'app_state.g.dart';

class LocaleConverter implements JsonConverter<Locale, String> {
  const LocaleConverter();

  @override
  Locale fromJson(String json) {
    // Handle locale format like "en", "en_US"
    final parts = json.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  @override
  String toJson(Locale object) {
    return object.countryCode != null && object.countryCode!.isNotEmpty ? '${object.languageCode}_${object.countryCode}' : object.languageCode;
  }
}

//! Maybe unused
@freezed
abstract class AppState with _$AppState {
  const factory AppState({String? username, @LocaleConverter() required Locale locale, @JsonKey(includeFromJson: false) String? sessionCookie, required bool rememberMe}) =
      _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);
}
