import 'dart:io';

import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

extension ToSliverBox on Widget {
  SliverToBoxAdapter get toSliverBox => SliverToBoxAdapter(child: this);
  SingleChildScrollView get toSingleChildScrollView =>
      SingleChildScrollView(child: this);
  Widget colorize(Color color) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: this,
    );
  }
}

extension ToAdaptiveBottomPadding on Widget {
  Widget toAdaptiveBottomPadding(BuildContext context, int sdkVersion) {
    bool isAndroid = Platform.isAndroid;

    if (isAndroid) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: sdkVersion >= 35 ? MediaQuery.of(context).padding.bottom : 0,
        ),
        child: this,
      );
    } else {
      return this;
    }
  }
}

extension ToAdaptiveBottomPaddingPermanent on Widget {
  Widget toAdaptiveBottomPaddingPermanent(BuildContext context) {
    bool isAndroid = Platform.isAndroid;

    if (isAndroid) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: this,
      );
    } else {
      return this;
    }
  }
}

extension ToSafeAreaBottomPadding on Widget {
  Widget get toSafeAreaBottomPadding =>
      SafeArea(minimum: const EdgeInsets.only(bottom: 16.0), child: this);
}

extension IosUpgrader on Widget {
  Widget toIosUpgrader() {
    return Platform.isIOS
        ? UpgradeAlert(
            dialogStyle: UpgradeDialogStyle.cupertino,
            barrierDismissible: false,
            upgrader: Upgrader(
              languageCode: 'en',
              durationUntilAlertAgain: const Duration(minutes: 2),
              debugLogging: false,
            ),
            child: this,
          )
        : this;
  }
}

extension NumExtensions on num {
  EdgeInsets get topPad => EdgeInsets.only(top: toDouble());
  EdgeInsets get bottomPad => EdgeInsets.only(bottom: toDouble());
  EdgeInsets get rightPad => EdgeInsets.only(right: toDouble());
  EdgeInsets get leftPad => EdgeInsets.only(left: toDouble());
  EdgeInsets get verticPad => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get horizPad => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get allPad => EdgeInsets.all(toDouble());
  //!
  BorderRadius get circleBorder => BorderRadius.circular(toDouble());
  Radius get cirleOnlyBorder => Radius.circular(toDouble());
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension StringColorExtension on String {
  Color get asHexColor {
    final hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
