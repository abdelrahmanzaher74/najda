import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NAJDA'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Help, faster'**
  String get tagline;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to stay protected with NAJDA'**
  String get signInSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join NAJDA to get help faster'**
  String get registerSubtitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get lastNameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Egyptian mobile number, e.g. 1012345678'**
  String get phoneInvalid;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your address'**
  String get addressRequired;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get genderRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we’ll send you a link to reset your password'**
  String get forgotSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent. Check your email.'**
  String get resetLinkSent;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get hello;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @homeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Your home screen is coming soon'**
  String get homeComingSoon;

  /// No description provided for @webOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Please use the web dashboard'**
  String get webOnlyTitle;

  /// No description provided for @webOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is managed from the NAJDA web dashboard. Sign in there to continue.'**
  String get webOnlyMessage;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @protectedLocationOn.
  ///
  /// In en, this message translates to:
  /// **'You’re protected · Location on'**
  String get protectedLocationOn;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @holdToAlert.
  ///
  /// In en, this message translates to:
  /// **'Hold to alert'**
  String get holdToAlert;

  /// No description provided for @sosHint.
  ///
  /// In en, this message translates to:
  /// **'Press SOS to instantly alert responders and share your live location.'**
  String get sosHint;

  /// No description provided for @quickReport.
  ///
  /// In en, this message translates to:
  /// **'Quick report'**
  String get quickReport;

  /// No description provided for @medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medical;

  /// No description provided for @fire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get fire;

  /// No description provided for @police.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get police;

  /// No description provided for @comingNextStep.
  ///
  /// In en, this message translates to:
  /// **'This part is coming in the next step'**
  String get comingNextStep;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report emergency'**
  String get reportTitle;

  /// No description provided for @whatsHappening.
  ///
  /// In en, this message translates to:
  /// **'What’s happening?'**
  String get whatsHappening;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Person collapsed near the fountain, breathing but unresponsive...'**
  String get descriptionHint;

  /// No description provided for @numberOfInjured.
  ///
  /// In en, this message translates to:
  /// **'Number of injured'**
  String get numberOfInjured;

  /// No description provided for @attachEvidence.
  ///
  /// In en, this message translates to:
  /// **'Attach evidence (optional)'**
  String get attachEvidence;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @recordAudio.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get recordAudio;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get sendReport;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Your report was sent. Help is on the way.'**
  String get reportSent;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location…'**
  String get gettingLocation;

  /// No description provided for @locationReady.
  ///
  /// In en, this message translates to:
  /// **'Location ready'**
  String get locationReady;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off. Turn it on to send a report.'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to send a report.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable it from the app settings.'**
  String get locationPermissionForever;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t get your location. Please try again.'**
  String get locationUnavailable;

  /// No description provided for @locationImprecise.
  ///
  /// In en, this message translates to:
  /// **'Your location isn’t precise enough. Allow “Precise location” for NAJDA in settings, or move to an open area and try again.'**
  String get locationImprecise;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @turnOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get turnOnLocation;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @currentCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Current coordinates'**
  String get currentCoordinates;

  /// No description provided for @locationAuto.
  ///
  /// In en, this message translates to:
  /// **'Detected automatically from your device. It can’t be edited.'**
  String get locationAuto;

  /// No description provided for @mockLocationDetected.
  ///
  /// In en, this message translates to:
  /// **'A fake location was detected. Turn off any mock-location app to send a report.'**
  String get mockLocationDetected;

  /// No description provided for @mapCredit.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get mapCredit;

  /// No description provided for @activeReport.
  ///
  /// In en, this message translates to:
  /// **'Active report'**
  String get activeReport;

  /// No description provided for @reportNumber.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportNumber;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Report received'**
  String get statusPending;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Responder assigned'**
  String get statusAssigned;

  /// No description provided for @statusEnRoute.
  ///
  /// In en, this message translates to:
  /// **'Help is on the way'**
  String get statusEnRoute;

  /// No description provided for @statusOnScene.
  ///
  /// In en, this message translates to:
  /// **'Responder arrived'**
  String get statusOnScene;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get statusUnknown;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @injuredLabel.
  ///
  /// In en, this message translates to:
  /// **'Injured'**
  String get injuredLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @cancelReport.
  ///
  /// In en, this message translates to:
  /// **'Cancel report'**
  String get cancelReport;

  /// No description provided for @cancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this report?'**
  String get cancelTitle;

  /// No description provided for @cancelWhy.
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get cancelWhy;

  /// No description provided for @cancelMistake.
  ///
  /// In en, this message translates to:
  /// **'Sent by mistake'**
  String get cancelMistake;

  /// No description provided for @cancelResolved.
  ///
  /// In en, this message translates to:
  /// **'Situation resolved'**
  String get cancelResolved;

  /// No description provided for @cancelNotNeeded.
  ///
  /// In en, this message translates to:
  /// **'Help no longer needed'**
  String get cancelNotNeeded;

  /// No description provided for @cancelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cancelOther;

  /// No description provided for @cancelReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get cancelReasonHint;

  /// No description provided for @cancelCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose a reason'**
  String get cancelCategoryRequired;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add a few details'**
  String get reasonRequired;

  /// No description provided for @confirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Confirm cancellation'**
  String get confirmCancel;

  /// No description provided for @keepReport.
  ///
  /// In en, this message translates to:
  /// **'Keep report'**
  String get keepReport;

  /// No description provided for @reportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Your report was cancelled.'**
  String get reportCancelled;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @reportQueued.
  ///
  /// In en, this message translates to:
  /// **'No internet. Your report is saved and will be sent automatically when the connection returns.'**
  String get reportQueued;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting to send'**
  String get pendingTitle;

  /// No description provided for @pendingBody.
  ///
  /// In en, this message translates to:
  /// **'Saved on your phone. It will be sent automatically when the internet is back.'**
  String get pendingBody;

  /// No description provided for @pendingSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Saved at'**
  String get pendingSavedAt;

  /// No description provided for @pendingSendNow.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get pendingSendNow;

  /// No description provided for @pendingDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get pendingDiscard;

  /// No description provided for @pendingStaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved report is old'**
  String get pendingStaleTitle;

  /// No description provided for @pendingStaleBody.
  ///
  /// In en, this message translates to:
  /// **'This report was saved more than 30 minutes ago. Your situation or location may have changed. Send it anyway or discard it?'**
  String get pendingStaleBody;

  /// No description provided for @pendingSendAnyway.
  ///
  /// In en, this message translates to:
  /// **'Send anyway'**
  String get pendingSendAnyway;

  /// No description provided for @pendingAlready.
  ///
  /// In en, this message translates to:
  /// **'You already have a report waiting to be sent.'**
  String get pendingAlready;

  /// No description provided for @googleTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing with Google, you agree to our '**
  String get googleTermsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andWord;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// No description provided for @verificationSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get verificationSentTo;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get secondsShort;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeEmail;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email first'**
  String get emailNotVerified;

  /// No description provided for @verificationExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification expired. Please verify your email again.'**
  String get verificationExpired;

  /// No description provided for @agreePrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreePrefix;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @agreeSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get agreeSuffix;

  /// No description provided for @mustAgree.
  ///
  /// In en, this message translates to:
  /// **'You must agree to continue'**
  String get mustAgree;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the link'**
  String get couldNotOpenLink;

  /// No description provided for @medicalHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical history'**
  String get medicalHistoryTitle;

  /// No description provided for @medicalHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share what matters in an emergency. You can update it later.'**
  String get medicalHistorySubtitle;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood type'**
  String get bloodType;

  /// No description provided for @bloodTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Critical for transfusions'**
  String get bloodTypeHint;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @selectAllThatApply.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get selectAllThatApply;

  /// No description provided for @allergyPenicillin.
  ///
  /// In en, this message translates to:
  /// **'Penicillin'**
  String get allergyPenicillin;

  /// No description provided for @allergyPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergyPeanuts;

  /// No description provided for @allergyLatex.
  ///
  /// In en, this message translates to:
  /// **'Latex'**
  String get allergyLatex;

  /// No description provided for @allergyAspirin.
  ///
  /// In en, this message translates to:
  /// **'Aspirin'**
  String get allergyAspirin;

  /// No description provided for @allergyBeeStings.
  ///
  /// In en, this message translates to:
  /// **'Bee stings'**
  String get allergyBeeStings;

  /// No description provided for @allergyShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergyShellfish;

  /// No description provided for @medicalConditions.
  ///
  /// In en, this message translates to:
  /// **'Medical conditions'**
  String get medicalConditions;

  /// No description provided for @conditionAsthma.
  ///
  /// In en, this message translates to:
  /// **'Asthma'**
  String get conditionAsthma;

  /// No description provided for @conditionDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get conditionDiabetes;

  /// No description provided for @conditionEpilepsy.
  ///
  /// In en, this message translates to:
  /// **'Epilepsy'**
  String get conditionEpilepsy;

  /// No description provided for @conditionHeartDisease.
  ///
  /// In en, this message translates to:
  /// **'Heart disease'**
  String get conditionHeartDisease;

  /// No description provided for @conditionHypertension.
  ///
  /// In en, this message translates to:
  /// **'Hypertension'**
  String get conditionHypertension;

  /// No description provided for @otherOption.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherOption;

  /// No description provided for @addOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your own'**
  String get addOtherTitle;

  /// No description provided for @addOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Type here'**
  String get addOtherHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @currentMedications.
  ///
  /// In en, this message translates to:
  /// **'Current medications'**
  String get currentMedications;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalLabel;

  /// No description provided for @medicationsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Insulin, Ventolin'**
  String get medicationsHint;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get emergencyContact;

  /// No description provided for @emergencyContactHint.
  ///
  /// In en, this message translates to:
  /// **'We’ll notify them automatically'**
  String get emergencyContactHint;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get contactPhone;

  /// No description provided for @contactNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the contact’s name'**
  String get contactNameRequired;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @medicalSaved.
  ///
  /// In en, this message translates to:
  /// **'Medical history saved'**
  String get medicalSaved;

  /// No description provided for @unitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Responders'**
  String get unitsTitle;

  /// No description provided for @unitAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get unitAmbulance;

  /// No description provided for @unitFirstResponder.
  ///
  /// In en, this message translates to:
  /// **'First responder'**
  String get unitFirstResponder;

  /// No description provided for @unitPolice.
  ///
  /// In en, this message translates to:
  /// **'Police unit'**
  String get unitPolice;

  /// No description provided for @unitFire.
  ///
  /// In en, this message translates to:
  /// **'Fire unit'**
  String get unitFire;

  /// No description provided for @unitAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted the case'**
  String get unitAccepted;

  /// No description provided for @unitEnRoute.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get unitEnRoute;

  /// No description provided for @unitArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get unitArrived;

  /// No description provided for @noUnitsYet.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a responder to be assigned…'**
  String get noUnitsYet;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @kmShort.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kmShort;

  /// No description provided for @metersShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get metersShort;

  /// No description provided for @etaApproxNote.
  ///
  /// In en, this message translates to:
  /// **'Distances and times are approximate.'**
  String get etaApproxNote;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show everyone'**
  String get showAll;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatWithDispatcher.
  ///
  /// In en, this message translates to:
  /// **'Chat with dispatcher'**
  String get chatWithDispatcher;

  /// No description provided for @chatCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask questions or share updates'**
  String get chatCardSubtitle;

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Tell the dispatcher anything that can help the responders.'**
  String get chatEmpty;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatHint;

  /// No description provided for @chatClosed.
  ///
  /// In en, this message translates to:
  /// **'This report is closed, so the chat is read-only.'**
  String get chatClosed;

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t send your message. Please try again.'**
  String get chatSendFailed;

  /// No description provided for @roleDispatcher.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher'**
  String get roleDispatcher;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get roleYou;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'NAJDA team'**
  String get roleStaff;

  /// No description provided for @adminJoined.
  ///
  /// In en, this message translates to:
  /// **'An admin joined the conversation'**
  String get adminJoined;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
