// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Secure Note App';

  @override
  String get appSubtitle => 'Your private thoughts, securely stored.';

  @override
  String get applicationError => 'Application Error';

  @override
  String get unknownErrorOccurred =>
      'An unknown error has occurred.\nThe application needs to be closed.';

  @override
  String get closeApplication => 'Close Application';

  @override
  String get chooseStorageMode => 'Choose your storage mode:';

  @override
  String get useNativeSecureStorage => 'Use Native Secure Storage';

  @override
  String get useRustDatabase => 'Use Rust Database';

  @override
  String get nativeStorageConfigured => 'Native storage is configured.';

  @override
  String get nativeStorageNeedsSetup => 'Native storage needs setup.';

  @override
  String get unlockNativeStorage => 'Unlock Native Storage';

  @override
  String get enterPasswordNativeStorage => 'Enter password for native storage:';

  @override
  String get password => 'Password';

  @override
  String get unlock => 'Unlock';

  @override
  String get invalidPassword => 'Invalid password.';

  @override
  String failedToUnlock(Object error) {
    return 'Failed to unlock: $error';
  }

  @override
  String get nativeCategories => 'Native Categories';

  @override
  String get searchNotes => 'Search notes...';

  @override
  String get enterSearchTerm => 'Enter a search term';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noNativeCategoriesYet => 'No native categories yet.';

  @override
  String get createNewNativeCategory => 'Create New Native Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get openRustDatabase => 'Open Rust Database';

  @override
  String get selectRustDatabaseFiles =>
      'Select your Rust application\'s database file and validation file, then enter the password.';

  @override
  String get step1SelectDatabaseFile =>
      'Step 1: Select Database File (.sqlite)';

  @override
  String get browseForSQLiteFile => 'Browse for SQLite File';

  @override
  String get step2SelectValidationFile =>
      'Step 2: Select Validation File (.dat)';

  @override
  String get browseForValidationFile => 'Browse for validation.dat';

  @override
  String get step3EnterPassword => 'Step 3: Enter Password';

  @override
  String get enterDatabasePassword => 'Enter your database password';

  @override
  String get openDatabase => 'Open Database';

  @override
  String get selectRustDatabaseFile =>
      'Please select the Rust SQLite database file.';

  @override
  String get selectValidationFile => 'Please select the validation.dat file.';

  @override
  String get enterPassword => 'Please enter the password.';

  @override
  String get validatingPassword => 'Validating password...';

  @override
  String get passwordValidated => 'Password validated! Opening database...';

  @override
  String get passwordValidationFailed =>
      'Password validation failed. Incorrect password or corrupted validation file.';

  @override
  String failedToOpenRustDb(Object error) {
    return 'Failed to open Rust DB with service: $error';
  }

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get kabyle => 'Taqbaylit';

  @override
  String get nativeOptionsTitle => 'Native Secure Storage Options';

  @override
  String get createOrOpenDefaultDatabase => 'Create or Open Default Database';

  @override
  String get openExistingDatabase => 'Open Existing Database';

  @override
  String get createNewDatabase => 'Create New Database';

  @override
  String get selectedDirMissingPrefs =>
      'Selected directory does not contain shared_preferences.json';

  @override
  String get noDbFileFound =>
      'No database file (.db) found in the selected directory';

  @override
  String get databaseCreatedTitle => 'Database Created';

  @override
  String get openNewDatabaseQuestion =>
      'Would you like to open the newly created database?';

  @override
  String get openDatabaseAction => 'Open Database';

  @override
  String get backToOptions => 'Back to Options';

  @override
  String get createPasswordForCustomDatabaseTitle =>
      'Create Password for Custom Database';

  @override
  String get createSecurePasswordTitle => 'Create Secure Password';

  @override
  String get createPasswordLead => 'Create a password to secure your notes';

  @override
  String get createPasswordLeadCustom =>
      'Create a password for your new database';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get minPasswordLength => 'Password must be at least 6 characters';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordCreatedSuccess =>
      'Password created successfully! Please log in.';

  @override
  String get failedToSetPassword => 'Failed to set password. Please try again.';

  @override
  String genericError(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get previousMonth => 'Previous Month';

  @override
  String get nextMonth => 'Next Month';

  @override
  String get noNotesForThisMonth => 'No notes for this month';

  @override
  String get addNote => 'Add Note';

  @override
  String addNoteToCategory(Object category) {
    return 'Add Note to $category';
  }

  @override
  String noNotesInCategoryForMonth(Object category, Object month, Object year) {
    return 'No notes in $category for $month $year.';
  }

  @override
  String get addFirstNote => 'Add First Note';

  @override
  String noteInCategory(Object category) {
    return 'Note in $category';
  }

  @override
  String get addNewNote => 'Add New Note';

  @override
  String get noteIsEncrypted => 'Note is encrypted';

  @override
  String get encryptNote => 'Encrypt note';

  @override
  String get categoryLabel => 'Category';

  @override
  String get unnamed => 'Unnamed';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String categoryColon(Object name) {
    return 'Category: $name';
  }

  @override
  String get background => 'Background';

  @override
  String get titleColor => 'Title Color';

  @override
  String get titleOptional => 'Title (Optional)';

  @override
  String get enterYourNoteHere => 'Enter your note here...';

  @override
  String get saveNote => 'Save Note';
}
