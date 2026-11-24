import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';

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
    Locale('es'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Golden Hour'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Every Second Counts'**
  String get appTagline;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Privacy'**
  String get settingsTitle;

  /// No description provided for @appearanceAndTheme.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE & THEME'**
  String get appearanceAndTheme;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @daylightLight.
  ///
  /// In en, this message translates to:
  /// **'Daylight Light'**
  String get daylightLight;

  /// No description provided for @highContrastDark.
  ///
  /// In en, this message translates to:
  /// **'High-Contrast Dark'**
  String get highContrastDark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select app display language'**
  String get languageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi (हिंदी)'**
  String get hindi;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish (Español)'**
  String get spanish;

  /// No description provided for @emergencySafetyProtocols.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY SAFETY PROTOCOLS'**
  String get emergencySafetyProtocols;

  /// No description provided for @offlineSafetyGuides.
  ///
  /// In en, this message translates to:
  /// **'Offline Emergency Safety Guides'**
  String get offlineSafetyGuides;

  /// No description provided for @offlineSafetyGuidesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guidance available without internet'**
  String get offlineSafetyGuidesSubtitle;

  /// No description provided for @safetyContactGroups.
  ///
  /// In en, this message translates to:
  /// **'Safety Contact Groups'**
  String get safetyContactGroups;

  /// No description provided for @safetyContactGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize contacts & broadcast emergency alerts'**
  String get safetyContactGroupsSubtitle;

  /// No description provided for @liveEmergencyRadar.
  ///
  /// In en, this message translates to:
  /// **'Live Emergency Radar & Map'**
  String get liveEmergencyRadar;

  /// No description provided for @liveEmergencyRadarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time responder radar & safe-zone alerts'**
  String get liveEmergencyRadarSubtitle;

  /// No description provided for @legalAndCompliance.
  ///
  /// In en, this message translates to:
  /// **'LEGAL & COMPLIANCE (INDIA DPDPA)'**
  String get legalAndCompliance;

  /// No description provided for @dpdpaPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'DPDPA 2023 Privacy Policy'**
  String get dpdpaPolicyTitle;

  /// No description provided for @dpdpaPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purpose limitation, data minimization, consent records'**
  String get dpdpaPolicySubtitle;

  /// No description provided for @emergencyResponderDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Emergency Responder Disclaimer'**
  String get emergencyResponderDisclaimer;

  /// No description provided for @emergencyResponderDisclaimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Good Samaritan protection and emergency response rules'**
  String get emergencyResponderDisclaimerSubtitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Golden Hour platform terms and limitations'**
  String get termsOfServiceSubtitle;

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT ACTIONS'**
  String get accountActions;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device. Your emergency QR will remain active.'**
  String get logOutSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'DPDPA Right to Erasure: Permanently delete all profile and emergency data'**
  String get deleteAccountSubtitle;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @emergencyHelplines.
  ///
  /// In en, this message translates to:
  /// **'Emergency Helplines'**
  String get emergencyHelplines;

  /// No description provided for @emergencySos.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get emergencySos;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @medicalConditions.
  ///
  /// In en, this message translates to:
  /// **'Health Conditions'**
  String get medicalConditions;

  /// No description provided for @activeMedications.
  ///
  /// In en, this message translates to:
  /// **'Active Medications'**
  String get activeMedications;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;
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
      <String>['en', 'es', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
