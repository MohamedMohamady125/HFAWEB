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
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HFA Swimming Club'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @threads.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get threads;

  /// No description provided for @gear.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get gear;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Welcome message with user first name
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String welcome(Object name);

  /// No description provided for @coachDashboard.
  ///
  /// In en, this message translates to:
  /// **'Coach Dashboard'**
  String get coachDashboard;

  /// No description provided for @loadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading Dashboard...'**
  String get loadingDashboard;

  /// No description provided for @myDashboard.
  ///
  /// In en, this message translates to:
  /// **'My Dashboard'**
  String get myDashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'👋 Welcome back!'**
  String get welcomeBack;

  /// No description provided for @todayIs.
  ///
  /// In en, this message translates to:
  /// **'Today is {day} {month} {year}'**
  String todayIs(Object day, Object month, Object year);

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// No description provided for @latePayment.
  ///
  /// In en, this message translates to:
  /// **'Late Payment'**
  String get latePayment;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @key.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get key;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @noGear.
  ///
  /// In en, this message translates to:
  /// **'No Gear'**
  String get noGear;

  /// No description provided for @noTrainingSession.
  ///
  /// In en, this message translates to:
  /// **'No training session'**
  String get noTrainingSession;

  /// No description provided for @daysOfWeekShort.
  ///
  /// In en, this message translates to:
  /// **'S,M,T,W,T,F,S'**
  String get daysOfWeekShort;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @failedToLoadProfileData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile data'**
  String get failedToLoadProfileData;

  /// No description provided for @registrationRequests.
  ///
  /// In en, this message translates to:
  /// **'Registration Requests'**
  String get registrationRequests;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @weeklyAttendance.
  ///
  /// In en, this message translates to:
  /// **'Weekly Attendance'**
  String get weeklyAttendance;

  /// No description provided for @attendanceCalendar.
  ///
  /// In en, this message translates to:
  /// **'Attendance Calendar'**
  String get attendanceCalendar;

  /// No description provided for @monthlyAttendanceCalendar.
  ///
  /// In en, this message translates to:
  /// **'Monthly Attendance Calendar'**
  String get monthlyAttendanceCalendar;

  /// No description provided for @athletesList.
  ///
  /// In en, this message translates to:
  /// **'Athletes List'**
  String get athletesList;

  /// No description provided for @swimMeetPerformance.
  ///
  /// In en, this message translates to:
  /// **'Swim Meet Performance'**
  String get swimMeetPerformance;

  /// No description provided for @attendanceSeason.
  ///
  /// In en, this message translates to:
  /// **'Attendance Season'**
  String get attendanceSeason;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @switchBranch.
  ///
  /// In en, this message translates to:
  /// **'Switch Branch'**
  String get switchBranch;

  /// Feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming soon!'**
  String featureComingSoon(Object feature);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming soon!'**
  String comingSoon(Object feature);

  /// No description provided for @comingSoonFeature.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming soon!'**
  String comingSoonFeature(Object feature);

  /// No description provided for @switchBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Branch'**
  String get switchBranchTitle;

  /// No description provided for @loadingBranches.
  ///
  /// In en, this message translates to:
  /// **'Loading branches...'**
  String get loadingBranches;

  /// No description provided for @noBranchesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Branches Available'**
  String get noBranchesAvailable;

  /// No description provided for @noBranchesDescription.
  ///
  /// In en, this message translates to:
  /// **'No branches are configured in the system.'**
  String get noBranchesDescription;

  /// No description provided for @currentBranch.
  ///
  /// In en, this message translates to:
  /// **'Current Branch'**
  String get currentBranch;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @switchToBranch.
  ///
  /// In en, this message translates to:
  /// **'Switch to Branch'**
  String get switchToBranch;

  /// No description provided for @switching.
  ///
  /// In en, this message translates to:
  /// **'Switching...'**
  String get switching;

  /// No description provided for @branchDetails.
  ///
  /// In en, this message translates to:
  /// **'Branch Details'**
  String get branchDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @switchButton.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchButton;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @practiceDays.
  ///
  /// In en, this message translates to:
  /// **'Practice Days'**
  String get practiceDays;

  /// No description provided for @branchId.
  ///
  /// In en, this message translates to:
  /// **'Branch ID: {branchId}'**
  String branchId(Object branchId);

  /// No description provided for @videoUrl.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get videoUrl;

  /// No description provided for @alreadyManaging.
  ///
  /// In en, this message translates to:
  /// **'You are already managing {branchName}'**
  String alreadyManaging(Object branchName);

  /// No description provided for @switchBranchConfirm.
  ///
  /// In en, this message translates to:
  /// **'Switch to {branchName}?'**
  String switchBranchConfirm(Object branchName);

  /// No description provided for @switchBranchDescription.
  ///
  /// In en, this message translates to:
  /// **'This will update all data views to show information for {branchName}.'**
  String switchBranchDescription(Object branchName);

  /// No description provided for @switchedToBranch.
  ///
  /// In en, this message translates to:
  /// **'Switched to {branchName}'**
  String switchedToBranch(Object branchName);

  /// No description provided for @failedToLoadBranches.
  ///
  /// In en, this message translates to:
  /// **'Failed to load branches'**
  String get failedToLoadBranches;

  /// No description provided for @failedToSwitchBranch.
  ///
  /// In en, this message translates to:
  /// **'Failed to switch branch'**
  String get failedToSwitchBranch;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @updatePasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Update your password to keep your account secure'**
  String get updatePasswordPrompt;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 chars, incl. special character'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get confirmPasswordHint;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Password Strength'**
  String get passwordStrength;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too Short (Min 8 chars)'**
  String get passwordTooShort;

  /// No description provided for @passwordNeedsSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'Weak (Needs special char)'**
  String get passwordNeedsSpecialChar;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get passwordModerate;

  /// No description provided for @passwordFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordFair;

  /// No description provided for @passwordGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordGood;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @passwordTips.
  ///
  /// In en, this message translates to:
  /// **'Password Tips'**
  String get passwordTips;

  /// No description provided for @passwordTipLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get passwordTipLength;

  /// No description provided for @passwordTipCase.
  ///
  /// In en, this message translates to:
  /// **'Include uppercase and lowercase letters'**
  String get passwordTipCase;

  /// No description provided for @passwordTipSpecial.
  ///
  /// In en, this message translates to:
  /// **'Add numbers and special characters (e.g., !@#\$)'**
  String get passwordTipSpecial;

  /// No description provided for @passwordTipAvoid.
  ///
  /// In en, this message translates to:
  /// **'Avoid common words or personal info'**
  String get passwordTipAvoid;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully. Please use your new password for future logins.'**
  String get passwordChangedSuccess;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordMinLength;

  /// No description provided for @passwordNeedsSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordNeedsSpecialCharacter;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get passwordSameAsCurrent;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @coachLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach Login'**
  String get coachLoginTitle;

  /// No description provided for @teamManagementPortal.
  ///
  /// In en, this message translates to:
  /// **'Team Management Portal'**
  String get teamManagementPortal;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'coach@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginAsCoach.
  ///
  /// In en, this message translates to:
  /// **'Login as Coach'**
  String get loginAsCoach;

  /// No description provided for @coachPortal.
  ///
  /// In en, this message translates to:
  /// **'Coach Portal'**
  String get coachPortal;

  /// No description provided for @coachPortalDescription.
  ///
  /// In en, this message translates to:
  /// **'Exclusive access for coaches to manage athletes, schedules, and attendance.'**
  String get coachPortalDescription;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordTooShortLogin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShortLogin;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @accessDeniedCoachOnly.
  ///
  /// In en, this message translates to:
  /// **'Access denied. Coaches only.'**
  String get accessDeniedCoachOnly;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get networkError;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach Profile'**
  String get profileTitle;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @branchAttendanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Branch Attendance Summary'**
  String get branchAttendanceSummary;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @failedToLogout.
  ///
  /// In en, this message translates to:
  /// **'Failed to logout'**
  String get failedToLogout;

  /// No description provided for @languageChangedToArabic.
  ///
  /// In en, this message translates to:
  /// **'Language changed to Arabic'**
  String get languageChangedToArabic;

  /// No description provided for @languageChangedToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Language changed to English'**
  String get languageChangedToEnglish;

  /// No description provided for @branchGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch Group'**
  String get branchGroupTitle;

  /// No description provided for @loadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation! 👋'**
  String get startConversation;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @unknownBranch.
  ///
  /// In en, this message translates to:
  /// **'Unknown Branch'**
  String get unknownBranch;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get failedToSendMessage;

  /// No description provided for @gearInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Gear Information'**
  String get gearInformationTitle;

  /// No description provided for @editGearTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Gear Information'**
  String get editGearTitle;

  /// No description provided for @gearDescription.
  ///
  /// In en, this message translates to:
  /// **'This section is for the practice gear. The displayed gear is already present to the athletes. You can add whichever new gear you want to add and press update.'**
  String get gearDescription;

  /// No description provided for @gearHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter gear requirements, equipment lists, or important notes...'**
  String get gearHintText;

  /// No description provided for @updateGearButton.
  ///
  /// In en, this message translates to:
  /// **'Update Gear Information'**
  String get updateGearButton;

  /// No description provided for @readOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'Read Only • Only Head Coaches can edit gear'**
  String get readOnlyMessage;

  /// No description provided for @loadingGearInformation.
  ///
  /// In en, this message translates to:
  /// **'Loading gear information...'**
  String get loadingGearInformation;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownErrorOccurred;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @gearUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Gear information updated successfully!'**
  String get gearUpdateSuccess;

  /// No description provided for @gearUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update gear'**
  String get gearUpdateFailed;

  /// No description provided for @weeklyAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'🏊 Weekly Attendance'**
  String get weeklyAttendanceTitle;

  /// No description provided for @day1.
  ///
  /// In en, this message translates to:
  /// **'Day 1'**
  String get day1;

  /// No description provided for @day2.
  ///
  /// In en, this message translates to:
  /// **'Day 2'**
  String get day2;

  /// No description provided for @day3.
  ///
  /// In en, this message translates to:
  /// **'Day 3'**
  String get day3;

  /// No description provided for @failedToGetUserProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to get user profile: {error}'**
  String failedToGetUserProfile(Object error);

  /// No description provided for @branchIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Branch ID not found in user profile'**
  String get branchIdNotFound;

  /// No description provided for @failedToLoadUserProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user profile'**
  String get failedToLoadUserProfile;

  /// No description provided for @noSessionDatesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No session dates configured for this branch'**
  String get noSessionDatesConfigured;

  /// No description provided for @failedToLoadSessionDates.
  ///
  /// In en, this message translates to:
  /// **'Failed to load session dates: {error}'**
  String failedToLoadSessionDates(Object error);

  /// No description provided for @failedToLoadSessionDatesGeneral.
  ///
  /// In en, this message translates to:
  /// **'Failed to load session dates'**
  String get failedToLoadSessionDatesGeneral;

  /// No description provided for @sessionDateNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Session date not available'**
  String get sessionDateNotAvailable;

  /// No description provided for @failedToLoadAttendance.
  ///
  /// In en, this message translates to:
  /// **'Failed to load attendance: {error}'**
  String failedToLoadAttendance(Object error);

  /// No description provided for @failedToLoadAttendanceGeneral.
  ///
  /// In en, this message translates to:
  /// **'Failed to load attendance'**
  String get failedToLoadAttendanceGeneral;

  /// No description provided for @attendanceMarked.
  ///
  /// In en, this message translates to:
  /// **'Attendance marked as {status}'**
  String attendanceMarked(Object status);

  /// No description provided for @failedToUpdateAttendance.
  ///
  /// In en, this message translates to:
  /// **'Failed to update attendance: {error}'**
  String failedToUpdateAttendance(Object error);

  /// No description provided for @failedToUpdateAttendanceGeneral.
  ///
  /// In en, this message translates to:
  /// **'Failed to update attendance'**
  String get failedToUpdateAttendanceGeneral;

  /// No description provided for @loadingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Loading attendance...'**
  String get loadingAttendance;

  /// No description provided for @noAthletesFound.
  ///
  /// In en, this message translates to:
  /// **'No Athletes Found'**
  String get noAthletesFound;

  /// No description provided for @noAttendanceDataForDay.
  ///
  /// In en, this message translates to:
  /// **'No attendance data for this day'**
  String get noAttendanceDataForDay;

  /// No description provided for @unknownAthlete.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownAthlete;

  /// No description provided for @missedGear.
  ///
  /// In en, this message translates to:
  /// **'Missed gear: {notes}'**
  String missedGear(Object notes);

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String status(Object status);

  /// No description provided for @didMissGear.
  ///
  /// In en, this message translates to:
  /// **'Did the athlete miss any gear at practice?'**
  String get didMissGear;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @typeMissedGearHere.
  ///
  /// In en, this message translates to:
  /// **'Type missed gear here...'**
  String get typeMissedGearHere;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @enterMissedGearNotes.
  ///
  /// In en, this message translates to:
  /// **'Please enter missed gear notes'**
  String get enterMissedGearNotes;

  /// No description provided for @loadingRequests.
  ///
  /// In en, this message translates to:
  /// **'Loading requests...'**
  String get loadingRequests;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests;

  /// No description provided for @allRequestsProcessed.
  ///
  /// In en, this message translates to:
  /// **'All registration requests have been processed'**
  String get allRequestsProcessed;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @athletesWaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'{count} athlete(s) waiting for approval'**
  String athletesWaitingApproval(Object count);

  /// No description provided for @failedToLoadRequests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load registration requests: {error}'**
  String failedToLoadRequests(Object error);

  /// No description provided for @failedToLoadRequestsGeneral.
  ///
  /// In en, this message translates to:
  /// **'Failed to load registration requests'**
  String get failedToLoadRequestsGeneral;

  /// No description provided for @approveRegistration.
  ///
  /// In en, this message translates to:
  /// **'Approve Registration'**
  String get approveRegistration;

  /// No description provided for @approveRegistrationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve {athlete}\'s registration request?'**
  String approveRegistrationMessage(Object athlete);

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @registrationApproved.
  ///
  /// In en, this message translates to:
  /// **'Registration approved successfully!'**
  String get registrationApproved;

  /// No description provided for @failedToApproveRegistration.
  ///
  /// In en, this message translates to:
  /// **'Failed to approve registration: {error}'**
  String failedToApproveRegistration(Object error);

  /// No description provided for @failedToApproveRegistrationGeneral.
  ///
  /// In en, this message translates to:
  /// **'Failed to approve registration'**
  String get failedToApproveRegistrationGeneral;

  /// No description provided for @rejectRegistration.
  ///
  /// In en, this message translates to:
  /// **'Reject Registration'**
  String get rejectRegistration;

  /// No description provided for @rejectRegistrationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject {athlete}\'s registration request?\n\nThis action cannot be undone.'**
  String rejectRegistrationMessage(Object athlete);

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @registrationRejected.
  ///
  /// In en, this message translates to:
  /// **'Registration request rejected'**
  String get registrationRejected;

  /// No description provided for @failedToRejectRegistration.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject registration: {error}'**
  String failedToRejectRegistration(Object error);

  /// No description provided for @failedToRejectRegistrationGeneral.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject registration'**
  String get failedToRejectRegistrationGeneral;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String submitted(Object date);

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// No description provided for @monthlyAttendance.
  ///
  /// In en, this message translates to:
  /// **'Monthly Attendance'**
  String get monthlyAttendance;

  /// No description provided for @loadingAthletes.
  ///
  /// In en, this message translates to:
  /// **'Loading athletes and attendance...'**
  String get loadingAthletes;

  /// No description provided for @errorLoadingAthletes.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Athletes'**
  String get errorLoadingAthletes;

  /// No description provided for @noAthletesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No athletes are registered in this branch'**
  String get noAthletesRegistered;

  /// No description provided for @monthlyAttendanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Monthly Attendance Overview'**
  String get monthlyAttendanceOverview;

  /// No description provided for @athletesInBranch.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 athlete in your branch} other {{count} athletes in your branch}}'**
  String athletesInBranch(num count);

  /// No description provided for @searchAthletes.
  ///
  /// In en, this message translates to:
  /// **'Search athletes...'**
  String get searchAthletes;

  /// No description provided for @failedToLoadAthletes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load athletes: {error}'**
  String failedToLoadAthletes(Object error);

  /// No description provided for @failedToLoadAthletesGeneral.
  ///
  /// In en, this message translates to:
  /// **'Failed to load athletes'**
  String get failedToLoadAthletesGeneral;

  /// No description provided for @athletesManagement.
  ///
  /// In en, this message translates to:
  /// **'Athletes Management'**
  String get athletesManagement;

  /// No description provided for @athleteId.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String athleteId(Object id);

  /// No description provided for @deleteAthlete.
  ///
  /// In en, this message translates to:
  /// **'Delete Athlete'**
  String get deleteAthlete;

  /// No description provided for @deleteAthleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete {name}?'**
  String deleteAthleteConfirm(Object name);

  /// No description provided for @deleteAthleteWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ This action cannot be undone!'**
  String get deleteAthleteWarning;

  /// No description provided for @deleteAthleteDetails.
  ///
  /// In en, this message translates to:
  /// **'• The athlete will lose access to their account forever\n• All their data will be permanently removed\n• This action is irreversible'**
  String get deleteAthleteDetails;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get delete;

  /// No description provided for @deleteAthleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} has been permanently deleted'**
  String deleteAthleteSuccess(Object name);

  /// No description provided for @deleteAthleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete athlete: {error}'**
  String deleteAthleteFailed(Object error);

  /// No description provided for @athletesInAcademy.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 athlete in academy} other {{count} athletes in academy}}'**
  String athletesInAcademy(num count);

  /// No description provided for @invalidId.
  ///
  /// In en, this message translates to:
  /// **'Invalid athlete ID'**
  String get invalidId;

  /// No description provided for @athlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get athlete;

  /// No description provided for @presentWithGear.
  ///
  /// In en, this message translates to:
  /// **'Present + Gear'**
  String get presentWithGear;

  /// No description provided for @presentWithoutGear.
  ///
  /// In en, this message translates to:
  /// **'Present - Gear'**
  String get presentWithoutGear;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @monthlyStatistics.
  ///
  /// In en, this message translates to:
  /// **'Monthly Statistics'**
  String get monthlyStatistics;

  /// No description provided for @attendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get attendanceRate;

  /// No description provided for @daysPresent.
  ///
  /// In en, this message translates to:
  /// **'Days Present'**
  String get daysPresent;

  /// No description provided for @daysAbsent.
  ///
  /// In en, this message translates to:
  /// **'Days Absent'**
  String get daysAbsent;

  /// No description provided for @gearIssues.
  ///
  /// In en, this message translates to:
  /// **'Gear Issues'**
  String get gearIssues;

  /// No description provided for @missedGearDetails.
  ///
  /// In en, this message translates to:
  /// **'Missed Gear Details'**
  String get missedGearDetails;

  /// No description provided for @perfectNoGearMissed.
  ///
  /// In en, this message translates to:
  /// **'Perfect! No gear was missed this month.'**
  String get perfectNoGearMissed;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notes;

  /// No description provided for @daysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Sun,Mon,Tue,Wed,Thu,Fri,Sat'**
  String get daysOfWeek;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @performanceLogs.
  ///
  /// In en, this message translates to:
  /// **'Performance Logs'**
  String get performanceLogs;

  /// No description provided for @athletePerformanceLogs.
  ///
  /// In en, this message translates to:
  /// **'Athlete Performance Logs'**
  String get athletePerformanceLogs;

  /// No description provided for @noAthletesRegisteredBranch.
  ///
  /// In en, this message translates to:
  /// **'No athletes are registered in this branch'**
  String get noAthletesRegisteredBranch;

  /// No description provided for @viewTimes.
  ///
  /// In en, this message translates to:
  /// **'View Times'**
  String get viewTimes;

  /// No description provided for @idField.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idField(Object id);

  /// No description provided for @loadingPerformanceLogs.
  ///
  /// In en, this message translates to:
  /// **'Loading performance logs...'**
  String get loadingPerformanceLogs;

  /// No description provided for @errorLoadingPerformanceLogs.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Performance Logs'**
  String get errorLoadingPerformanceLogs;

  /// No description provided for @noPerformanceLogs.
  ///
  /// In en, this message translates to:
  /// **'No Performance Logs'**
  String get noPerformanceLogs;

  /// No description provided for @noPerformanceRecords.
  ///
  /// In en, this message translates to:
  /// **'No performance records found for this athlete'**
  String get noPerformanceRecords;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @performanceRecord.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 performance record} other {{count} performance records}}'**
  String performanceRecord(num count);

  /// No description provided for @unknownEvent.
  ///
  /// In en, this message translates to:
  /// **'Unknown Event'**
  String get unknownEvent;

  /// No description provided for @noTime.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get noTime;

  /// No description provided for @trainingSession.
  ///
  /// In en, this message translates to:
  /// **'Training Session'**
  String get trainingSession;

  /// No description provided for @paymentManagement.
  ///
  /// In en, this message translates to:
  /// **'Payment Management'**
  String get paymentManagement;

  /// No description provided for @loadingPaymentData.
  ///
  /// In en, this message translates to:
  /// **'Loading payment data...'**
  String get loadingPaymentData;

  /// No description provided for @errorLoadingPaymentData.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Payment Data'**
  String get errorLoadingPaymentData;

  /// No description provided for @monthlyPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Monthly Payment Status'**
  String get monthlyPaymentStatus;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current:'**
  String get current;

  /// No description provided for @paymentStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment status updated successfully'**
  String get paymentStatusUpdated;

  /// No description provided for @failedToUpdatePaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update payment status: {error}'**
  String failedToUpdatePaymentStatus(Object error);

  /// Title for the Athletes Measurements tool card on the coach home screen
  ///
  /// In en, this message translates to:
  /// **'Athletes Measurements'**
  String get athletesMeasurements;

  /// No description provided for @measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @loadingMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Loading measurements...'**
  String get loadingMeasurements;

  /// No description provided for @errorLoadingMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Measurements'**
  String get errorLoadingMeasurements;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No Measurements'**
  String get noMeasurements;

  /// No description provided for @noMeasurementsForAthlete.
  ///
  /// In en, this message translates to:
  /// **'No measurements found for this athlete'**
  String get noMeasurementsForAthlete;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @measurementRecord.
  ///
  /// In en, this message translates to:
  /// **'measurement record'**
  String get measurementRecord;

  /// No description provided for @measurementRecords.
  ///
  /// In en, this message translates to:
  /// **'measurement records'**
  String get measurementRecords;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @arm.
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get arm;

  /// No description provided for @leg.
  ///
  /// In en, this message translates to:
  /// **'Leg'**
  String get leg;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat %'**
  String get fat;

  /// No description provided for @muscle.
  ///
  /// In en, this message translates to:
  /// **'Muscle %'**
  String get muscle;

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @signInBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInBtn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @unknownUserType.
  ///
  /// In en, this message translates to:
  /// **'Unknown user type: {userType}'**
  String unknownUserType(Object userType);

  /// No description provided for @branchChat.
  ///
  /// In en, this message translates to:
  /// **'Branch Chat'**
  String get branchChat;

  /// No description provided for @branchDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Branch Discussion'**
  String get branchDiscussion;

  /// No description provided for @loadingThreads.
  ///
  /// In en, this message translates to:
  /// **'Loading chat threads...'**
  String get loadingThreads;

  /// No description provided for @failedToLoadThreads.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chat threads'**
  String get failedToLoadThreads;

  /// No description provided for @networkErrorLoadingThreads.
  ///
  /// In en, this message translates to:
  /// **'Network error loading threads'**
  String get networkErrorLoadingThreads;

  /// No description provided for @userBranchInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User branch information not available'**
  String get userBranchInfoNotAvailable;

  /// No description provided for @failedToLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get failedToLoadMessages;

  /// No description provided for @networkErrorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Network error loading messages'**
  String get networkErrorLoadingMessages;

  /// No description provided for @readOnlyMode.
  ///
  /// In en, this message translates to:
  /// **'You are viewing this chat in read-only mode.'**
  String get readOnlyMode;

  /// No description provided for @noChatThreadsYet.
  ///
  /// In en, this message translates to:
  /// **'No Chat Threads Yet'**
  String get noChatThreadsYet;

  /// No description provided for @createFirstDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Create the first discussion thread for your branch'**
  String get createFirstDiscussion;

  /// No description provided for @coachHasNotCreatedThreads.
  ///
  /// In en, this message translates to:
  /// **'Your coach hasn\'t created any threads yet'**
  String get coachHasNotCreatedThreads;

  /// No description provided for @createThread.
  ///
  /// In en, this message translates to:
  /// **'Create Thread'**
  String get createThread;

  /// No description provided for @selectAThread.
  ///
  /// In en, this message translates to:
  /// **'Select a Thread'**
  String get selectAThread;

  /// No description provided for @tapSwitchToChoose.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Switch\" in the header to choose a conversation'**
  String get tapSwitchToChoose;

  /// No description provided for @waitForCoach.
  ///
  /// In en, this message translates to:
  /// **'Be the first to say something or wait for your coach!'**
  String get waitForCoach;

  /// No description provided for @switchThread.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchThread;

  /// No description provided for @selectChatThread.
  ///
  /// In en, this message translates to:
  /// **'Select Chat Thread'**
  String get selectChatThread;

  /// No description provided for @untitledThread.
  ///
  /// In en, this message translates to:
  /// **'Untitled Thread'**
  String get untitledThread;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @createNewThread.
  ///
  /// In en, this message translates to:
  /// **'Create New Thread'**
  String get createNewThread;

  /// No description provided for @threadTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., \"Weekly Training Discussion\"'**
  String get threadTitleHint;

  /// No description provided for @threadTitleCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Thread title cannot be empty!'**
  String get threadTitleCannotBeEmpty;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @threadCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Thread created successfully! 🎉'**
  String get threadCreatedSuccessfully;

  /// No description provided for @failedToCreateThread.
  ///
  /// In en, this message translates to:
  /// **'Failed to create thread'**
  String get failedToCreateThread;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today at'**
  String get todayAt;

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at'**
  String get yesterdayAt;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Title for the Coach Branch Assignment tool card on the coach home screen
  ///
  /// In en, this message translates to:
  /// **'Coach Branch Assignment'**
  String get coachBranchAssignment;

  /// No description provided for @assignCoachesTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Coaches'**
  String get assignCoachesTitle;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @loadingCoaches.
  ///
  /// In en, this message translates to:
  /// **'Loading coaches...'**
  String get loadingCoaches;

  /// No description provided for @noCoachesFound.
  ///
  /// In en, this message translates to:
  /// **'No Coaches Found'**
  String get noCoachesFound;

  /// No description provided for @noCoachesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No coaches are available for assignment'**
  String get noCoachesAvailable;

  /// No description provided for @coachAssignmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach Assignments'**
  String get coachAssignmentsTitle;

  /// No description provided for @coachesInSystem.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count} coach in the system} other {{count} coaches in the system}}'**
  String coachesInSystem(num count);

  /// No description provided for @searchCoachesHint.
  ///
  /// In en, this message translates to:
  /// **'Search coaches...'**
  String get searchCoachesHint;

  /// No description provided for @assignedStat.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assignedStat;

  /// No description provided for @unassignedStat.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassignedStat;

  /// No description provided for @multiBranchStat.
  ///
  /// In en, this message translates to:
  /// **'Multi-Branch'**
  String get multiBranchStat;

  /// No description provided for @noCoachesForQuery.
  ///
  /// In en, this message translates to:
  /// **'No coaches found for \"{query}\"'**
  String noCoachesForQuery(Object query);

  /// No description provided for @failedToLoadCoaches.
  ///
  /// In en, this message translates to:
  /// **'Failed to load coaches: {error}'**
  String failedToLoadCoaches(Object error);

  /// No description provided for @failedToLoadStats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load assignment stats: {error}'**
  String failedToLoadStats(Object error);

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// No description provided for @branchesAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'Branches assigned to {coachName}'**
  String branchesAssignedTo(Object coachName);

  /// No description provided for @noBranchesFound.
  ///
  /// In en, this message translates to:
  /// **'No branches found'**
  String get noBranchesFound;

  /// No description provided for @assignButton.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assignButton;

  /// No description provided for @unassignButton.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get unassignButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @errorLoadingBranches.
  ///
  /// In en, this message translates to:
  /// **'Error loading branches'**
  String get errorLoadingBranches;

  /// No description provided for @failedToAssign.
  ///
  /// In en, this message translates to:
  /// **'Failed to assign'**
  String get failedToAssign;

  /// No description provided for @failedToUnassign.
  ///
  /// In en, this message translates to:
  /// **'Failed to unassign'**
  String get failedToUnassign;

  /// No description provided for @branchAssigned.
  ///
  /// In en, this message translates to:
  /// **'Branch assigned'**
  String get branchAssigned;

  /// No description provided for @branchUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Branch unassigned'**
  String get branchUnassigned;

  /// No description provided for @gearUpdates.
  ///
  /// In en, this message translates to:
  /// **'Gear Updates'**
  String get gearUpdates;

  /// No description provided for @latestGearUpdates.
  ///
  /// In en, this message translates to:
  /// **'Latest Gear Updates'**
  String get latestGearUpdates;

  /// No description provided for @noGearUpdates.
  ///
  /// In en, this message translates to:
  /// **'No Gear Updates'**
  String get noGearUpdates;

  /// No description provided for @noGearUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Your coach hasn\'t posted any gear updates yet. Check back later!'**
  String get noGearUpdatesDesc;

  /// No description provided for @coachUpdate.
  ///
  /// In en, this message translates to:
  /// **'Coach Update'**
  String get coachUpdate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon!'**
  String get shareFeatureComingSoon;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
