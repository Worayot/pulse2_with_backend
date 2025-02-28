import 'package:easy_localization/easy_localization.dart';

String timeDeltaFromNow({required DateTime dateTime}) {
  Duration difference = DateTime.now().difference(dateTime);

  // If the dateTime is in the future
  if (difference.isNegative) {
    difference =
        difference.abs(); // Make the duration positive for future timestamps
    if (difference.inDays > 0) {
      return '${'in'.tr()} ${difference.inDays} ${'day(s)'.tr()}';
    } else if (difference.inHours > 0) {
      return '${'in'.tr()} ${difference.inHours} ${'hour(s)'.tr()}';
    } else if (difference.inMinutes > 0) {
      return '${'in'.tr()} ${difference.inMinutes} ${'minute(s)'.tr()}';
    } else if (difference.inSeconds > 0) {
      return '${'in'.tr()} ${difference.inSeconds} ${'second(s)'.tr()}';
    } else {
      return '${'in'.tr()} ${'theFuture'.tr()}';
    }
  }

  // If the dateTime is in the past
  if (difference.inDays > 0) {
    return '${difference.inDays} ${'day(s)'.tr()} ${'ago'.tr()}';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${'hour(s)'.tr()} ${'ago'.tr()}';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} ${'minute(s)'.tr()} ${'ago'.tr()}';
  } else if (difference.inSeconds > 0) {
    return '${difference.inSeconds} ${'second(s)'.tr()} ${'ago'.tr()}';
  } else {
    return 'now'.tr();
  }
}

bool isBeforeNow({required DateTime dateTime}) {
  return dateTime.isBefore(DateTime.now());
}
