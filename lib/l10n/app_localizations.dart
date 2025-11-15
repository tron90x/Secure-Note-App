import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_kab.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('kab')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Note App'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your private thoughts, securely stored.'**
  String get appSubtitle;

  /// No description provided for @applicationError.
  ///
  /// In en, this message translates to:
  /// **'Application Error'**
  String get applicationError;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unknown error has occurred.\nThe application needs to be closed.'**
  String get unknownErrorOccurred;

  /// No description provided for @closeApplication.
  ///
  /// In en, this message translates to:
  /// **'Close Application'**
  String get closeApplication;

  /// No description provided for @chooseStorageMode.
  ///
  /// In en, this message translates to:
  /// **'Choose your storage mode:'**
  String get chooseStorageMode;

  /// No description provided for @useNativeSecureStorage.
  ///
  /// In en, this message translates to:
  /// **'Use Native Secure Storage'**
  String get useNativeSecureStorage;

  /// No description provided for @useRustDatabase.
  ///
  /// In en, this message translates to:
  /// **'Use Rust Database'**
  String get useRustDatabase;

  /// No description provided for @nativeStorageConfigured.
  ///
  /// In en, this message translates to:
  /// **'Native storage is configured.'**
  String get nativeStorageConfigured;

  /// No description provided for @nativeStorageNeedsSetup.
  ///
  /// In en, this message translates to:
  /// **'Native storage needs setup.'**
  String get nativeStorageNeedsSetup;

  /// No description provided for @unlockNativeStorage.
  ///
  /// In en, this message translates to:
  /// **'Unlock Native Storage'**
  String get unlockNativeStorage;

  /// No description provided for @enterPasswordNativeStorage.
  ///
  /// In en, this message translates to:
  /// **'Enter password for native storage:'**
  String get enterPasswordNativeStorage;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password.'**
  String get invalidPassword;

  /// No description provided for @failedToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlock: {error}'**
  String failedToUnlock(Object error);

  /// No description provided for @nativeCategories.
  ///
  /// In en, this message translates to:
  /// **'Native Categories'**
  String get nativeCategories;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Search notes...'**
  String get searchNotes;

  /// No description provided for @enterSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Enter a search term'**
  String get enterSearchTerm;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noNativeCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No native categories yet.'**
  String get noNativeCategoriesYet;

  /// No description provided for @createNewNativeCategory.
  ///
  /// In en, this message translates to:
  /// **'Create New Native Category'**
  String get createNewNativeCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @openRustDatabase.
  ///
  /// In en, this message translates to:
  /// **'Open Rust Database'**
  String get openRustDatabase;

  /// No description provided for @selectRustDatabaseFiles.
  ///
  /// In en, this message translates to:
  /// **'Select your Rust application\'s database file and validation file, then enter the password.'**
  String get selectRustDatabaseFiles;

  /// No description provided for @step1SelectDatabaseFile.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Select Database File (.sqlite)'**
  String get step1SelectDatabaseFile;

  /// No description provided for @browseForSQLiteFile.
  ///
  /// In en, this message translates to:
  /// **'Browse for SQLite File'**
  String get browseForSQLiteFile;

  /// No description provided for @step2SelectValidationFile.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Select Validation File (.dat)'**
  String get step2SelectValidationFile;

  /// No description provided for @browseForValidationFile.
  ///
  /// In en, this message translates to:
  /// **'Browse for validation.dat'**
  String get browseForValidationFile;

  /// No description provided for @step3EnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Enter Password'**
  String get step3EnterPassword;

  /// No description provided for @enterDatabasePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your database password'**
  String get enterDatabasePassword;

  /// No description provided for @openDatabase.
  ///
  /// In en, this message translates to:
  /// **'Open Database'**
  String get openDatabase;

  /// No description provided for @selectRustDatabaseFile.
  ///
  /// In en, this message translates to:
  /// **'Please select the Rust SQLite database file.'**
  String get selectRustDatabaseFile;

  /// No description provided for @selectValidationFile.
  ///
  /// In en, this message translates to:
  /// **'Please select the validation.dat file.'**
  String get selectValidationFile;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter the password.'**
  String get enterPassword;

  /// No description provided for @validatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Validating password...'**
  String get validatingPassword;

  /// No description provided for @passwordValidated.
  ///
  /// In en, this message translates to:
  /// **'Password validated! Opening database...'**
  String get passwordValidated;

  /// No description provided for @passwordValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Password validation failed. Incorrect password or corrupted validation file.'**
  String get passwordValidationFailed;

  /// No description provided for @failedToOpenRustDb.
  ///
  /// In en, this message translates to:
  /// **'Failed to open Rust DB with service: {error}'**
  String failedToOpenRustDb(Object error);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @kabyle.
  ///
  /// In en, this message translates to:
  /// **'Taqbaylit'**
  String get kabyle;

  /// No description provided for @nativeOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Native Secure Storage Options'**
  String get nativeOptionsTitle;

  /// No description provided for @createOrOpenDefaultDatabase.
  ///
  /// In en, this message translates to:
  /// **'Create or Open Default Database'**
  String get createOrOpenDefaultDatabase;

  /// No description provided for @openExistingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Open Existing Database'**
  String get openExistingDatabase;

  /// No description provided for @createNewDatabase.
  ///
  /// In en, this message translates to:
  /// **'Create New Database'**
  String get createNewDatabase;

  /// No description provided for @selectedDirMissingPrefs.
  ///
  /// In en, this message translates to:
  /// **'Selected directory does not contain shared_preferences.json'**
  String get selectedDirMissingPrefs;

  /// No description provided for @noDbFileFound.
  ///
  /// In en, this message translates to:
  /// **'No database file (.db) found in the selected directory'**
  String get noDbFileFound;

  /// No description provided for @databaseCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Database Created'**
  String get databaseCreatedTitle;

  /// No description provided for @openNewDatabaseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to open the newly created database?'**
  String get openNewDatabaseQuestion;

  /// No description provided for @openDatabaseAction.
  ///
  /// In en, this message translates to:
  /// **'Open Database'**
  String get openDatabaseAction;

  /// No description provided for @backToOptions.
  ///
  /// In en, this message translates to:
  /// **'Back to Options'**
  String get backToOptions;

  /// No description provided for @createPasswordForCustomDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Password for Custom Database'**
  String get createPasswordForCustomDatabaseTitle;

  /// No description provided for @createSecurePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Secure Password'**
  String get createSecurePasswordTitle;

  /// No description provided for @createPasswordLead.
  ///
  /// In en, this message translates to:
  /// **'Create a password to secure your notes'**
  String get createPasswordLead;

  /// No description provided for @createPasswordLeadCustom.
  ///
  /// In en, this message translates to:
  /// **'Create a password for your new database'**
  String get createPasswordLeadCustom;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @minPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get minPasswordLength;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password created successfully! Please log in.'**
  String get passwordCreatedSuccess;

  /// No description provided for @failedToSetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to set password. Please try again.'**
  String get failedToSetPassword;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String genericError(Object error);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next Month'**
  String get nextMonth;

  /// No description provided for @noNotesForThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No notes for this month'**
  String get noNotesForThisMonth;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @addNoteToCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Note to {category}'**
  String addNoteToCategory(Object category);

  /// No description provided for @noNotesInCategoryForMonth.
  ///
  /// In en, this message translates to:
  /// **'No notes in {category} for {month} {year}.'**
  String noNotesInCategoryForMonth(Object category, Object month, Object year);

  /// No description provided for @addFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Add First Note'**
  String get addFirstNote;

  /// No description provided for @noteInCategory.
  ///
  /// In en, this message translates to:
  /// **'Note in {category}'**
  String noteInCategory(Object category);

  /// No description provided for @addNewNote.
  ///
  /// In en, this message translates to:
  /// **'Add New Note'**
  String get addNewNote;

  /// No description provided for @noteIsEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Note is encrypted'**
  String get noteIsEncrypted;

  /// No description provided for @encryptNote.
  ///
  /// In en, this message translates to:
  /// **'Encrypt note'**
  String get encryptNote;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamed;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @categoryColon.
  ///
  /// In en, this message translates to:
  /// **'Category: {name}'**
  String categoryColon(Object name);

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @titleColor.
  ///
  /// In en, this message translates to:
  /// **'Title Color'**
  String get titleColor;

  /// No description provided for @titleOptional.
  ///
  /// In en, this message translates to:
  /// **'Title (Optional)'**
  String get titleOptional;

  /// No description provided for @enterYourNoteHere.
  ///
  /// In en, this message translates to:
  /// **'Enter your note here...'**
  String get enterYourNoteHere;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'kab'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'kab':
      return AppLocalizationsKab();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
