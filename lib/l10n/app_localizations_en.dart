// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NAJDA';

  @override
  String get tagline => 'Help, faster';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to stay protected with NAJDA';

  @override
  String get signIn => 'Sign in';

  @override
  String get email => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don’t have an account?';

  @override
  String get createAccount => 'Create account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get or => 'OR';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Join NAJDA to get help faster';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get phone => 'Phone number';

  @override
  String get address => 'Address';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get firstNameRequired => 'Please enter your first name';

  @override
  String get lastNameRequired => 'Please enter your last name';

  @override
  String get phoneRequired => 'Please enter your phone number';

  @override
  String get phoneInvalid =>
      'Enter a valid Egyptian mobile number, e.g. 1012345678';

  @override
  String get addressRequired => 'Please enter your address';

  @override
  String get genderRequired => 'Please select your gender';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotSubtitle =>
      'Enter your email and we’ll send you a link to reset your password';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get resetLinkSent => 'Reset link sent. Check your email.';

  @override
  String get hello => 'Hello,';

  @override
  String get signOut => 'Sign out';

  @override
  String get homeComingSoon => 'Your home screen is coming soon';

  @override
  String get webOnlyTitle => 'Please use the web dashboard';

  @override
  String get webOnlyMessage =>
      'Your account is managed from the NAJDA web dashboard. Sign in there to continue.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get protectedLocationOn => 'You’re protected · Location on';

  @override
  String get sos => 'SOS';

  @override
  String get holdToAlert => 'Hold to alert';

  @override
  String get sosHint =>
      'Press SOS to instantly alert responders and share your live location.';

  @override
  String get quickReport => 'Quick report';

  @override
  String get medical => 'Medical';

  @override
  String get fire => 'Fire';

  @override
  String get police => 'Police';

  @override
  String get comingNextStep => 'This part is coming in the next step';

  @override
  String get reportTitle => 'Report emergency';

  @override
  String get whatsHappening => 'What’s happening?';

  @override
  String get descriptionHint =>
      'e.g. Person collapsed near the fountain, breathing but unresponsive...';

  @override
  String get numberOfInjured => 'Number of injured';

  @override
  String get attachEvidence => 'Attach evidence (optional)';

  @override
  String get upload => 'Upload';

  @override
  String get recordAudio => 'Record audio';

  @override
  String get sendReport => 'Send report';

  @override
  String get reportSent => 'Your report was sent. Help is on the way.';

  @override
  String get gettingLocation => 'Getting your location…';

  @override
  String get locationReady => 'Location ready';

  @override
  String get locationServiceDisabled =>
      'Location is turned off. Turn it on to send a report.';

  @override
  String get locationPermissionDenied =>
      'Location permission is needed to send a report.';

  @override
  String get locationPermissionForever =>
      'Location permission is blocked. Enable it from the app settings.';

  @override
  String get locationUnavailable =>
      'Couldn’t get your location. Please try again.';

  @override
  String get locationImprecise =>
      'Your location isn’t precise enough. Allow “Precise location” for NAJDA in settings, or move to an open area and try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get turnOnLocation => 'Turn on location';

  @override
  String get openSettings => 'Open settings';

  @override
  String get currentCoordinates => 'Current coordinates';

  @override
  String get locationAuto =>
      'Detected automatically from your device. It can’t be edited.';

  @override
  String get mockLocationDetected =>
      'A fake location was detected. Turn off any mock-location app to send a report.';

  @override
  String get mapCredit => '© OpenStreetMap contributors';

  @override
  String get activeReport => 'Active report';

  @override
  String get reportNumber => 'Report';

  @override
  String get statusPending => 'Report received';

  @override
  String get statusAssigned => 'Responder assigned';

  @override
  String get statusEnRoute => 'Help is on the way';

  @override
  String get statusOnScene => 'Responder arrived';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusUnknown => 'Unknown status';

  @override
  String get progress => 'Progress';

  @override
  String get details => 'Details';

  @override
  String get injuredLabel => 'Injured';

  @override
  String get locationLabel => 'Location';

  @override
  String get noDescription => 'No description';

  @override
  String get cancelReport => 'Cancel report';

  @override
  String get cancelTitle => 'Cancel this report?';

  @override
  String get cancelWhy => 'Why are you cancelling?';

  @override
  String get cancelMistake => 'Sent by mistake';

  @override
  String get cancelResolved => 'Situation resolved';

  @override
  String get cancelNotNeeded => 'Help no longer needed';

  @override
  String get cancelOther => 'Other';

  @override
  String get cancelReasonHint => 'Add details (optional)';

  @override
  String get cancelCategoryRequired => 'Please choose a reason';

  @override
  String get reasonRequired => 'Please add a few details';

  @override
  String get confirmCancel => 'Confirm cancellation';

  @override
  String get keepReport => 'Keep report';

  @override
  String get reportCancelled => 'Your report was cancelled.';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get reportQueued =>
      'No internet. Your report is saved and will be sent automatically when the connection returns.';

  @override
  String get pendingTitle => 'Waiting to send';

  @override
  String get pendingBody =>
      'Saved on your phone. It will be sent automatically when the internet is back.';

  @override
  String get pendingSavedAt => 'Saved at';

  @override
  String get pendingSendNow => 'Send now';

  @override
  String get pendingDiscard => 'Discard';

  @override
  String get pendingStaleTitle => 'Saved report is old';

  @override
  String get pendingStaleBody =>
      'This report was saved more than 30 minutes ago. Your situation or location may have changed. Send it anyway or discard it?';

  @override
  String get pendingSendAnyway => 'Send anyway';

  @override
  String get pendingAlready => 'You already have a report waiting to be sent.';

  @override
  String get googleTermsPrefix =>
      'By continuing with Google, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get andWord => ' and ';

  @override
  String get sendVerificationCode => 'Send verification code';

  @override
  String get verificationSentTo => 'We sent a 6-digit code to';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String get resendIn => 'Resend in';

  @override
  String get secondsShort => 's';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get changeEmail => 'Change';

  @override
  String get emailNotVerified => 'Please verify your email first';

  @override
  String get verificationExpired =>
      'Verification expired. Please verify your email again.';

  @override
  String get agreePrefix => 'I agree to the ';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get agreeSuffix => '.';

  @override
  String get mustAgree => 'You must agree to continue';

  @override
  String get couldNotOpenLink => 'Couldn’t open the link';

  @override
  String get medicalHistoryTitle => 'Medical history';

  @override
  String get medicalHistorySubtitle =>
      'Share what matters in an emergency. You can update it later.';

  @override
  String get bloodType => 'Blood type';

  @override
  String get bloodTypeHint => 'Critical for transfusions';

  @override
  String get allergies => 'Allergies';

  @override
  String get selectAllThatApply => 'Select all that apply';

  @override
  String get allergyPenicillin => 'Penicillin';

  @override
  String get allergyPeanuts => 'Peanuts';

  @override
  String get allergyLatex => 'Latex';

  @override
  String get allergyAspirin => 'Aspirin';

  @override
  String get allergyBeeStings => 'Bee stings';

  @override
  String get allergyShellfish => 'Shellfish';

  @override
  String get medicalConditions => 'Medical conditions';

  @override
  String get conditionAsthma => 'Asthma';

  @override
  String get conditionDiabetes => 'Diabetes';

  @override
  String get conditionEpilepsy => 'Epilepsy';

  @override
  String get conditionHeartDisease => 'Heart disease';

  @override
  String get conditionHypertension => 'Hypertension';

  @override
  String get otherOption => 'Other';

  @override
  String get addOtherTitle => 'Add your own';

  @override
  String get addOtherHint => 'Type here';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get currentMedications => 'Current medications';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get medicationsHint => 'e.g. Insulin, Ventolin';

  @override
  String get emergencyContact => 'Emergency contact';

  @override
  String get emergencyContactHint => 'We’ll notify them automatically';

  @override
  String get contactName => 'Contact name';

  @override
  String get contactPhone => 'Contact phone';

  @override
  String get contactNameRequired => 'Please enter the contact’s name';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get medicalSaved => 'Medical history saved';

  @override
  String get unitsTitle => 'Responders';

  @override
  String get unitAmbulance => 'Ambulance';

  @override
  String get unitFirstResponder => 'First responder';

  @override
  String get unitPolice => 'Police unit';

  @override
  String get unitFire => 'Fire unit';

  @override
  String get unitAccepted => 'Accepted the case';

  @override
  String get unitEnRoute => 'On the way';

  @override
  String get unitArrived => 'Arrived';

  @override
  String get noUnitsYet => 'Waiting for a responder to be assigned…';

  @override
  String get yourLocation => 'Your location';

  @override
  String get minutesShort => 'min';

  @override
  String get kmShort => 'km';

  @override
  String get metersShort => 'm';

  @override
  String get etaApproxNote => 'Distances and times are approximate.';

  @override
  String get showAll => 'Show everyone';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatWithDispatcher => 'Chat with dispatcher';

  @override
  String get chatCardSubtitle => 'Ask questions or share updates';

  @override
  String get chatEmpty =>
      'No messages yet. Tell the dispatcher anything that can help the responders.';

  @override
  String get chatHint => 'Type a message…';

  @override
  String get chatClosed => 'This report is closed, so the chat is read-only.';

  @override
  String get chatSendFailed => 'Couldn’t send your message. Please try again.';

  @override
  String get roleDispatcher => 'Dispatcher';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleYou => 'You';

  @override
  String get roleStaff => 'NAJDA team';

  @override
  String get adminJoined => 'An admin joined the conversation';

  @override
  String get newMessage => 'New message';

  @override
  String get send => 'Send';

  @override
  String get whileYouWait => 'While you wait';

  @override
  String get guidanceTitle => 'Until help arrives';

  @override
  String get seeAllGuidance => 'See all steps';

  @override
  String get guidanceDisclaimer =>
      'General first-aid information. It doesn’t replace professional care. If the dispatcher tells you something different, follow the dispatcher.';

  @override
  String get guidanceImportant => 'Important';
}
