// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Application de Notes Sécurisée';

  @override
  String get appSubtitle => 'Vos pensées privées, stockées en toute sécurité.';

  @override
  String get applicationError => 'Erreur d\'Application';

  @override
  String get unknownErrorOccurred =>
      'Une erreur inconnue s\'est produite.\nL\'application doit être fermée.';

  @override
  String get closeApplication => 'Fermer l\'Application';

  @override
  String get chooseStorageMode => 'Choisissez votre mode de stockage :';

  @override
  String get useNativeSecureStorage => 'Utiliser le Stockage Sécurisé Natif';

  @override
  String get useRustDatabase => 'Utiliser la Base de Données Rust';

  @override
  String get nativeStorageConfigured => 'Le stockage natif est configuré.';

  @override
  String get nativeStorageNeedsSetup =>
      'Le stockage natif nécessite une configuration.';

  @override
  String get unlockNativeStorage => 'Déverrouiller le Stockage Natif';

  @override
  String get enterPasswordNativeStorage =>
      'Entrez le mot de passe pour le stockage natif :';

  @override
  String get password => 'Mot de passe';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get invalidPassword => 'Mot de passe invalide.';

  @override
  String failedToUnlock(Object error) {
    return 'Échec du déverrouillage : $error';
  }

  @override
  String get nativeCategories => 'Catégories Natives';

  @override
  String get searchNotes => 'Rechercher des notes...';

  @override
  String get enterSearchTerm => 'Entrez un terme de recherche';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get noNativeCategoriesYet => 'Aucune catégorie native pour le moment.';

  @override
  String get createNewNativeCategory => 'Créer une Nouvelle Catégorie Native';

  @override
  String get categoryName => 'Nom de la Catégorie';

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String get openRustDatabase => 'Ouvrir la Base de Données Rust';

  @override
  String get selectRustDatabaseFiles =>
      'Sélectionnez le fichier de base de données de votre application Rust et le fichier de validation, puis entrez le mot de passe.';

  @override
  String get step1SelectDatabaseFile =>
      'Étape 1 : Sélectionner le Fichier de Base de Données (.sqlite)';

  @override
  String get browseForSQLiteFile => 'Parcourir pour le Fichier SQLite';

  @override
  String get step2SelectValidationFile =>
      'Étape 2 : Sélectionner le Fichier de Validation (.dat)';

  @override
  String get browseForValidationFile => 'Parcourir pour validation.dat';

  @override
  String get step3EnterPassword => 'Étape 3 : Entrer le Mot de Passe';

  @override
  String get enterDatabasePassword =>
      'Entrez votre mot de passe de base de données';

  @override
  String get openDatabase => 'Ouvrir la Base de Données';

  @override
  String get selectRustDatabaseFile =>
      'Veuillez sélectionner le fichier de base de données SQLite Rust.';

  @override
  String get selectValidationFile =>
      'Veuillez sélectionner le fichier validation.dat.';

  @override
  String get enterPassword => 'Veuillez entrer le mot de passe.';

  @override
  String get validatingPassword => 'Validation du mot de passe...';

  @override
  String get passwordValidated =>
      'Mot de passe validé ! Ouverture de la base de données...';

  @override
  String get passwordValidationFailed =>
      'La validation du mot de passe a échoué. Mot de passe incorrect ou fichier de validation corrompu.';

  @override
  String failedToOpenRustDb(Object error) {
    return 'Échec de l\'ouverture de la base de données Rust avec le service : $error';
  }

  @override
  String error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get kabyle => 'Taqbaylit';

  @override
  String get nativeOptionsTitle => 'Options de stockage sécurisé natif';

  @override
  String get createOrOpenDefaultDatabase =>
      'Créer ou ouvrir la base par défaut';

  @override
  String get openExistingDatabase => 'Ouvrir une base existante';

  @override
  String get createNewDatabase => 'Créer une nouvelle base';

  @override
  String get selectedDirMissingPrefs =>
      'Le dossier sélectionné ne contient pas shared_preferences.json';

  @override
  String get noDbFileFound =>
      'Aucun fichier base de données (.db) trouvé dans le dossier sélectionné';

  @override
  String get databaseCreatedTitle => 'Base de données créée';

  @override
  String get openNewDatabaseQuestion =>
      'Voulez-vous ouvrir la base nouvellement créée ?';

  @override
  String get openDatabaseAction => 'Ouvrir la base';

  @override
  String get backToOptions => 'Retour aux options';

  @override
  String get createPasswordForCustomDatabaseTitle =>
      'Créer un mot de passe pour la base personnalisée';

  @override
  String get createSecurePasswordTitle => 'Créer un mot de passe sécurisé';

  @override
  String get createPasswordLead =>
      'Créez un mot de passe pour sécuriser vos notes';

  @override
  String get createPasswordLeadCustom =>
      'Créez un mot de passe pour votre nouvelle base';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => 'Entrez votre mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmez le mot de passe';

  @override
  String get confirmPasswordHint => 'Saisissez à nouveau votre mot de passe';

  @override
  String get pleaseEnterPassword => 'Veuillez saisir un mot de passe';

  @override
  String get minPasswordLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordCreatedSuccess =>
      'Mot de passe créé avec succès ! Veuillez vous connecter.';

  @override
  String get failedToSetPassword =>
      'Échec de la création du mot de passe. Veuillez réessayer.';

  @override
  String genericError(Object error) {
    return 'Une erreur s\'est produite : $error';
  }

  @override
  String get previousMonth => 'Mois précédent';

  @override
  String get nextMonth => 'Mois suivant';

  @override
  String get noNotesForThisMonth => 'Aucune note pour ce mois';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String addNoteToCategory(Object category) {
    return 'Ajouter une note à $category';
  }

  @override
  String noNotesInCategoryForMonth(Object category, Object month, Object year) {
    return 'Aucune note dans $category pour $month $year.';
  }

  @override
  String get addFirstNote => 'Ajouter la première note';

  @override
  String noteInCategory(Object category) {
    return 'Note dans $category';
  }

  @override
  String get addNewNote => 'Ajouter une nouvelle note';

  @override
  String get noteIsEncrypted => 'La note est chiffrée';

  @override
  String get encryptNote => 'Chiffrer la note';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get unnamed => 'Sans nom';

  @override
  String get pleaseSelectCategory => 'Veuillez sélectionner une catégorie';

  @override
  String categoryColon(Object name) {
    return 'Catégorie : $name';
  }

  @override
  String get background => 'Arrière-plan';

  @override
  String get titleColor => 'Couleur du titre';

  @override
  String get titleOptional => 'Titre (facultatif)';

  @override
  String get enterYourNoteHere => 'Saisissez votre note ici...';

  @override
  String get saveNote => 'Enregistrer la note';
}
