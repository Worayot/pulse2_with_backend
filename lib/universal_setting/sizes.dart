import 'package:flutter/material.dart';

Size getScreenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double getPageTitleSize(BuildContext context) {
  // return MediaQuery.of(context).size.width / 18.5;
  return 22;
}

class SearchBarSetting {
  final BuildContext context;

  SearchBarSetting({required this.context});

  Size getSize() {
    return MediaQuery.of(context).size;
  }

  double getHeight() {
    return MediaQuery.of(context).size.height * 0.065;
  }

  double horizontalPadding() {
    return 10;
  }

  double verticalPadding() {
    return 15;
  }
}

class ButtonNextToSearchBarSetting {
  final BuildContext context;

  ButtonNextToSearchBarSetting({required this.context});

  double verticalPadding() {
    return MediaQuery.of(context).size.height * 0.016;
  }
}

class TextWidgetSize {
  final BuildContext context;

  TextWidgetSize({required this.context});

  double getDialogTitleSize() {
    return MediaQuery.of(context).size.width * 0.045;
  }

  double getInfoBoxTextSize() {
    return MediaQuery.of(context).size.width * 0.038;
  }
}
