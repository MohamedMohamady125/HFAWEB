// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نادي السباحة HFA';

  @override
  String get home => 'الرئيسية';

  @override
  String get threads => 'المحادثات';

  @override
  String get gear => 'الأدوات ';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String welcome(Object name) {
    return 'مرحباً $name';
  }

  @override
  String get coachDashboard => 'لوحة المدرب';

  @override
  String get loadingDashboard => 'جاري تحميل اللوحة...';

  @override
  String get myDashboard => 'لوحتي';

  @override
  String get welcomeBack => '👋 مرحباً بعودتك!';

  @override
  String todayIs(Object day, Object month, Object year) {
    return 'اليوم هو $day $month $year';
  }

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get latePayment => 'دفعة متأخرة';

  @override
  String get user => 'المستخدم';

  @override
  String get key => 'المفتاح';

  @override
  String get present => 'حاضر';

  @override
  String get noGear => 'بدون ادوات';

  @override
  String get noTrainingSession => 'لا توجد جلسة تدريب';

  @override
  String get daysOfWeekShort => 'أ,ث,ث,ر,خ,ج,س';

  @override
  String get failedToLoadProfile => 'فشل في تحميل الملف الشخصي';

  @override
  String get failedToLoadProfileData => 'فشل في تحميل بيانات الملف الشخصي';

  @override
  String get registrationRequests => 'طلبات التسجيل';

  @override
  String get attendance => 'الحضور';

  @override
  String get weeklyAttendance => 'الحضور الأسبوعي';

  @override
  String get attendanceCalendar => 'تقويم الحضور';

  @override
  String get monthlyAttendanceCalendar => 'تقويم الحضور الشهري';

  @override
  String get athletesList => 'قائمة الرياضيين';

  @override
  String get swimMeetPerformance => 'أداء المسابقات';

  @override
  String get attendanceSeason => 'موسم الحضور';

  @override
  String get payments => 'المدفوعات';

  @override
  String get switchBranch => 'تغيير الفرع';

  @override
  String featureComingSoon(Object feature) {
    return 'ميزة $feature قريباً!';
  }

  @override
  String comingSoon(Object feature) {
    return 'ميزة $feature قريباً!';
  }

  @override
  String comingSoonFeature(Object feature) {
    return 'ميزة $feature قريباً!';
  }

  @override
  String get switchBranchTitle => 'تغيير الفرع';

  @override
  String get loadingBranches => 'جاري تحميل الفروع...';

  @override
  String get noBranchesAvailable => 'لا توجد فروع متاحة';

  @override
  String get noBranchesDescription => 'لا توجد فروع مكونة في النظام.';

  @override
  String get currentBranch => 'الفرع الحالي';

  @override
  String get active => 'نشط';

  @override
  String get switchToBranch => 'التبديل إلى الفرع';

  @override
  String get switching => 'جاري التبديل...';

  @override
  String get branchDetails => 'تفاصيل الفرع';

  @override
  String get close => 'إغلاق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get switchButton => 'تبديل';

  @override
  String get address => 'العنوان';

  @override
  String get phone => 'الهاتف';

  @override
  String get practiceDays => 'أيام التدريب';

  @override
  String branchId(Object branchId) {
    return 'رقم الفرع: $branchId';
  }

  @override
  String get videoUrl => 'رابط الفيديو';

  @override
  String alreadyManaging(Object branchName) {
    return 'أنت تدير بالفعل $branchName';
  }

  @override
  String switchBranchConfirm(Object branchName) {
    return 'التبديل إلى $branchName؟';
  }

  @override
  String switchBranchDescription(Object branchName) {
    return 'سيؤدي هذا إلى تحديث جميع عروض البيانات لإظهار معلومات $branchName.';
  }

  @override
  String switchedToBranch(Object branchName) {
    return 'تم التبديل إلى $branchName';
  }

  @override
  String get failedToLoadBranches => 'فشل في تحميل الفروع';

  @override
  String get failedToSwitchBranch => 'فشل في تغيير الفرع';

  @override
  String get refresh => 'تحديث';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get securitySettings => 'إعدادات الأمان';

  @override
  String get updatePasswordPrompt => 'قم بتحديث كلمة المرور للحفاظ على أمان حسابك';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get enterCurrentPassword => 'أدخل كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get newPasswordHint => '8 أحرف على الأقل، تتضمن رمز خاص';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور الجديدة';

  @override
  String get passwordStrength => 'قوة كلمة المرور';

  @override
  String get passwordTooShort => 'قصيرة جداً (8 أحرف على الأقل)';

  @override
  String get passwordNeedsSpecialChar => 'ضعيفة (تحتاج رمز خاص)';

  @override
  String get passwordWeak => 'ضعيفة';

  @override
  String get passwordModerate => 'متوسطة';

  @override
  String get passwordFair => 'مقبولة';

  @override
  String get passwordGood => 'جيدة';

  @override
  String get passwordStrong => 'قوية';

  @override
  String get passwordTips => 'نصائح كلمة المرور';

  @override
  String get passwordTipLength => 'استخدم 8 أحرف على الأقل';

  @override
  String get passwordTipCase => 'أدرج الأحرف الكبيرة والصغيرة';

  @override
  String get passwordTipSpecial => 'أضف أرقام ورموز خاصة (مثل !@#\$)';

  @override
  String get passwordTipAvoid => 'تجنب الكلمات الشائعة أو المعلومات الشخصية';

  @override
  String get changePasswordButton => 'تغيير كلمة المرور';

  @override
  String get passwordChangedSuccess => 'تم تغيير كلمة المرور بنجاح. يرجى استخدام كلمة المرور الجديدة في عمليات تسجيل الدخول المستقبلية.';

  @override
  String get success => 'نجح!';

  @override
  String get ok => 'موافق';

  @override
  String get pleaseEnterCurrentPassword => 'يرجى إدخال كلمة المرور الحالية';

  @override
  String get pleaseEnterNewPassword => 'يرجى إدخال كلمة مرور جديدة';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordNeedsSpecialCharacter => 'يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordSameAsCurrent => 'يجب أن تكون كلمة المرور الجديدة مختلفة عن الحالية';

  @override
  String get failedToChangePassword => 'فشل في تغيير كلمة المرور';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get coachLoginTitle => 'تسجيل دخول المدرب';

  @override
  String get teamManagementPortal => 'بوابة إدارة الفريق';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get emailHint => 'coach@example.com';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginAsCoach => 'تسجيل الدخول كمدرب';

  @override
  String get coachPortal => 'بوابة المدرب';

  @override
  String get coachPortalDescription => 'وصول حصري للمدربين لإدارة الرياضيين والجداول والحضور.';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordTooShortLogin => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get accessDeniedCoachOnly => 'تم رفض الوصول. المدربون فقط.';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى المحاولة مرة أخرى.';

  @override
  String get profileTitle => 'ملف المدرب الشخصي';

  @override
  String get loadingProfile => 'جاري تحميل الملف الشخصي...';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get quickActions => 'الإجراءات السريعة';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get branchAttendanceSummary => 'ملخص حضور الفرع';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get logoutMessage => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get confirm => 'تأكيد';

  @override
  String get failedToLogout => 'فشل في تسجيل الخروج';

  @override
  String get languageChangedToArabic => 'تم تغيير اللغة إلى العربية';

  @override
  String get languageChangedToEnglish => 'تم تغيير اللغة إلى الإنجليزية';

  @override
  String get branchGroupTitle => 'مجموعة الفرع';

  @override
  String get loadingMessages => 'جاري تحميل الرسائل...';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get startConversation => 'ابدأ المحادثة! 👋';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get typeAMessage => 'اكتب رسالة...';

  @override
  String get online => 'متصل';

  @override
  String get unknownBranch => 'فرع غير معروف';

  @override
  String get failedToSendMessage => 'فشل في إرسال الرسالة';

  @override
  String get gearInformationTitle => 'معلومات الأدوات';

  @override
  String get editGearTitle => 'تحرير معلومات الأدوات';

  @override
  String get gearDescription => 'هذا القسم خاص بمعدات التدريب. الأدوات المعروضة موجودة بالفعل للرياضيين. يمكنك إضافة أي معدات جديدة تريد إضافتها والضغط على تحديث.';

  @override
  String get gearHintText => 'أدخل متطلبات الأدوات أو قوائم الأدوات أو الملاحظات المهمة...';

  @override
  String get updateGearButton => 'تحديث معلومات الأدوات';

  @override
  String get readOnlyMessage => 'للقراءة فقط • المدربين الرئيسيين فقط يمكنهم تحرير الأدوات';

  @override
  String get loadingGearInformation => 'جاري تحميل معلومات الأدوات...';

  @override
  String get unknownErrorOccurred => 'حدث خطأ غير معروف';

  @override
  String get updating => 'جاري التحديث...';

  @override
  String get gearUpdateSuccess => 'تم تحديث معلومات الأدوات بنجاح!';

  @override
  String get gearUpdateFailed => 'فشل في تحديث الأدوات';

  @override
  String get weeklyAttendanceTitle => '🏊 الحضور الأسبوعي';

  @override
  String get day1 => 'اليوم 1';

  @override
  String get day2 => 'اليوم 2';

  @override
  String get day3 => 'اليوم 3';

  @override
  String failedToGetUserProfile(Object error) {
    return 'فشل في الحصول على ملف المستخدم: $error';
  }

  @override
  String get branchIdNotFound => 'لم يتم العثور على رقم الفرع في ملف المستخدم';

  @override
  String get failedToLoadUserProfile => 'فشل في تحميل ملف المستخدم';

  @override
  String get noSessionDatesConfigured => 'لا توجد تواريخ جلسات مكونة لهذا الفرع';

  @override
  String failedToLoadSessionDates(Object error) {
    return 'فشل في تحميل تواريخ الجلسات: $error';
  }

  @override
  String get failedToLoadSessionDatesGeneral => 'فشل في تحميل تواريخ الجلسات';

  @override
  String get sessionDateNotAvailable => 'تاريخ الجلسة غير متوفر';

  @override
  String failedToLoadAttendance(Object error) {
    return 'فشل في تحميل الحضور: $error';
  }

  @override
  String get failedToLoadAttendanceGeneral => 'فشل في تحميل الحضور';

  @override
  String attendanceMarked(Object status) {
    return 'تم تسجيل الحضور كـ $status';
  }

  @override
  String failedToUpdateAttendance(Object error) {
    return 'فشل في تحديث الحضور: $error';
  }

  @override
  String get failedToUpdateAttendanceGeneral => 'فشل في تحديث الحضور';

  @override
  String get loadingAttendance => 'جاري تحميل الحضور...';

  @override
  String get noAthletesFound => 'لم يتم العثور على رياضيين';

  @override
  String get noAttendanceDataForDay => 'لا توجد بيانات حضور لهذا اليوم';

  @override
  String get unknownAthlete => 'غير معروف';

  @override
  String missedGear(Object notes) {
    return 'معدات مفقودة: $notes';
  }

  @override
  String status(Object status) {
    return 'الحالة: $status';
  }

  @override
  String get didMissGear => 'هل فقد الرياضي أي معدات في التدريب؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get typeMissedGearHere => 'اكتب الأدوات المفقودة هنا...';

  @override
  String get submit => 'إرسال';

  @override
  String get enterMissedGearNotes => 'يرجى إدخال ملاحظات الأدوات المفقودة';

  @override
  String get loadingRequests => 'جاري تحميل الطلبات...';

  @override
  String get noPendingRequests => 'لا توجد طلبات معلقة';

  @override
  String get allRequestsProcessed => 'تم معالجة جميع طلبات التسجيل';

  @override
  String get pendingRequests => 'الطلبات المعلقة';

  @override
  String athletesWaitingApproval(Object count) {
    return '$count رياضي(ين) في انتظار الموافقة';
  }

  @override
  String failedToLoadRequests(Object error) {
    return 'فشل في تحميل طلبات التسجيل: $error';
  }

  @override
  String get failedToLoadRequestsGeneral => 'فشل في تحميل طلبات التسجيل';

  @override
  String get approveRegistration => 'الموافقة على التسجيل';

  @override
  String approveRegistrationMessage(Object athlete) {
    return 'هل أنت متأكد من رغبتك في الموافقة على طلب تسجيل $athlete؟';
  }

  @override
  String get approve => 'موافقة';

  @override
  String get registrationApproved => 'تمت الموافقة على التسجيل بنجاح!';

  @override
  String failedToApproveRegistration(Object error) {
    return 'فشل في الموافقة على التسجيل: $error';
  }

  @override
  String get failedToApproveRegistrationGeneral => 'فشل في الموافقة على التسجيل';

  @override
  String get rejectRegistration => 'رفض التسجيل';

  @override
  String rejectRegistrationMessage(Object athlete) {
    return 'هل أنت متأكد من رغبتك في رفض طلب تسجيل $athlete؟\n\nهذا الإجراء لا يمكن التراجع عنه.';
  }

  @override
  String get reject => 'رفض';

  @override
  String get registrationRejected => 'تم رفض طلب التسجيل';

  @override
  String failedToRejectRegistration(Object error) {
    return 'فشل في رفض التسجيل: $error';
  }

  @override
  String get failedToRejectRegistrationGeneral => 'فشل في رفض التسجيل';

  @override
  String get pending => 'معلق';

  @override
  String get processing => 'جاري المعالجة...';

  @override
  String get unknown => 'غير معروف';

  @override
  String get invalidDate => 'تاريخ غير صحيح';

  @override
  String submitted(Object date) {
    return 'تم الإرسال $date';
  }

  @override
  String get noEmail => 'لا يوجد بريد إلكتروني';

  @override
  String get noPhone => 'لا يوجد هاتف';

  @override
  String get monthlyAttendance => 'الحضور الشهري';

  @override
  String get loadingAthletes => 'جاري تحميل الرياضيين والحضور...';

  @override
  String get errorLoadingAthletes => 'خطأ في تحميل الرياضيين';

  @override
  String get noAthletesRegistered => 'لا يوجد رياضيون مسجلون في هذا الفرع';

  @override
  String get monthlyAttendanceOverview => 'نظرة عامة على الحضور الشهري';

  @override
  String athletesInBranch(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رياضي في فرعك',
      one: 'رياضي واحد في فرعك',
    );
    return '$_temp0';
  }

  @override
  String get searchAthletes => 'البحث عن الرياضيين...';

  @override
  String failedToLoadAthletes(Object error) {
    return 'فشل في تحميل الرياضيين: $error';
  }

  @override
  String get failedToLoadAthletesGeneral => 'فشل في تحميل الرياضيين';

  @override
  String get athletesManagement => 'إدارة الرياضيين';

  @override
  String athleteId(Object id) {
    return 'الرقم: $id';
  }

  @override
  String get deleteAthlete => 'حذف الرياضي';

  @override
  String deleteAthleteConfirm(Object name) {
    return 'هل أنت متأكد من رغبتك في حذف $name نهائياً؟';
  }

  @override
  String get deleteAthleteWarning => '⚠️ هذا الإجراء لا يمكن التراجع عنه!';

  @override
  String get deleteAthleteDetails => '• سيفقد الرياضي الوصول إلى حسابه للأبد\n• سيتم حذف جميع بياناته نهائياً\n• هذا الإجراء غير قابل للعكس';

  @override
  String get delete => 'حذف نهائياً';

  @override
  String deleteAthleteSuccess(Object name) {
    return 'تم حذف $name نهائياً';
  }

  @override
  String deleteAthleteFailed(Object error) {
    return 'فشل في حذف الرياضي: $error';
  }

  @override
  String athletesInAcademy(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رياضي في الأكاديمية',
      one: 'رياضي واحد في الأكاديمية',
    );
    return '$_temp0';
  }

  @override
  String get invalidId => 'رقم رياضي غير صحيح';

  @override
  String get athlete => 'الرياضي';

  @override
  String get presentWithGear => 'حاضر + معدات';

  @override
  String get presentWithoutGear => 'حاضر - معدات';

  @override
  String get absent => 'غائب';

  @override
  String get monthlyStatistics => 'الإحصائيات الشهرية';

  @override
  String get attendanceRate => 'معدل الحضور';

  @override
  String get daysPresent => 'أيام الحضور';

  @override
  String get daysAbsent => 'أيام الغياب';

  @override
  String get gearIssues => 'مشاكل الأدوات';

  @override
  String get missedGearDetails => 'تفاصيل الأدوات المفقودة';

  @override
  String get perfectNoGearMissed => 'ممتاز! لم تُفقد أي معدات هذا الشهر.';

  @override
  String get notes => 'الملاحظات:';

  @override
  String get daysOfWeek => 'أ,ث,ث,ر,خ,ج,س';

  @override
  String get january => 'يناير';

  @override
  String get february => 'فبراير';

  @override
  String get march => 'مارس';

  @override
  String get april => 'أبريل';

  @override
  String get may => 'مايو';

  @override
  String get june => 'يونيو';

  @override
  String get july => 'يوليو';

  @override
  String get august => 'أغسطس';

  @override
  String get september => 'سبتمبر';

  @override
  String get october => 'أكتوبر';

  @override
  String get november => 'نوفمبر';

  @override
  String get december => 'ديسمبر';

  @override
  String get performanceLogs => 'سجلات الأداء';

  @override
  String get athletePerformanceLogs => 'سجلات أداء الرياضيين';

  @override
  String get noAthletesRegisteredBranch => 'لا يوجد رياضيون مسجلون في هذا الفرع';

  @override
  String get viewTimes => 'عرض الأوقات';

  @override
  String idField(Object id) {
    return 'الرقم: $id';
  }

  @override
  String get loadingPerformanceLogs => 'جاري تحميل سجلات الأداء...';

  @override
  String get errorLoadingPerformanceLogs => 'خطأ في تحميل سجلات الأداء';

  @override
  String get noPerformanceLogs => 'لا توجد سجلات أداء';

  @override
  String get noPerformanceRecords => 'لم يتم العثور على سجلات أداء لهذا الرياضي';

  @override
  String get performance => 'الأداء';

  @override
  String performanceRecord(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سجل أداء',
      one: 'سجل أداء واحد',
    );
    return '$_temp0';
  }

  @override
  String get unknownEvent => 'حدث غير معروف';

  @override
  String get noTime => 'لا يوجد وقت';

  @override
  String get trainingSession => 'جلسة تدريب';

  @override
  String get paymentManagement => 'إدارة المدفوعات';

  @override
  String get loadingPaymentData => 'جاري تحميل بيانات الدفع...';

  @override
  String get errorLoadingPaymentData => 'خطأ في تحميل بيانات الدفع';

  @override
  String get monthlyPaymentStatus => 'حالة الدفع الشهرية';

  @override
  String get paid => 'مدفوع';

  @override
  String get late => 'متأخر';

  @override
  String get current => 'الحالي:';

  @override
  String get paymentStatusUpdated => 'تم تحديث حالة الدفع بنجاح';

  @override
  String failedToUpdatePaymentStatus(Object error) {
    return 'فشل في تحديث حالة الدفع: $error';
  }

  @override
  String get athletesMeasurements => 'قياسات الرياضيين';

  @override
  String get measurements => 'القياسات';

  @override
  String get loadingMeasurements => 'جاري تحميل القياسات...';

  @override
  String get errorLoadingMeasurements => 'خطأ في تحميل القياسات';

  @override
  String get noMeasurements => 'لا توجد قياسات';

  @override
  String get noMeasurementsForAthlete => 'لم يتم العثور على قياسات لهذا الرياضي';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get measurementRecord => 'سجل قياس';

  @override
  String get measurementRecords => 'سجلات قياس';

  @override
  String get height => 'الطول';

  @override
  String get weight => 'الوزن';

  @override
  String get arm => 'الذراع';

  @override
  String get leg => 'الساق';

  @override
  String get fat => 'نسبة الدهون %';

  @override
  String get muscle => 'نسبة العضلات %';

  @override
  String get notRecorded => 'غير مسجل';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signInToAccount => 'سجل الدخول إلى حسابك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get validEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get enterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get signInBtn => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String unknownUserType(Object userType) {
    return 'نوع مستخدم غير معروف: $userType';
  }

  @override
  String get branchChat => 'محادثة الفرع';

  @override
  String get branchDiscussion => 'مناقشة الفرع';

  @override
  String get loadingThreads => 'جاري تحميل خيوط الدردشة...';

  @override
  String get failedToLoadThreads => 'فشل في تحميل خيوط الدردشة';

  @override
  String get networkErrorLoadingThreads => 'خطأ في الشبكة أثناء تحميل الخيوط';

  @override
  String get userBranchInfoNotAvailable => 'معلومات فرع المستخدم غير متاحة';

  @override
  String get failedToLoadMessages => 'فشل في تحميل الرسائل';

  @override
  String get networkErrorLoadingMessages => 'خطأ في الشبكة أثناء تحميل الرسائل';

  @override
  String get readOnlyMode => 'أنت تشاهد هذه المحادثة في وضع القراءة فقط.';

  @override
  String get noChatThreadsYet => 'لا توجد خيوط دردشة بعد';

  @override
  String get createFirstDiscussion => 'أنشئ أول خيط مناقشة لفرعك';

  @override
  String get coachHasNotCreatedThreads => 'لم ينشئ مدربك أي خيوط بعد';

  @override
  String get createThread => 'إنشاء خيط';

  @override
  String get selectAThread => 'اختر خيطاً';

  @override
  String get tapSwitchToChoose => 'اضغط \"تبديل\" في الرأس لاختيار محادثة';

  @override
  String get waitForCoach => 'كن أول من يقول شيئاً أو انتظر مدربك!';

  @override
  String get switchThread => 'تبديل';

  @override
  String get selectChatThread => 'اختر خيط الدردشة';

  @override
  String get untitledThread => 'خيط بدون عنوان';

  @override
  String get created => 'تم الإنشاء';

  @override
  String get createNewThread => 'إنشاء خيط جديد';

  @override
  String get threadTitleHint => 'مثال: \"مناقشة التدريب الأسبوعية\"';

  @override
  String get threadTitleCannotBeEmpty => 'عنوان الخيط لا يمكن أن يكون فارغاً!';

  @override
  String get create => 'إنشاء';

  @override
  String get threadCreatedSuccessfully => 'تم إنشاء الخيط بنجاح! 🎉';

  @override
  String get failedToCreateThread => 'فشل في إنشاء الخيط';

  @override
  String get todayAt => 'اليوم في';

  @override
  String get yesterdayAt => 'أمس في';

  @override
  String get you => 'أنت';

  @override
  String get coachBranchAssignment => 'تعيين فرع المدرب';

  @override
  String get assignCoachesTitle => 'تعيين المدربين';

  @override
  String get refreshTooltip => 'تحديث';

  @override
  String get loadingCoaches => 'جاري تحميل المدربين...';

  @override
  String get noCoachesFound => 'لم يتم العثور على مدربين';

  @override
  String get noCoachesAvailable => 'لا يوجد مدربون متاحون للتعيين';

  @override
  String get coachAssignmentsTitle => 'تعيينات المدربين';

  @override
  String coachesInSystem(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مدرب في النظام',
      one: 'مدرب واحد في النظام',
    );
    return '$_temp0';
  }

  @override
  String get searchCoachesHint => 'البحث عن المدربين...';

  @override
  String get assignedStat => 'معين';

  @override
  String get unassignedStat => 'غير معين';

  @override
  String get multiBranchStat => 'متعدد الفروع';

  @override
  String noCoachesForQuery(Object query) {
    return 'لم يتم العثور على مدربين لـ \"$query\"';
  }

  @override
  String failedToLoadCoaches(Object error) {
    return 'فشل في تحميل المدربين: $error';
  }

  @override
  String failedToLoadStats(Object error) {
    return 'فشل في تحميل إحصائيات التعيين: $error';
  }

  @override
  String get failedToLoadData => 'فشل في تحميل البيانات';

  @override
  String branchesAssignedTo(Object coachName) {
    return 'الفروع المعينة لـ $coachName';
  }

  @override
  String get noBranchesFound => 'لم يتم العثور على فروع';

  @override
  String get assignButton => 'تعيين';

  @override
  String get unassignButton => 'إلغاء التعيين';

  @override
  String get backButton => 'رجوع';

  @override
  String get errorLoadingBranches => 'خطأ في تحميل الفروع';

  @override
  String get failedToAssign => 'فشل في التعيين';

  @override
  String get failedToUnassign => 'فشل في إلغاء التعيين';

  @override
  String get branchAssigned => 'تم تعيين الفرع';

  @override
  String get branchUnassigned => 'تم إلغاء تعيين الفرع';

  @override
  String get gearUpdates => 'تحديثات الأدوات ';

  @override
  String get latestGearUpdates => 'أحدث تحديثات الأدوات';

  @override
  String get noGearUpdates => 'لا توجد تحديثات معدات';

  @override
  String get noGearUpdatesDesc => 'لم ينشر مدربك أي تحديثات معدات بعد. تحقق لاحقاً!';

  @override
  String get coachUpdate => 'تحديث المدرب';

  @override
  String get save => 'حفظ';

  @override
  String get share => 'مشاركة';

  @override
  String get shareFeatureComingSoon => 'ميزة المشاركة قريباً!';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String daysAgo(Object days) {
    return 'منذ $days أيام';
  }
}
