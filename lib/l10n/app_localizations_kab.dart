// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kabyle (`kab`).
class AppLocalizationsKab extends AppLocalizations {
  AppLocalizationsKab([String locale = 'kab']) : super(locale);

  @override
  String get appTitle => 'Asnas n Tira Yettwamlen';

  @override
  String get appSubtitle => 'Iɣmisen-ik/ikem tuffɣa, ttwaḥerzen s tɣellist.';

  @override
  String get applicationError => 'Tuccḍa n Usnas';

  @override
  String get unknownErrorOccurred =>
      'Tuccḍa tarussint teḍra.\nAsnas ilaq ad yettwamdel.';

  @override
  String get closeApplication => 'Mdel Asnas';

  @override
  String get chooseStorageMode => 'Fren anaw n uḥerzi:';

  @override
  String get useNativeSecureStorage => 'Seqdec Aḥerzi Amzun Yettwamlen';

  @override
  String get useRustDatabase => 'Seqdec Taffa n Yisefka Rust';

  @override
  String get nativeStorageConfigured => 'Aḥerzi amzun yettwasewḍen.';

  @override
  String get nativeStorageNeedsSetup => 'Aḥerzi amzun yesra asewḍi.';

  @override
  String get unlockNativeStorage => 'Rmed Aḥerzi Amzun';

  @override
  String get enterPasswordNativeStorage =>
      'Sekcem awal n uɛeddi i uḥerzi amzun:';

  @override
  String get password => 'Awal n uɛeddi';

  @override
  String get unlock => 'Rmed';

  @override
  String get invalidPassword => 'Awal n uɛeddi aruɣan.';

  @override
  String failedToUnlock(Object error) {
    return 'Ur yeddi ara rmed: $error';
  }

  @override
  String get nativeCategories => 'Taggayin Amzunen';

  @override
  String get searchNotes => 'Nadi tira...';

  @override
  String get enterSearchTerm => 'Sekcem awalen n unadi';

  @override
  String get noResultsFound => 'Ulac igmumen';

  @override
  String get noNativeCategoriesYet => 'Ulac taggayin amzunen s tura.';

  @override
  String get createNewNativeCategory => 'Rnu Taggayt Tamaynut Amzun';

  @override
  String get categoryName => 'Isem n Taggayt';

  @override
  String get cancel => 'Sefsex';

  @override
  String get create => 'Rnu';

  @override
  String get openRustDatabase => 'Ldi Taffa n Yisefka Rust';

  @override
  String get selectRustDatabaseFiles =>
      'Fren afaylu n taffa n yisefka n usnas-ik Rust d afaylu n usentem, sinna sekcem awal n uɛeddi.';

  @override
  String get step1SelectDatabaseFile =>
      'Tasertit 1: Fren Afaylu n Taffa n Yisefka (.sqlite)';

  @override
  String get browseForSQLiteFile => 'Snirem i Afaylu SQLite';

  @override
  String get step2SelectValidationFile =>
      'Tasertit 2: Fren Afaylu n Usentem (.dat)';

  @override
  String get browseForValidationFile => 'Snirem i validation.dat';

  @override
  String get step3EnterPassword => 'Tasertit 3: Sekcem Awal n uɛeddi';

  @override
  String get enterDatabasePassword => 'Sekcem awal n uɛeddi n taffa n yisefka';

  @override
  String get openDatabase => 'Ldi Taffa n Yisefka';

  @override
  String get selectRustDatabaseFile =>
      'Ttxil-k fren afaylu n taffa n yisefka SQLite Rust.';

  @override
  String get selectValidationFile => 'Ttxil-k fren afaylu validation.dat.';

  @override
  String get enterPassword => 'Ttxil-k sekcem awal n uɛeddi.';

  @override
  String get validatingPassword => 'Asentem n wawal n uɛeddi...';

  @override
  String get passwordValidated =>
      'Awal n uɛeddi yettwaseqdec! Ldi taffa n yisefka...';

  @override
  String get passwordValidationFailed =>
      'Asentem n wawal n uɛeddi ur yeddi ara. Awal n uɛeddi aruɣan neɣ afaylu n usentem yettwaɣerzen.';

  @override
  String failedToOpenRustDb(Object error) {
    return 'Ur yeddi ara ldi taffa n yisefka Rust s uxeddim: $error';
  }

  @override
  String error(Object error) {
    return 'Tuccḍa: $error';
  }

  @override
  String get language => 'Tutlayt';

