// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HFA Swimming Club';

  @override
  String get home => 'Home';

  @override
  String get threads => 'Threads';

  @override
  String get gear => 'Gear';

  @override
  String get profile => 'Profile';

  @override
  String welcome(Object name) {
    return 'Welcome $name';
  }

  @override
  String get coachDashboard => 'Coach Dashboard';

  @override
  String get loadingDashboard => 'Loading Dashboard...';

  @override
  String get myDashboard => 'My Dashboard';

  @override
  String get welcomeBack => '👋 Welcome back!';

  @override
  String todayIs(Object day, Object month, Object year) {
    return 'Today is $day $month $year';
  }

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get latePayment => 'Late Payment';

  @override
  String get user => 'User';

  @override
  String get key => 'Key';

  @override
  String get present => 'Present';

  @override
  String get noGear => 'No Gear';

  @override
  String get noTrainingSession => 'No training session';

  @override
  String get daysOfWeekShort => 'S,M,T,W,T,F,S';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get failedToLoadProfileData => 'Failed to load profile data';

  @override
  String get registrationRequests => 'Registration Requests';

  @override
  String get attendance => 'Attendance';

  @override
  String get weeklyAttendance => 'Weekly Attendance';

  @override
  String get attendanceCalendar => 'Attendance Calendar';

  @override
  String get monthlyAttendanceCalendar => 'Monthly Attendance Calendar';

  @override
  String get athletesList => 'Athletes List';

  @override
  String get swimMeetPerformance => 'Swim Meet Performance';

  @override
  String get attendanceSeason => 'Attendance Season';

  @override
  String get payments => 'Payments';

  @override
  String get switchBranch => 'Switch Branch';

  @override
  String featureComingSoon(Object feature) {
    return '$feature feature coming soon!';
  }

  @override
  String comingSoon(Object feature) {
    return '$feature feature coming soon!';
  }

  @override
  String comingSoonFeature(Object feature) {
    return '$feature feature coming soon!';
  }

  @override
  String get switchBranchTitle => 'Switch Branch';

  @override
  String get loadingBranches => 'Loading branches...';

  @override
  String get noBranchesAvailable => 'No Branches Available';

  @override
  String get noBranchesDescription => 'No branches are configured in the system.';

  @override
  String get currentBranch => 'Current Branch';

  @override
  String get active => 'Active';

  @override
  String get switchToBranch => 'Switch to Branch';

  @override
  String get switching => 'Switching...';

  @override
  String get branchDetails => 'Branch Details';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get switchButton => 'Switch';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get practiceDays => 'Practice Days';

  @override
  String branchId(Object branchId) {
    return 'Branch ID: $branchId';
  }

  @override
  String get videoUrl => 'Video URL';

  @override
  String alreadyManaging(Object branchName) {
    return 'You are already managing $branchName';
  }

  @override
  String switchBranchConfirm(Object branchName) {
    return 'Switch to $branchName?';
  }

  @override
  String switchBranchDescription(Object branchName) {
    return 'This will update all data views to show information for $branchName.';
  }

  @override
  String switchedToBranch(Object branchName) {
    return 'Switched to $branchName';
  }

  @override
  String get failedToLoadBranches => 'Failed to load branches';

  @override
  String get failedToSwitchBranch => 'Failed to switch branch';

  @override
  String get refresh => 'Refresh';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get securitySettings => 'Security Settings';

  @override
  String get updatePasswordPrompt => 'Update your password to keep your account secure';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get newPasswordHint => 'Min. 8 chars, incl. special character';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get confirmPasswordHint => 'Re-enter your new password';

  @override
  String get passwordStrength => 'Password Strength';

  @override
  String get passwordTooShort => 'Too Short (Min 8 chars)';

  @override
  String get passwordNeedsSpecialChar => 'Weak (Needs special char)';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordModerate => 'Moderate';

  @override
  String get passwordFair => 'Fair';

  @override
  String get passwordGood => 'Good';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get passwordTips => 'Password Tips';

  @override
  String get passwordTipLength => 'Use at least 8 characters';

  @override
  String get passwordTipCase => 'Include uppercase and lowercase letters';

  @override
  String get passwordTipSpecial => 'Add numbers and special characters (e.g., !@#\$)';

  @override
  String get passwordTipAvoid => 'Avoid common words or personal info';

  @override
  String get changePasswordButton => 'Change Password';

  @override
  String get passwordChangedSuccess => 'Your password has been changed successfully. Please use your new password for future logins.';

  @override
  String get success => 'Success!';

  @override
  String get ok => 'OK';

  @override
  String get pleaseEnterCurrentPassword => 'Please enter your current password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters long';

  @override
  String get passwordNeedsSpecialCharacter => 'Password must contain at least one special character';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordSameAsCurrent => 'New password must be different from current password';

  @override
  String get failedToChangePassword => 'Failed to change password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get coachLoginTitle => 'Coach Login';

  @override
  String get teamManagementPortal => 'Team Management Portal';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'coach@example.com';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginAsCoach => 'Login as Coach';

  @override
  String get coachPortal => 'Coach Portal';

  @override
  String get coachPortalDescription => 'Exclusive access for coaches to manage athletes, schedules, and attendance.';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordTooShortLogin => 'Password must be at least 6 characters';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get accessDeniedCoachOnly => 'Access denied. Coaches only.';

  @override
  String get networkError => 'Network error. Please try again.';

  @override
  String get profileTitle => 'Coach Profile';

  @override
  String get loadingProfile => 'Loading profile...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get logout => 'Logout';

  @override
  String get branchAttendanceSummary => 'Branch Attendance Summary';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutMessage => 'Are you sure you want to logout?';

  @override
  String get confirm => 'Confirm';

  @override
  String get failedToLogout => 'Failed to logout';

  @override
  String get languageChangedToArabic => 'Language changed to Arabic';

  @override
  String get languageChangedToEnglish => 'Language changed to English';

  @override
  String get branchGroupTitle => 'Branch Group';

  @override
  String get loadingMessages => 'Loading messages...';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startConversation => 'Start the conversation! 👋';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get online => 'Online';

  @override
  String get unknownBranch => 'Unknown Branch';

  @override
  String get failedToSendMessage => 'Failed to send message';

  @override
  String get gearInformationTitle => 'Gear Information';

  @override
  String get editGearTitle => 'Edit Gear Information';

  @override
  String get gearDescription => 'This section is for the practice gear. The displayed gear is already present to the athletes. You can add whichever new gear you want to add and press update.';

  @override
  String get gearHintText => 'Enter gear requirements, equipment lists, or important notes...';

  @override
  String get updateGearButton => 'Update Gear Information';

  @override
  String get readOnlyMessage => 'Read Only • Only Head Coaches can edit gear';

  @override
  String get loadingGearInformation => 'Loading gear information...';

  @override
  String get unknownErrorOccurred => 'Unknown error occurred';

  @override
  String get updating => 'Updating...';

  @override
  String get gearUpdateSuccess => 'Gear information updated successfully!';

  @override
  String get gearUpdateFailed => 'Failed to update gear';

  @override
  String get weeklyAttendanceTitle => '🏊 Weekly Attendance';

  @override
  String get day1 => 'Day 1';

  @override
  String get day2 => 'Day 2';

  @override
  String get day3 => 'Day 3';

  @override
  String failedToGetUserProfile(Object error) {
    return 'Failed to get user profile: $error';
  }

  @override
  String get branchIdNotFound => 'Branch ID not found in user profile';

  @override
  String get failedToLoadUserProfile => 'Failed to load user profile';

  @override
  String get noSessionDatesConfigured => 'No session dates configured for this branch';

  @override
  String failedToLoadSessionDates(Object error) {
    return 'Failed to load session dates: $error';
  }

  @override
  String get failedToLoadSessionDatesGeneral => 'Failed to load session dates';

  @override
  String get sessionDateNotAvailable => 'Session date not available';

  @override
  String failedToLoadAttendance(Object error) {
    return 'Failed to load attendance: $error';
  }

  @override
  String get failedToLoadAttendanceGeneral => 'Failed to load attendance';

  @override
  String attendanceMarked(Object status) {
    return 'Attendance marked as $status';
  }

  @override
  String failedToUpdateAttendance(Object error) {
    return 'Failed to update attendance: $error';
  }

  @override
  String get failedToUpdateAttendanceGeneral => 'Failed to update attendance';

  @override
  String get loadingAttendance => 'Loading attendance...';

  @override
  String get noAthletesFound => 'No Athletes Found';

  @override
  String get noAttendanceDataForDay => 'No attendance data for this day';

  @override
  String get unknownAthlete => 'Unknown';

  @override
  String missedGear(Object notes) {
    return 'Missed gear: $notes';
  }

  @override
  String status(Object status) {
    return 'Status: $status';
  }

  @override
  String get didMissGear => 'Did the athlete miss any gear at practice?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get typeMissedGearHere => 'Type missed gear here...';

  @override
  String get submit => 'Submit';

  @override
  String get enterMissedGearNotes => 'Please enter missed gear notes';

  @override
  String get loadingRequests => 'Loading requests...';

  @override
  String get noPendingRequests => 'No Pending Requests';

  @override
  String get allRequestsProcessed => 'All registration requests have been processed';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String athletesWaitingApproval(Object count) {
    return '$count athlete(s) waiting for approval';
  }

  @override
  String failedToLoadRequests(Object error) {
    return 'Failed to load registration requests: $error';
  }

  @override
  String get failedToLoadRequestsGeneral => 'Failed to load registration requests';

  @override
  String get approveRegistration => 'Approve Registration';

  @override
  String approveRegistrationMessage(Object athlete) {
    return 'Are you sure you want to approve $athlete\'s registration request?';
  }

  @override
  String get approve => 'Approve';

  @override
  String get registrationApproved => 'Registration approved successfully!';

  @override
  String failedToApproveRegistration(Object error) {
    return 'Failed to approve registration: $error';
  }

  @override
  String get failedToApproveRegistrationGeneral => 'Failed to approve registration';

  @override
  String get rejectRegistration => 'Reject Registration';

  @override
  String rejectRegistrationMessage(Object athlete) {
    return 'Are you sure you want to reject $athlete\'s registration request?\n\nThis action cannot be undone.';
  }

  @override
  String get reject => 'Reject';

  @override
  String get registrationRejected => 'Registration request rejected';

  @override
  String failedToRejectRegistration(Object error) {
    return 'Failed to reject registration: $error';
  }

  @override
  String get failedToRejectRegistrationGeneral => 'Failed to reject registration';

  @override
  String get pending => 'Pending';

  @override
  String get processing => 'Processing...';

  @override
  String get unknown => 'Unknown';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String submitted(Object date) {
    return 'Submitted $date';
  }

  @override
  String get noEmail => 'No email';

  @override
  String get noPhone => 'No phone';

  @override
  String get monthlyAttendance => 'Monthly Attendance';

  @override
  String get loadingAthletes => 'Loading athletes and attendance...';

  @override
  String get errorLoadingAthletes => 'Error Loading Athletes';

  @override
  String get noAthletesRegistered => 'No athletes are registered in this branch';

  @override
  String get monthlyAttendanceOverview => 'Monthly Attendance Overview';

  @override
  String athletesInBranch(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count athletes in your branch',
      one: '1 athlete in your branch',
    );
    return '$_temp0';
  }

  @override
  String get searchAthletes => 'Search athletes...';

  @override
  String failedToLoadAthletes(Object error) {
    return 'Failed to load athletes: $error';
  }

  @override
  String get failedToLoadAthletesGeneral => 'Failed to load athletes';

  @override
  String get athletesManagement => 'Athletes Management';

  @override
  String athleteId(Object id) {
    return 'ID: $id';
  }

  @override
  String get deleteAthlete => 'Delete Athlete';

  @override
  String deleteAthleteConfirm(Object name) {
    return 'Are you sure you want to permanently delete $name?';
  }

  @override
  String get deleteAthleteWarning => '⚠️ This action cannot be undone!';

  @override
  String get deleteAthleteDetails => '• The athlete will lose access to their account forever\n• All their data will be permanently removed\n• This action is irreversible';

  @override
  String get delete => 'Delete Forever';

  @override
  String deleteAthleteSuccess(Object name) {
    return '$name has been permanently deleted';
  }

  @override
  String deleteAthleteFailed(Object error) {
    return 'Failed to delete athlete: $error';
  }

  @override
  String athletesInAcademy(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count athletes in academy',
      one: '1 athlete in academy',
    );
    return '$_temp0';
  }

  @override
  String get invalidId => 'Invalid athlete ID';

  @override
  String get athlete => 'Athlete';

  @override
  String get presentWithGear => 'Present + Gear';

  @override
  String get presentWithoutGear => 'Present - Gear';

  @override
  String get absent => 'Absent';

  @override
  String get monthlyStatistics => 'Monthly Statistics';

  @override
  String get attendanceRate => 'Attendance Rate';

  @override
  String get daysPresent => 'Days Present';

  @override
  String get daysAbsent => 'Days Absent';

  @override
  String get gearIssues => 'Gear Issues';

  @override
  String get missedGearDetails => 'Missed Gear Details';

  @override
  String get perfectNoGearMissed => 'Perfect! No gear was missed this month.';

  @override
  String get notes => 'Notes:';

  @override
  String get daysOfWeek => 'Sun,Mon,Tue,Wed,Thu,Fri,Sat';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get performanceLogs => 'Performance Logs';

  @override
  String get athletePerformanceLogs => 'Athlete Performance Logs';

  @override
  String get noAthletesRegisteredBranch => 'No athletes are registered in this branch';

  @override
  String get viewTimes => 'View Times';

  @override
  String idField(Object id) {
    return 'ID: $id';
  }

  @override
  String get loadingPerformanceLogs => 'Loading performance logs...';

  @override
  String get errorLoadingPerformanceLogs => 'Error Loading Performance Logs';

  @override
  String get noPerformanceLogs => 'No Performance Logs';

  @override
  String get noPerformanceRecords => 'No performance records found for this athlete';

  @override
  String get performance => 'Performance';

  @override
  String performanceRecord(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count performance records',
      one: '1 performance record',
    );
    return '$_temp0';
  }

  @override
  String get unknownEvent => 'Unknown Event';

  @override
  String get noTime => 'No time';

  @override
  String get trainingSession => 'Training Session';

  @override
  String get paymentManagement => 'Payment Management';

  @override
  String get loadingPaymentData => 'Loading payment data...';

  @override
  String get errorLoadingPaymentData => 'Error Loading Payment Data';

  @override
  String get monthlyPaymentStatus => 'Monthly Payment Status';

  @override
  String get paid => 'Paid';

  @override
  String get late => 'Late';

  @override
  String get current => 'Current:';

  @override
  String get paymentStatusUpdated => 'Payment status updated successfully';

  @override
  String failedToUpdatePaymentStatus(Object error) {
    return 'Failed to update payment status: $error';
  }

  @override
  String get athletesMeasurements => 'Athletes Measurements';

  @override
  String get measurements => 'Measurements';

  @override
  String get loadingMeasurements => 'Loading measurements...';

  @override
  String get errorLoadingMeasurements => 'Error Loading Measurements';

  @override
  String get noMeasurements => 'No Measurements';

  @override
  String get noMeasurementsForAthlete => 'No measurements found for this athlete';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get measurementRecord => 'measurement record';

  @override
  String get measurementRecords => 'measurement records';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get arm => 'Arm';

  @override
  String get leg => 'Leg';

  @override
  String get fat => 'Fat %';

  @override
  String get muscle => 'Muscle %';

  @override
  String get notRecorded => 'Not recorded';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get validEmail => 'Please enter a valid email';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get signInBtn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String unknownUserType(Object userType) {
    return 'Unknown user type: $userType';
  }

  @override
  String get branchChat => 'Branch Chat';

  @override
  String get branchDiscussion => 'Branch Discussion';

  @override
  String get loadingThreads => 'Loading chat threads...';

  @override
  String get failedToLoadThreads => 'Failed to load chat threads';

  @override
  String get networkErrorLoadingThreads => 'Network error loading threads';

  @override
  String get userBranchInfoNotAvailable => 'User branch information not available';

  @override
  String get failedToLoadMessages => 'Failed to load messages';

  @override
  String get networkErrorLoadingMessages => 'Network error loading messages';

  @override
  String get readOnlyMode => 'You are viewing this chat in read-only mode.';

  @override
  String get noChatThreadsYet => 'No Chat Threads Yet';

  @override
  String get createFirstDiscussion => 'Create the first discussion thread for your branch';

  @override
  String get coachHasNotCreatedThreads => 'Your coach hasn\'t created any threads yet';

  @override
  String get createThread => 'Create Thread';

  @override
  String get selectAThread => 'Select a Thread';

  @override
  String get tapSwitchToChoose => 'Tap \"Switch\" in the header to choose a conversation';

  @override
  String get waitForCoach => 'Be the first to say something or wait for your coach!';

  @override
  String get switchThread => 'Switch';

  @override
  String get selectChatThread => 'Select Chat Thread';

  @override
  String get untitledThread => 'Untitled Thread';

  @override
  String get created => 'Created';

  @override
  String get createNewThread => 'Create New Thread';

  @override
  String get threadTitleHint => 'e.g., \"Weekly Training Discussion\"';

  @override
  String get threadTitleCannotBeEmpty => 'Thread title cannot be empty!';

  @override
  String get create => 'Create';

  @override
  String get threadCreatedSuccessfully => 'Thread created successfully! 🎉';

  @override
  String get failedToCreateThread => 'Failed to create thread';

  @override
  String get todayAt => 'Today at';

  @override
  String get yesterdayAt => 'Yesterday at';

  @override
  String get you => 'You';

  @override
  String get coachBranchAssignment => 'Coach Branch Assignment';

  @override
  String get assignCoachesTitle => 'Assign Coaches';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get loadingCoaches => 'Loading coaches...';

  @override
  String get noCoachesFound => 'No Coaches Found';

  @override
  String get noCoachesAvailable => 'No coaches are available for assignment';

  @override
  String get coachAssignmentsTitle => 'Coach Assignments';

  @override
  String coachesInSystem(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coaches in the system',
      one: '$count coach in the system',
    );
    return '$_temp0';
  }

  @override
  String get searchCoachesHint => 'Search coaches...';

  @override
  String get assignedStat => 'Assigned';

  @override
  String get unassignedStat => 'Unassigned';

  @override
  String get multiBranchStat => 'Multi-Branch';

  @override
  String noCoachesForQuery(Object query) {
    return 'No coaches found for \"$query\"';
  }

  @override
  String failedToLoadCoaches(Object error) {
    return 'Failed to load coaches: $error';
  }

  @override
  String failedToLoadStats(Object error) {
    return 'Failed to load assignment stats: $error';
  }

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String branchesAssignedTo(Object coachName) {
    return 'Branches assigned to $coachName';
  }

  @override
  String get noBranchesFound => 'No branches found';

  @override
  String get assignButton => 'Assign';

  @override
  String get unassignButton => 'Unassign';

  @override
  String get backButton => 'Back';

  @override
  String get errorLoadingBranches => 'Error loading branches';

  @override
  String get failedToAssign => 'Failed to assign';

  @override
  String get failedToUnassign => 'Failed to unassign';

  @override
  String get branchAssigned => 'Branch assigned';

  @override
  String get branchUnassigned => 'Branch unassigned';

  @override
  String get gearUpdates => 'Gear Updates';

  @override
  String get latestGearUpdates => 'Latest Gear Updates';

  @override
  String get noGearUpdates => 'No Gear Updates';

  @override
  String get noGearUpdatesDesc => 'Your coach hasn\'t posted any gear updates yet. Check back later!';

  @override
  String get coachUpdate => 'Coach Update';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get shareFeatureComingSoon => 'Share feature coming soon!';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }
}
