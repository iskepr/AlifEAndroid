// Fonts Family
import "dart:io";

import "package:flutter/material.dart";
import "generated/l10n.dart";

const String kMainFont = "tajawal";
const String kTerminalFont = "noto_kufi";
const Map<String, String> kFonts = {
  kMainFont: "تجوال",
  kTerminalFont: "كوفي",
  "hasubi": "حاسوب",
  "alaq_halab": "حلب",
  "kawkab": "كويكب",
};

// Fonts Size
const double kSoSmallFont = 12;
const double kSmallFont = 14;
const double kMediumFont = 16;
const double kLargeFont = 20;
const double kSoLargeFont = 24;

// Paddings
const double kSmallPadding = 5;
const double kMediumPadding = 10;
const double kLargePadding = 15;
const double kDefaultPadding = 20;

// Border Radius
const double kSoSmallBorderRadius = 15;
const double kSmallBorderRadius = 26;
const double kMediumBorderRadius = 30;
const double kLargeBorderRadius = 50;
const double kCircleBorderRadius = 100;

// Animations Durations & Curves
const Duration kAnimationFasterDuration = Duration(milliseconds: 200);
const Duration kAnimationDuration = Duration(milliseconds: 350);
const Duration kAnimationSlowerDuration = Duration(milliseconds: 500);

const Curve kCurveEaseInOut = Curves.easeInOut;
const Curve kCurveEaseOutBack = Curves.easeOutBack;

// ide
const int kCodeSpaceLength = 4;
final String kCodeSpace = " " * kCodeSpaceLength;

// Hive Boxes
const String kBoxOpenedFiles = "box_opened_files";
const String kBoxSettings = "box_Settings";

// Boxes keys
const String kKeyLastFile = "box_last_file";
const String kKeyAlifVersion = "alif_version";
const String kKeyWorkspacePath = "workspace_path";
const String kKeyBashHistory = "bash_history";

// directories
final String kHomeDir = Platform.isAndroid
    ? "/storage/emulated/0"
    : Platform.isLinux
    ? "${Platform.environment["HOME"]}"
    : "";
const String kAlifBin = "الف";
const String kTempFileName = "مؤقت.الف";
const String kLinkerPath = "/system/bin/linker64";
const String kLibAlifSuffix = "/libalif.so";

// Global Variables
final S l10n = S.current;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Versions
const String kAppVersion = "v1.2.0";
const String kAlifVersion = "v5.3.0";
