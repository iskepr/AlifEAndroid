// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Taif IDE`
  String get title {
    return Intl.message('Taif IDE', name: 'title', desc: '', args: []);
  }

  /// `Terminal`
  String get terminal {
    return Intl.message('Terminal', name: 'terminal', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `New File`
  String get newFile {
    return Intl.message('New File', name: 'newFile', desc: '', args: []);
  }

  /// `Open File`
  String get openFile {
    return Intl.message('Open File', name: 'openFile', desc: '', args: []);
  }

  /// `Delete File`
  String get deleteFile {
    return Intl.message('Delete File', name: 'deleteFile', desc: '', args: []);
  }

  /// `Are you sure?`
  String get areYouSure {
    return Intl.message(
      'Are you sure?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Save As`
  String get save_as {
    return Intl.message('Save As', name: 'save_as', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Font Size`
  String get fontSize {
    return Intl.message('Font Size', name: 'fontSize', desc: '', args: []);
  }

  /// `Auto Save`
  String get autoSave {
    return Intl.message('Auto Save', name: 'autoSave', desc: '', args: []);
  }

  /// `Edit File`
  String get editFile {
    return Intl.message('Edit File', name: 'editFile', desc: '', args: []);
  }

  /// `No Path`
  String get noPath {
    return Intl.message('No Path', name: 'noPath', desc: '', args: []);
  }

  /// `File Name`
  String get fileName {
    return Intl.message('File Name', name: 'fileName', desc: '', args: []);
  }

  /// `Enter Command`
  String get enterCommand {
    return Intl.message(
      'Enter Command',
      name: 'enterCommand',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Replace With`
  String get replaceWith {
    return Intl.message(
      'Replace With',
      name: 'replaceWith',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Warning`
  String get warning {
    return Intl.message('Warning', name: 'warning', desc: '', args: []);
  }

  /// `Success`
  String get success {
    return Intl.message('Success', name: 'success', desc: '', args: []);
  }

  /// `Info`
  String get info {
    return Intl.message('Info', name: 'info', desc: '', args: []);
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `For Read Only`
  String get forReadOnly {
    return Intl.message(
      'For Read Only',
      name: 'forReadOnly',
      desc: '',
      args: [],
    );
  }

  /// `For Write`
  String get forWrite {
    return Intl.message('For Write', name: 'forWrite', desc: '', args: []);
  }

  /// `Successfully installed Alif version`
  String get successInstallAlifVersion {
    return Intl.message(
      'Successfully installed Alif version',
      name: 'successInstallAlifVersion',
      desc: '',
      args: [],
    );
  }

  /// `Successfully updated Alif from version`
  String get successUpdateAlifVersionFrom {
    return Intl.message(
      'Successfully updated Alif from version',
      name: 'successUpdateAlifVersionFrom',
      desc: '',
      args: [],
    );
  }

  /// `to`
  String get to {
    return Intl.message('to', name: 'to', desc: '', args: []);
  }

  /// `Alif Language Core v5`
  String get alifLangCore {
    return Intl.message(
      'Alif Language Core v5',
      name: 'alifLangCore',
      desc: '',
      args: [],
    );
  }

  /// `Taif IDE Version`
  String get ideVersion {
    return Intl.message(
      'Taif IDE Version',
      name: 'ideVersion',
      desc: '',
      args: [],
    );
  }

  /// `Beta`
  String get beta {
    return Intl.message('Beta', name: 'beta', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
