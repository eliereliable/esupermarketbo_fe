import 'dart:ui';

import 'package:esupermarketbo_fe/ThemeManager/theme_mnager.dart';
import 'package:esupermarketbo_fe/ThemeManager/theme_type.dart';
import 'package:flutter/material.dart';


class CommonThemeType implements ThemeTypes {
  static final CommonThemeType _instance = CommonThemeType._internal();

  factory CommonThemeType() {
    return _instance;
  }

  CommonThemeType._internal();
  @override
  Color? getColorKey(ColorKey colorKey, ThemeType themeMode) {
    return getNonOptionalColorForKey(colorKey, themeMode);
  }

  @override
  ThemeData? getThemeData(ThemeType themeType, ThemeData? defaultThemeData) {
    return getNonOptionalThemeData(themeType, defaultThemeData);
  }

  Color getNonOptionalColorForKey(ColorKey colorKey, ThemeType themeMode) {
    switch (colorKey) {
      case ColorKey.PrimaryColor2:
        return Color(0xff19DFD3);
      case ColorKey.LoginColor2:
        return Color(0xff19DFD3);
      case ColorKey.PrimaryColor:
      case ColorKey.CustomButtonBlue:
        return Color(0xFF1E65DE);
      case ColorKey.CustomButtonGreen:
        return Color(0xFF12F6BB);
      case ColorKey.White:
        return Color(0xffffffff);
      case ColorKey.backgroundColor:
        return Color(0xFFf4F6F9);
      case ColorKey.fieldBorder:
        return Color(0xFFACC6F3);
      case ColorKey.black:
        return Color(0xFF030944);
      case ColorKey.BorderLoginColor:
        return Color(0xffD9D9D9);
      case ColorKey.BackgroundSnackBarSecondary:
        return Color(0xffEBB5A3);
      case ColorKey.BackgroundSnackBarPrimary:
      case ColorKey.ErrorColor:
        return Color(0xffD74F21);
      case ColorKey.greyColor:
        return Color(0xffCDD7E5);
      case ColorKey.uploadIdBackground:
        return Color(0xff030944);
      case ColorKey.orange:
        return Color(0xffF09712);
      case ColorKey.filter:
        return Color(0xffEBF5FB);
      case ColorKey.DividerColor:
        return Color(0xffDEE2E7);
      case ColorKey.redColor:
        return Color(0xffFF5015);
    }
  }

  ThemeData getNonOptionalThemeData(
      ThemeType themeMode, ThemeData? defaultThemeData) {
    return ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: getColorKey(
              ColorKey.PrimaryColor, themeMode), // Set your desired color here
        ),
        scaffoldBackgroundColor: getColorKey(ColorKey.White, themeMode),
        useMaterial3: true,
        primaryColor: getColorKey(ColorKey.White, themeMode),
        appBarTheme: AppBarTheme(
          backgroundColor: getColorKey(ColorKey.White, themeMode),
          surfaceTintColor: getColorKey(ColorKey.White, themeMode),
          centerTitle: true,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: getColorKey(
                ColorKey.PrimaryColor, themeMode), // Set desired color
          ),
        ),
        indicatorColor: getColorKey(ColorKey.PrimaryColor, themeMode),
        inputDecorationTheme: InputDecorationTheme(
            focusColor: getColorKey(ColorKey.PrimaryColor, themeMode)));
  }
}
