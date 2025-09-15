
import 'package:esupermarketbo_fe/ThemeManager/common_theme_type.dart';
import 'package:flutter/material.dart';


enum ThemeType {
  LightMode,
  DarkMode;

  bool isDarkMode() {
    return this == ThemeType.DarkMode;
  }
}

enum ColorKey {
  LoginColor2,
  PrimaryColor,
  CustomButtonBlue,
  CustomButtonGreen,
 White,
 backgroundColor,
 fieldBorder,
 orange,
 black,
 PrimaryColor2,
 BorderLoginColor,
 BackgroundSnackBarPrimary,
 BackgroundSnackBarSecondary,
 greyColor,
 uploadIdBackground,
 ErrorColor,
 redColor,
 DividerColor,
 filter
}

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  ThemeType _themeMode = ThemeType.LightMode;

  factory ThemeManager() {
    return _instance;
  }

  ThemeManager._internal();

  void configure(ThemeType themeMode) {
    this._themeMode = themeMode;
  }

  Color getColor(ColorKey colorKey) {
    return this
        ._prepareCommonService()
        .getNonOptionalColorForKey(colorKey, this._themeMode);
  }

  ThemeData getThemeData(ThemeType? themeType, ThemeData? defaultThemeData) {
    return this
        ._prepareCommonService()
        .getNonOptionalThemeData(themeType ?? _themeMode, defaultThemeData);
  }

  CommonThemeType _prepareCommonService() {
    return CommonThemeType();
  }
}