  @override
  String get selectLanguage => 'Fren Tutlayt';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get kabyle => 'Taqbaylit';

  @override
  String get nativeOptionsTitle => 'Iɣewwaren n uḥerzi amzun';

  @override
  String get createOrOpenDefaultDatabase =>
      'Rnu neɣ ldi taffa n yisefka tamezwarut';

  @override
  String get openExistingDatabase => 'Ldi taffa n yisefka yellan';

  @override
  String get createNewDatabase => 'Rnu taffa n yisefka tamaynut';

  @override
  String get selectedDirMissingPrefs =>
      'akaram i yettwafernen ur yesɛi ara shared_preferences.json';

  @override
  String get noDbFileFound =>
      'Ulac afaylu n taffa n yisefka (.db) deg ukaram i yettwafernen';

  @override
  String get databaseCreatedTitle => 'Taffa n yisefka tettwarna';

  @override
  String get openNewDatabaseQuestion =>
      'Tebɣiḍ ad teldiḍ taffa n yisefka tettwarna tura?';

  @override
  String get openDatabaseAction => 'Ldi taffa n yisefka';

  @override
  String get backToOptions => 'Uɣal ɣer iɣewwaren';

  @override
  String get createPasswordForCustomDatabaseTitle =>
      'Rnu awal n uɛeddi i taffa n yisefka yugnen';

  @override
  String get createSecurePasswordTitle => 'Rnu awal n uɛeddi aɣellsan';

  @override
  String get createPasswordLead => 'Rnu awal n uɛeddi i usekles n tazmilt-ik';

  @override
  String get createPasswordLeadCustom =>
      'Rnu awal n uɛeddi i taffa-ik n yisefka tamaynut';

  @override
  String get passwordLabel => 'Awal n uɛeddi';

  @override
  String get passwordHint => 'Sekcem awal-ik n uɛeddi';

  @override
  String get confirmPasswordLabel => 'Sentem awal n uɛeddi';

  @override
  String get confirmPasswordHint => 'Ales asekcem n wawal n uɛeddi';

  @override
  String get pleaseEnterPassword => 'Ttxil-k sekcem awal n uɛeddi';

  @override
  String get minPasswordLength =>
      'Awal n uɛeddi ilaq ad yegber 6 n yisekkilen ma drus';

  @override
  String get pleaseConfirmPassword => 'Ttxil-k sentem awal n uɛeddi';

  @override
  String get passwordsDoNotMatch => 'Awalen n uɛeddi ur mṣadan ara';

  @override
  String get passwordCreatedSuccess =>
      'Awal n uɛeddi yettwarnan akken iwata! Ttxil-k qqen.';

  @override
  String get failedToSetPassword =>
      'Ur yeddi ara asbadu n wawal n uɛeddi. ɛreḍ tikkelt-nniḍen.';

  @override
  String genericError(Object error) {
    return 'Teḍra-d tuccḍa: $error';
  }

  @override
  String get previousMonth => 'Aggur yezrin';

  @override
  String get nextMonth => 'Aggur d-iteddun';

  @override
  String get noNotesForThisMonth => 'Ulac tizmilin i waggur-agi';

  @override
  String get addNote => 'Rnu tazmilt';

  @override
  String addNoteToCategory(Object category) {
    return 'Rnu tazmilt ɣer $category';
  }

  @override
  String noNotesInCategoryForMonth(Object category, Object month, Object year) {
    return 'Ulac tizmilin deg $category i $month $year.';
  }

  @override
  String get addFirstNote => 'Rnu tazmilt tamezwarut';

  @override
  String noteInCategory(Object category) {
    return 'Tazmilt deg $category';
  }

  @override
  String get addNewNote => 'Rnu tazmilt tamaynut';

  @override
  String get noteIsEncrypted => 'Tazmilt tettwawgelhen';

  @override
  String get encryptNote => 'Awgelhen n tazmilt';

  @override
  String get categoryLabel => 'Taggayt';

  @override
  String get unnamed => 'War isem';

  @override
  String get pleaseSelectCategory => 'Ttxil-k fren taggayt';

  @override
  String categoryColon(Object name) {
    return 'Taggayt: $name';
  }

  @override
  String get background => 'Agilal';

  @override
  String get titleColor => 'Ini n uzwel';

  @override
  String get titleOptional => 'Azwel (afrayan)';

  @override
  String get enterYourNoteHere => 'Sekcem tazmilt-ik dagi...';

  @override
  String get saveNote => 'Sekles tazmilt';
}
