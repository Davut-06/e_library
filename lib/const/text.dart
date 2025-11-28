// ignore_for_file: prefer_if_null_operators, unnecessary_null_comparison

import 'package:flutter/material.dart';

import '../utils/colors.dart';

class UIText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? align;
  final BuildContext context;
  final FontWeight? textWeight;
  final TextDirection? textDirection;
  final TextDecoration? textDecoration;
  final int? textLines;
  final TextOverflow? textOverflow;
  const UIText({
    super.key,
    required this.text,
    required this.context,
    this.color,
    this.align = TextAlign.left,
    this.textWeight,
    this.textDirection,
    this.textDecoration,
    this.textLines,
    this.textOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text != null ? text : 'Text here');
  }

  Text get big {
    return Text(
      text != null ? text : 'Text here',
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 34,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get h1 {
    return Text(
      text != null ? text : 'Text here',
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 32,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get h2 {
    return Text(
      maxLines: textLines,
      text != null ? text : 'Text here',
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 28,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get h3 {
    return Text(
      text != null ? text : 'Text here',
      textAlign: align,
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 24,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get h4 {
    return Text(
      text != null ? text : 'Text here',
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 22,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get h5 {
    return Text(
      text != null ? text : 'Text here',
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 20,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get t1 {
    return Text(
      text != null ? text : 'Text here',
      textAlign: align,
      maxLines: textLines,
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 18,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get t2 {
    return Text(
      text != null ? text : 'Text here',
      textAlign: align,
      maxLines: textLines,
      overflow: textOverflow,
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 16,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get t3 {
    return Text(
      text != null ? text : 'Text here',
      textDirection: textDirection,
      textAlign: align,
      maxLines: textLines,
      overflow: textOverflow,
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 14,
        color: color == null ? AppColors.textPrimary : color,
        decoration: textDecoration,
      ),
    );
  }

  Text get t4 {
    return Text(
      text != null ? text : 'Text here',
      textDirection: textDirection,
      textAlign: align,
      maxLines: textLines,
      overflow: textOverflow,
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 13,
        color: color == null ? AppColors.textPrimary : color,
        decoration: textDecoration,
      ),
    );
  }

  Text get l1 {
    return Text(
      text != null ? text : 'Text here',
      maxLines: textLines,
      overflow: textOverflow,
      textAlign: align,
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 12,
        color: color == null ? AppColors.textPrimary : color,
        decoration: textDecoration,
      ),
    );
  }

  Text get l2 {
    return Text(
      text != null ? text : 'Text here',
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 11,
        color: color == null ? AppColors.textPrimary : color,
      ),
    );
  }

  Text get s1 {
    return Text(
      text != null ? text : 'Text here',
      textAlign: align,
      style: TextStyle(
        fontWeight: textWeight == null ? FontWeight.w500 : textWeight,
        fontSize: 10,
        color: color == null ? AppColors.textPrimary : color,
        decoration: textDecoration,
      ),
    );
  }
}
