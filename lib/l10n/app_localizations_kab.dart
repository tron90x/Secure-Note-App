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

  @override
  String errorLoadingCategories(Object error) {
    return 'Tuccḍa deg usider n teggayin: $error';
  }

  @override
  String get pickNoteBackgroundColor => 'Fren ini n ugilal n tezm ilt';

  @override
  String get pickTitleColor => 'Fren ini n uzwel';

  @override
  String get select => 'Fren';

  @override
  String get pleaseEnterContentBeforeEncrypting =>
      'Ttxil-k sekcem agbur send awgelhen';

  @override
  String get encrypt => 'Awgelhen';

  @override
  String get noteEncryptedSuccessfully => 'Tazmilt tettwawgelhen akken iwata!';

  @override
  String encryptionError(Object error) {
    return 'Tuccḍa: $error';
  }

  @override
  String get pleaseEnterTitle => 'Ttxil-k sekcem azwel';

  @override
  String errorSavingNote(Object error) {
    return 'Tuccḍa deg usekles n tezmilet: $error';
  }

  @override
  String tooManyFailedAttempts(Object minutes) {
    return 'Aṭas n tirmitinin ur neǧǧi ara. Ttxil-k raǧu $minutes n tesdat.';
  }

  @override
  String get decryptNote => 'Kkes awgelhen n tezmilt';

  @override
  String get enterPasswordToDecrypt =>
      'Sekcem awal n uɛeddi i tuksa n uwgelhen';

  @override
  String get pleaseEnterThePassword => 'Ttxil-k sekcem awal n uɛeddi';

  @override
  String failedAttempts(Object current, Object max) {
    return 'Tirmitinin ur neǧǧin ara: $current/$max';
  }

  @override
  String get decrypt => 'Kkes awgelhen';

  @override
  String get noteDecryptedSuccessfully =>
      'Awgelhen n tezmilt yettwakkes akken iwata!';

  @override
  String decryptionError(Object error) {
    return 'Tuccḍa: $error';
  }

  @override
  String get noteContentCannotBeEmpty =>
      'Agbur n tezmilet ur yezmir ara ad yili d ilem.';

  @override
  String get noteUpdated => 'Tazmilt tettwaleqqem!';

  @override
  String get deleteNote => 'Kkes tazmilt';

  @override
  String get deleteNoteConfirmation =>
      'Tebɣiḍ s tidet ad tekkseḍ tazmilt-agi? Tigawt-agi ur tezmir ara ad tettwasefsex.';

  @override
  String get delete => 'Kkes';

  @override
  String errorDeletingNote(Object error) {
    return 'Tuccḍa deg tukksa n tezmilet: $error';
  }

  @override
  String errorLoadingImages(Object error) {
    return 'Tuccḍa deg usider n tugniwin: $error';
  }

  @override
  String get imageDeletedSuccessfully => 'Tugna tettwakkes akken iwata';

  @override
  String errorDeletingImage(Object error) {
    return 'Tuccḍa deg tukksa n tugna: $error';
  }

  @override
  String get close => 'Mdel';

  @override
  String imageSavedTo(Object path) {
    return 'Tugna tettwasekles deg: $path';
  }

  @override
  String errorDownloadingImage(Object error) {
    return 'Tuccḍa deg usider n tugna: $error';
  }

  @override
  String get attachedImages => 'Tugniwin yeddan';

  @override
  String get imagesAttachedSuccessfully => 'Tugna/tugniwin rnan akken iwata!';

  @override
  String errorAttachingImages(Object error) {
    return 'Tuccḍa deg tmerna n tugna/tugniwin: $error';
  }

  @override
  String get titleLabel => 'Azwel';

  @override
  String get untitled => 'War azwel';

  @override
  String get changeBackgroundColor => 'Beddel ini n ugilal';

  @override
  String get changeTextColor => 'Beddel ini n uḍris';

  @override
  String get cancelEdit => 'Sefsex asnifel';

  @override
  String get saveChanges => 'Sekles ibeddilen';

  @override
  String get resetDatabase => 'Ales asbadu n taffa n yisefka';

  @override
  String get resetDatabaseConfirmation =>
      'Tebɣiḍ s tidet ad talseḍ asbadu n taffa n yisefka? Ayagi ad yekkes akk tizmilin-ik ur yezmir ara ad yettwasefsex.';

  @override
  String get reset => 'Ales asbadu';

  @override
  String failedToResetDatabase(Object error) {
    return 'Ur yeddi ara walles n usebdu n taffa n yisefka: $error';
  }

  @override
  String get unlockCustomDatabase => 'Rmed taffa n yisefka yugnen';

  @override
  String get enterPasswordCustomDb =>
      'Sekcem awal n uɛeddi i taffa n yisefka yugnen:';

  @override
  String get searchFilters => 'Imsizdigen n unadi';

  @override
  String get selectDateRange => 'Fren azilal n wazemz';

  @override
  String get filterByCategory => 'Sizdeg s teggayt';

  @override
  String get allCategories => 'Akk taggayin';

  @override
  String get clearAllFilters => 'Sfeḍ akk imsizdigen';

  @override
  String get createNewEntry => 'Rnu anekcum amaynut';

  @override
  String get entryNameLabel => 'Isem n unekcum';

  @override
  String get enterEntryName => 'Sekcem isem i unekcum-inek';

  @override
  String get pleaseEnterName => 'Ttxil-k sekcem isem';

  @override
  String errorCreatingEntry(Object error) {
    return 'Tuccḍa deg tmerna n unekcum: $error';
  }

  @override
  String get deleteEntry => 'Kkes anekcum';

  @override
  String deleteEntryConfirmation(Object name) {
    return 'Tebɣiḍ s tidet ad tekkseḍ "$name"? Ayagi ad yekkes daɣen akk tizmilin n unekcum-agi.';
  }

  @override
  String errorDeletingEntry(Object error) {
    return 'Tuccḍa deg tukksa n unekcum: $error';
  }

  @override
  String get themeSettings => 'Iɣewwaren n usentel';

  @override
  String get switchToListView => 'Ddu ɣer tmuɣli s tebdart';

  @override
  String get switchToGridView => 'Ddu ɣer tmuɣli s tferrugt';

  @override
  String get returnToWelcomeScreen => 'Uɣal ɣer ugdil n usenselkem';

  @override
  String get unnamedCategory => 'Taggayt war isem';

  @override
  String get createdLabel => 'Yettwarna: ';

  @override
  String get noEntriesYet => 'Ulac inekman s tura';

  @override
  String get tapPlusButtonToCreate =>
      'Senned ɣef tqeffalt + i tmerna n unekcum-ik amezwaru';

  @override
  String get createFirstEntry => 'Rnu anekcum amezwaru';

  @override
  String get lastModifiedLabel => 'Asnifel aneggaru: ';

  @override
  String get addNewEntry => 'Rnu anekcum amaynut';

  @override
  String get entryNameCannotBeEmpty =>
      'Isem n unekcum ur yezmir ara ad yili d ilem.';

  @override
  String get add => 'Rnu';

  @override
  String entryAddedWithId(Object name, Object id) {
    return 'Anekcum "$name" yettwarnan s ID: $id.';
  }

  @override
  String failedToAddEntry(Object error) {
    return 'Ur yeddi ara rnu n unekcum: $error';
  }

  @override
  String editEntry(Object name) {
    return 'Ẓreg anekcum "$name"';
  }

  @override
  String get newEntryNameLabel => 'Isem amaynut n unekcum';

  @override
  String get pleaseEnterDifferentName => 'Ttxil-k sekcem isem-nniḍen.';

  @override
  String get update => 'Leqqem';

  @override
  String entryUpdatedTo(Object oldName, Object newName) {
    return 'Anekcum "$oldName" yettuleqqem ɣer "$newName".';
  }

  @override
  String failedToUpdateEntry(Object error) {
    return 'Ur yeddi ara uleqqem n unekcum: $error';
  }

  @override
  String get deleteEntryQuestion => 'Kkes anekcum?';

  @override
  String deleteEntryAndNotesConfirmation(Object name) {
    return 'Tebɣiḍ s tidet ad tekkseḍ "$name" d akk tizmilin-is? Ur yezmir ara ad yettwasefsex.';
  }

  @override
  String entryDeleted(Object name) {
    return 'Anekcum "$name" yettwakkes';
  }

  @override
  String get pleaseSelectEntryFirst => 'Ttxil-k fren anekcum amezwaru.';

  @override
  String addNewNoteTo(Object name) {
    return 'Rnu tazmilt tamaynut ɣer "$name"';
  }

  @override
  String get noteContentLabel => 'Agbur n tezmilet';

  @override
  String get noteContentCannotBeEmpty =>
      'Agbur n tezmilet ur yezmir ara ad yili d ilem.';

  @override
  String get addNoteButton => 'Rnu tazmilt';

  @override
  String get noteAddedSuccessfully => 'Tazmilt tettwarna akken iwata!';

  @override
  String failedToAddNote(Object error) {
    return 'Ur yeddi ara tmerna n tezmilet: $error';
  }

  @override
  String todoEditNote(Object id) {
    return 'TODO: Ẓreg tazmilt $id';
  }

  @override
  String get deleteNoteQuestion => 'Kkes tazmilt?';

  @override
  String get deleteNoteConfirmation =>
      'Tebɣiḍ s tidet ad tekkseḍ tazmilt-agi? Ur tezmir ara ad tettwasefsex.';

  @override
  String get noteDeleted => 'Tazmilt tettwakkes';

  @override
  String rustDbTitle(Object name) {
    return 'Taffa Rust: $name';
  }

  @override
  String get loadingDatabase => 'Asider n taffa n yisefka...';

  @override
  String get errorLabel => 'Tuccḍa';

  @override
  String get entries => 'Inekman';

  @override
  String get noEntriesFound => 'Ulac inekman';

  @override
  String get notes => 'Tizmilin';

  @override
  String get noNotesFoundForMonth => 'Ulac tizmilin i waggur-agi';

  @override
  String get refresh => 'Smiren';

  @override
  String get themeMode => 'Anaw n usentel';

  @override
  String get systemTheme => 'Anagraw';

  @override
  String get lightTheme => 'Aceɛlal';

  @override
  String get darkTheme => 'Aberkan';

  @override
  String get automaticDarkMode => 'Anaw aberkan awurman';

  @override
  String get enableTimeBasedDarkMode => 'Rmed anaw aberkan s wakud';

  @override
  String get darkModeTimeBased => 'Anaw aberkan gar 19:00 d 06:00';

  @override
  String get myNotes => 'Tizmilin-inu';

  @override
  String get welcomeToMyNotes => 'Anṣuf ɣer Tizmilin-inu';

  @override
  String get yourPersonalNoteApplication =>
      'Asnas-inek udmawan n tira n tizmilin';

  @override
  String get viewNotes => 'Ẓer tizmilin';

  @override
  String get welcome => 'Anṣuf';

  @override
  String get applicationInitializedSuccessfully =>
      'Asnas yettwasbadu akken iwata.';

  @override
  String get continueButton => 'Kemmel';

  @override
  String errorLoadingNotes(Object error) {
    return 'Tuccḍa deg usider n tezmilin: $error';
  }

  @override
  String get noNotesYet => 'Ulac tizmilin s tura';

  @override
  String get encryptedNoteLabel => '[Tazmilt yettwawgelhen]';
}
