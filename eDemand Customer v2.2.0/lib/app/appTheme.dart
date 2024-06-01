import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

enum AppTheme { dark, light }

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.light: ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightPrimaryColor,
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimaryColor,
    secondaryHeaderColor: AppColors.lightSubHeadingColor1,
    fontFamily: "PlusJakartaSans",
    primarySwatch: AppColors.primarySwatchLightColor,
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.lightAccentColor,
      selectionHandleColor: AppColors.lightAccentColor,

    ),
  ),
  //
  AppTheme.dark: ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimaryColor,
    secondaryHeaderColor: AppColors.darkSubHeadingColor1,
    scaffoldBackgroundColor: AppColors.darkPrimaryColor,
    primarySwatch: AppColors.primarySwatchDarkColor,
    fontFamily: "PlusJakartaSans",
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.darkAccentColor,
      selectionHandleColor: AppColors.darkAccentColor,
    ),
  )
};
