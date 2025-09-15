
import 'package:esupermarketbo_fe/ThemeManager/theme_mnager.dart';
import 'package:flutter/material.dart';


abstract class ThemeTypes {
  Color? getColorKey(ColorKey colorKey, ThemeType themeMode);
  ThemeData? getThemeData(ThemeType themeType, ThemeData? defaultThemeData);
}
