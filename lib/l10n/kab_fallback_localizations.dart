import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Provides Material localizations for the 'kab' locale by delegating
/// to a fallback locale (French by default).
class KabMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const KabMaterialLocalizationsDelegate({this.fallback = const Locale('fr')});

  final Locale fallback;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'kab';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    // Load the fallback localization for Material widgets
    return GlobalMaterialLocalizations.delegate.load(fallback);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

/// Provides Cupertino localizations for the 'kab' locale by delegating
/// to a fallback locale (French by default).
class KabCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const KabCupertinoLocalizationsDelegate({this.fallback = const Locale('fr')});

  final Locale fallback;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'kab';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    // Load the fallback localization for Cupertino widgets
    return GlobalCupertinoLocalizations.delegate.load(fallback);
  }

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}


