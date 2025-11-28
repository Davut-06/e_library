import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();
  static const Color primary = Color(0xff5D87FF);
  static const Color primarySecondary = Color(0xffECF2FF);
  static const Color primaryTertiary = Color(0xff4570EA);
  static const Color secondary = Color(0xff49BEFF);
  static const Color secondary2 = Color(0xffE8F7FF);
  static const Color secondary3 = Color(0xff34A1DE);
  static const Color backgroundColor = Colors.white;
  static const Color action = Color(0xff13DEB9);
  static const Color actionSecondary = Color(0xffFFAE1F);
  static const Color actionTertiary = Color(0xffFA896B);
  static const Color textPrimary = Color(0xff2A3547);
  static const Color textSecondary = Color(0xff5A6A85);
  static const Color lightGray = Color(0xffDFE5EF);
  static const Color lightBlue = Color(0xffF4F8FF);
  static const Color blueGreyMedium = Color(0xff7C8FAC);
  static const Color blueGrey = Color(0xffC8D7F1);
  static const Color secondaryBg = Color(0xffF5F6FA);
}

@immutable
class AppDarkColors {
  const AppDarkColors._();
  static const Color primary = Colors.white;
  static const Color backgroundColor = Color(0xff0E1F4C);
}

Color gradeTextColor(int? value) {
  if (value == null) {
    return AppColors.lightBlue;
  } else if (value <= 100 && value >= 85) {
    return const Color(0xff13DEB9);
  } else if (value <= 85 && value >= 70) {
    return const Color(0xff5D87FF);
  } else if (value < 70 && value >= 50) {
    return const Color(0xffFFAE1F);
  } else {
    return const Color(0xffFA896B);
  }
}

Color gradeColor(int? value) {
  if (value == null) {
    return AppColors.lightBlue;
  } else if (value <= 100 && value >= 85) {
    return const Color(0xffE6FFFA);
  } else if (value <= 85 && value >= 70) {
    return const Color(0xffF2F6FA);
  } else if (value < 70 && value >= 50) {
    return const Color(0xffFEF5E5);
  } else {
    return const Color(0xffFBF2EF);
  }
}
