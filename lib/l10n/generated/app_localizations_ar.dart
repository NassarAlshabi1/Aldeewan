// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'الديوان';

  @override
  String get appTitle => 'الديوان';

  @override
  String get appSlogan => 'إدارة مالية آمنة';

  @override
  String get home => 'الرئيسية';

  @override
  String get ledger => 'الدفتر';

  @override
  String get cashbook => 'الصندوق';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get featureManageCash => 'إدارة النقد والحسابات';

  @override
  String get featureTrackDebts => 'تتبع الديون والأشخاص';

  @override
  String get featureAnalytics => 'تحليلات مالية';

  @override
  String get featureBackup => 'نسخ احتياطي آمن';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get general => 'عام';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get search => 'بحث...';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get addPersonPrompt => 'تحتاج إلى إضافة شخص قبل إضافة معاملة';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get backupData => 'نسخ احتياطي (JSON)';

  @override
  String get backupDataSubtitle => 'تصدير جميع البيانات إلى ملف JSON';

  @override
  String get restoreData => 'استعادة البيانات (JSON)';

  @override
  String get restoreDataSubtitle =>
      'استيراد البيانات من ملف JSON (يستبدل البيانات الحالية)';

  @override
  String get exportPersons => 'تصدير الأشخاص (CSV)';

  @override
  String get exportTransactions => 'تصدير المعاملات (CSV)';

  @override
  String get personStatement => 'كشف حساب';

  @override
  String get cashFlow => 'التدفق النقدي';

  @override
  String get aboutDeveloper => 'عن المطور';

  @override
  String get currency => 'العملة';

  @override
  String get currencyOptions => 'خيارات العملة';

  @override
  String get backupSuccess => 'تم إنشاء النسخة الاحتياطية بنجاح';

  @override
  String backupFailed(Object error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get restoreSuccess => 'تم استعادة البيانات بنجاح';

  @override
  String restoreFailed(Object error) {
    return 'فشل الاستعادة: $error';
  }

  @override
  String get exportSuccess => 'تم التصدير بنجاح';

  @override
  String exportFailed(Object error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get developerName => 'متآصل';

  @override
  String get developerEmail => 'abdo13-m.azme@hotmail.com';

  @override
  String get version => 'الإصدار';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get editTransaction => 'تعديل المعاملة';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get role => 'الدور';

  @override
  String get amount => 'المبلغ';

  @override
  String get date => 'التاريخ';

  @override
  String get note => 'ملاحظة';

  @override
  String get category => 'التصنيف';

  @override
  String get type => 'النوع';

  @override
  String get income => 'دخل';

  @override
  String get expense => 'صرف';

  @override
  String get selectPerson => 'اختر الشخص';

  @override
  String get noPersonsFound => 'لا يوجد أشخاص';

  @override
  String get customer => 'عميل';

  @override
  String get supplier => 'مورد';

  @override
  String get unknown => 'غير معروف';

  @override
  String get dateRange => 'الفترة الزمنية';

  @override
  String get selectDateRange => 'اختر الفترة';

  @override
  String get generateReport => 'إنشاء التقرير';

  @override
  String statementFor(Object name) {
    return 'كشف حساب $name';
  }

  @override
  String period(Object end, Object start) {
    return 'الفترة: $start - $end';
  }

  @override
  String get balanceBroughtForward => 'الرصيد المرحل';

  @override
  String get closingBalance => 'الرصيد الختامي';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get debt => 'دين (لنا)';

  @override
  String get payment => 'دفعة';

  @override
  String get credit => 'دين (علينا)';

  @override
  String get transaction => 'معاملة';

  @override
  String get totalIncome => 'إجمالي الدخل';

  @override
  String get totalExpense => 'إجمالي المصروفات';

  @override
  String get netProfitLoss => 'صافي الربح/الخسارة';

  @override
  String get cashFlowReport => 'تقرير التدفق النقدي';

  @override
  String get madeWithLove => 'صنع بـ ❤️ بواسطة متآصل';

  @override
  String appVersionInfo(String version) {
    return 'الديوان موبايل إصدار $version';
  }

  @override
  String get developerTagline =>
      'ميديا | تصوير | مونتاج | تصميم | ويب | تطوير برمجيات \"احترافية وجودة وفن\" #motaasl';

  @override
  String get openSourceLink => 'عرض على GitHub';

  @override
  String get islamicEndowment => 'هذا التطبيق وقف إسلامي خيري';

  @override
  String get facebook => 'فيسبوك';

  @override
  String get instagram => 'انستغرام';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get tagline => 'دفتر حساباتك الشخصي';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get addDebt => 'إضافة دين';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get addCashEntry => 'إضافة معاملة';

  @override
  String get viewBalances => 'عرض الأرصدة';

  @override
  String get allTransactions => 'كل المعاملات';

  @override
  String get recentActivity => 'أحدث المعاملات';

  @override
  String get noEntriesYet => 'لا توجد معاملات حتى الآن';

  @override
  String get totalReceivable => 'ديون لك';

  @override
  String get totalPayable => 'ديون عليك';

  @override
  String get moneyIn => 'الأموال الواردة';

  @override
  String get moneyOut => 'الأموال الصادرة';

  @override
  String get trueIncome => 'الدخل الحقيقي';

  @override
  String get trueExpense => 'المصروف الحقيقي';

  @override
  String get debtsSection => 'الديون';

  @override
  String get monthlySection => 'الحركة الشهرية';

  @override
  String get transactionDetails => 'تفاصيل المعاملة';

  @override
  String get deleteTransaction => 'حذف المعاملة';

  @override
  String get deleteTransactionConfirm => 'هل أنت متأكد من حذف هذه المعاملة؟';

  @override
  String get deletedSuccessfully => 'تم الحذف بنجاح';

  @override
  String get person => 'الشخص';

  @override
  String get savedSuccessfully => 'تم الحفظ بنجاح';

  @override
  String get cashLabel => 'نقد';

  @override
  String get bankLabel => 'بنك';

  @override
  String get camera => 'كاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get addToLedger => 'إضافة إلى الدفتر (دين/ائتمان)';

  @override
  String get addToLedgerSubtitle => 'يتطلب اختيار شخص';

  @override
  String get addToCashbook => 'إضافة إلى الصندوق (دخل/صرف)';

  @override
  String get addToCashbookSubtitle => 'لا يتطلب شخص';

  @override
  String get scanReceipt => 'مسح إيصال';

  @override
  String scanError(Object error) {
    return 'خطأ في مسح الإيصال: $error';
  }

  @override
  String get scanTimeout => 'انتهت مهلة المسح';

  @override
  String get totalSpent => 'إجمالي المصروف';

  @override
  String goalReached(Object percent) {
    return 'تم تحقيق $percent%';
  }

  @override
  String targetLabel(Object amount) {
    return 'الهدف: $amount';
  }

  @override
  String get goalProgress => 'تقدم الهدف';

  @override
  String budgetUsage(Object percentage) {
    return 'استخدام الميزانية $percentage';
  }

  @override
  String get pleaseEnterAmount => 'الرجاء إدخال المبلغ';

  @override
  String get invalidNumber => 'رقم غير صحيح';

  @override
  String get pleaseEnterName => 'الرجاء إدخال الاسم';

  @override
  String get me => 'أنا';

  @override
  String get netPosition => 'صافي المركز المالي';

  @override
  String get customersOweYouMore => 'العملاء مدينون لك بأكثر';

  @override
  String get youOweSuppliersMore => 'أنت مدين للموردين بأكثر';

  @override
  String get profitThisMonth => 'ربح هذا الشهر';

  @override
  String get lossThisMonth => 'خسارة هذا الشهر';

  @override
  String get all => 'الكل';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get custom => 'مخصص';

  @override
  String get saleOnCredit => 'بيع (آجل)';

  @override
  String get paymentReceived => 'استلام دفعة';

  @override
  String get purchaseOnCredit => 'شراء (آجل)';

  @override
  String get paymentMade => 'دفع دفعة';

  @override
  String get debtGiven => 'إقراض (دفعت له)';

  @override
  String get debtTaken => 'اقتراض (استلمت منه)';

  @override
  String get cashSale => 'بيع (نقد)';

  @override
  String get cashIncome => 'إيراد إضافي';

  @override
  String get cashExpense => 'مصروفات';

  @override
  String get currentBalance => 'الرصيد الحالي';

  @override
  String get settled => 'خالص';

  @override
  String get receivable => 'ديون لك';

  @override
  String get payable => 'ديون عليك';

  @override
  String get advance => 'رصيد مقدم';

  @override
  String get advanceOwesYou => 'لك (رصيد مقدم)';

  @override
  String get advanceYouOwe => 'عليك (رصيد مقدم)';

  @override
  String get analytics => 'التحليلات';

  @override
  String get budgets => 'الميزانيات';

  @override
  String get goals => 'الأهداف';

  @override
  String get linkAccount => 'ربط حساب';

  @override
  String get myAccounts => 'حساباتي';

  @override
  String get syncAccounts => 'مزامنة الحسابات';

  @override
  String get expensesByCategory => 'المصروفات حسب الفئة';

  @override
  String get budgetSummary => 'ملخص الميزانية';

  @override
  String get createBudget => 'إنشاء ميزانية';

  @override
  String get createGoal => 'إنشاء هدف';

  @override
  String get goalName => 'اسم الهدف';

  @override
  String get monthlyLimit => 'الحد الشهري';

  @override
  String get targetAmount => 'المبلغ المستهدف';

  @override
  String get currentSaved => 'المدخرات الحالية';

  @override
  String get addToGoal => 'إضافة للهدف';

  @override
  String get connectBank => 'ربط البنك';

  @override
  String get selectProvider => 'اختر المزود';

  @override
  String get noExpensesToShow => 'لا توجد مصروفات لعرضها';

  @override
  String get unlock => 'فتح القفل';

  @override
  String get appLocked => 'التطبيق مقفل';

  @override
  String get link => 'ربط';

  @override
  String get linkBankAccount => 'ربط حسابك البنكي';

  @override
  String get errorLoadingAccounts => 'خطأ في تحميل الحسابات';

  @override
  String get personNotFound => 'الشخص غير موجود';

  @override
  String get appLock => 'قفل التطبيق';

  @override
  String get appLockSubtitle => 'طلب المصادقة لفتح التطبيق';

  @override
  String get unlockApp => 'فتح التطبيق';

  @override
  String get accountLinkedSuccess => 'تم ربط الحساب بنجاح!';

  @override
  String get authFailed => 'فشلت المصادقة. يرجى التحقق من البيانات.';

  @override
  String get linkBankAccountTitle => 'ربط حساب بنكي';

  @override
  String get connectAccount => 'اتصال بالحساب';

  @override
  String errorOccurred(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get simpleMode => 'الوضع البسيط';

  @override
  String get simpleModeSubtitle => 'استخدام مصطلحات مبسطة (سلف/دين)';

  @override
  String get oldDebt => 'دين قديم / رصيد افتتاحي';

  @override
  String get oldDebtExplanation =>
      'استخدم هذا الخيار للديون التي كانت موجودة قبل استخدامك للتطبيق. سيتم تسجيل الدين في ملف الشخص ولكن لن يغير رصيدك النقدي/البنكي الحالي.';

  @override
  String get ok => 'حسناً';

  @override
  String get simpleLent => 'سلفته (لنا)';

  @override
  String get simpleBorrowed => 'تسلف منه (علينا)';

  @override
  String get simpleGotPaid => 'استلمت منه';

  @override
  String get simplePaidBack => 'سددت له';

  @override
  String get english => 'English';

  @override
  String get currencyQAR => 'ريال قطري (ر.ق)';

  @override
  String get currencySAR => 'ريال سعودي (ر.س)';

  @override
  String get currencyEGP => 'جنيه مصري (ج.م)';

  @override
  String get currencySDG => 'جنيه سوداني (ج.س)';

  @override
  String get currencyKWD => 'دينار كويتي (KWD)';

  @override
  String get loading => 'جاري التحميل';

  @override
  String get error => 'خطأ';

  @override
  String get deleteCategoryTitle => 'حذف الفئة؟';

  @override
  String deleteCategoryContent(Object categoryName) {
    return 'هل أنت متأكد أنك تريد حذف \"$categoryName\"؟';
  }

  @override
  String get newCategoryTitle => 'فئة جديدة';

  @override
  String get categoryType => 'النوع: ';

  @override
  String get selectColor => 'اختر لوناً';

  @override
  String get selectIcon => 'اختر أيقونة';

  @override
  String get create => 'إنشاء';

  @override
  String get active => 'نشط';

  @override
  String get history => 'السجل';

  @override
  String get overBudget => 'تجاوز الميزانية';

  @override
  String get remaining => 'المتبقي';

  @override
  String get spent => 'المصروف';

  @override
  String get limit => 'الحد';

  @override
  String get catHousing => 'السكن';

  @override
  String get catFood => 'الطعام';

  @override
  String get catTransportation => 'المواصلات';

  @override
  String get catHealth => 'الصحة';

  @override
  String get catEntertainment => 'الترفيه';

  @override
  String get catShopping => 'التسوق';

  @override
  String get catUtilities => 'الفواتير';

  @override
  String get catIncome => 'الدخل';

  @override
  String get catOther => 'أخرى';

  @override
  String get catSavings => 'المدخرات';

  @override
  String get manageCategories => 'إدارة الفئات';

  @override
  String budgetExceededMessage(String currency, String amount) {
    return 'لقد تجاوزت ميزانيتك بمقدار $currency $amount';
  }

  @override
  String budgetRemainingMessage(String currency, String amount) {
    return 'لديك $currency $amount متبقية';
  }

  @override
  String get deleteBudget => 'حذف الميزانية';

  @override
  String get deleteBudgetConfirmation =>
      'هل أنت متأكد أنك تريد حذف هذه الميزانية؟';

  @override
  String get deleteGoal => 'حذف الهدف';

  @override
  String get deleteGoalConfirmation => 'هل أنت متأكد أنك تريد حذف هذا الهدف؟';

  @override
  String get goalDetails => 'تفاصيل الهدف';

  @override
  String get budgetDetails => 'تفاصيل الميزانية';

  @override
  String get videoTutorials => 'فيديو تعليمي';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get hijriCalendar => 'التقويم الهجري الإسلامي';

  @override
  String get showHijriDate => 'عرض التاريخ الهجري';

  @override
  String get hijriAdjustment => 'تعديل التاريخ الهجري';

  @override
  String get hijriAdjustmentDesc => 'تعديل التاريخ الهجري بزيادة أو نقص أيام';

  @override
  String get days => 'أيام';

  @override
  String get deadline => 'الموعد النهائي';

  @override
  String get saved => 'المدخرات';

  @override
  String get target => 'الهدف';

  @override
  String get actions => 'الإجراءات';

  @override
  String get addFunds => 'إضافة أموال';

  @override
  String get withdraw => 'سحب';

  @override
  String get goalNotFound => 'الهدف غير موجود';

  @override
  String get budgetNotFound => 'الميزانية غير موجودة';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortNewest => 'الأحدث أولاً';

  @override
  String get sortOldest => 'الأقدم أولاً';

  @override
  String get sortHighestAmount => 'الأعلى مبلغاً';

  @override
  String get sortLowestAmount => 'الأقل مبلغاً';

  @override
  String get goalExceededError =>
      'لا يمكن إضافة الأموال. إجمالي المدخرات سيتجاوز المبلغ المستهدف.';

  @override
  String get budgetExceededError =>
      'لا يمكن إضافة المصروف. إجمالي المصروفات سيتجاوز حد الميزانية.';

  @override
  String goalExceededErrorWithRemaining(String amount) {
    return 'لا يمكن إضافة الأموال. يمكنك إضافة ما يصل إلى $amount فقط.';
  }

  @override
  String budgetExceededErrorWithRemaining(String amount) {
    return 'لا يمكن إضافة المصروف. لديك $amount فقط متبقية في هذه الميزانية.';
  }

  @override
  String get expenseBreakdown => 'تفاصيل المصروفات';

  @override
  String get editGoal => 'تعديل الهدف';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get noDate => 'لا يوجد تاريخ';

  @override
  String get editBudget => 'تعديل الميزانية';

  @override
  String get appSounds => 'أصوات التطبيق';

  @override
  String get appSoundsSubtitle => 'تشغيل أصوات عند الحفظ أو التنقل';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get clearAllConfirmTitle => 'مسح جميع الإشعارات؟';

  @override
  String get clearAllConfirmMessage => 'سيتم حذف جميع الإشعارات نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get clear => 'مسح';

  @override
  String get personCurrency => 'العملة';

  @override
  String get personCurrencyNote => 'سيتم تتبع معاملات هذا الشخص بهذه العملة.';

  @override
  String get personCurrencyDialogBody => 'استخدم العملة الافتراضية للتطبيق، أو اختر عملة محددة لهذا الشخص.';

  @override
  String get useAppDefault => 'استخدم الافتراضية';

  @override
  String get chooseCurrency => 'اختر عملة';

  @override
  String get appDefault => 'افتراضية';

  @override
  String personCurrencyBadge(String code) => 'العملة: $code';

  @override
  String get exchangeRates => 'أسعار الصرف';

  @override
  String get exchangeRatesSubtitle => 'حدد كم يساوي 1 وحدة من العملة الأساسية بالعملات الأخرى. يُستخدم لتقدير المجموع الكلي عبر العملات المختلطة.';

  @override
  String get baseCurrency => 'العملة الأساسية';

  @override
  String get rate => 'السعر';

  @override
  String rateHint(String base, String code) => '1 $base = كم $code';

  @override
  String get mixedTotalNote => 'المجاميع تجمع عملات مختلفة باستخدام الأسعار التي حددتها. وهي تقديرية فقط.';

  @override
  String get saveRate => 'حفظ السعر';

  @override
  String get inventory => 'المخزون';

  @override
  String get inventorySubtitle => 'تتبع المنتجات ومستويات المخزون والحركات';

  @override
  String get product => 'المنتج';

  @override
  String get products => 'المنتجات';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get sku => 'رمز المنتج (SKU)';

  @override
  String get category => 'الفئة';

  @override
  String get unit => 'الوحدة';

  @override
  String get costPrice => 'سعر التكلفة';

  @override
  String get salePrice => 'سعر البيع';

  @override
  String get lowStockThreshold => 'حد التنبيه لنقص المخزون';

  @override
  String get lowStockThresholdHint => 'تنبيه عند انخفاض الكمية المتوفرة إلى هذا الحد أو أقل. اتركه فارغاً لتعطيل التنبيه.';

  @override
  String get quantityOnHand => 'الكمية المتوفرة';

  @override
  String get inStock => 'متوفر';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get stockMovements => 'حركات المخزون';

  @override
  String get addStockMovement => 'تسجيل حركة مخزون';

  @override
  String get movementType => 'نوع الحركة';

  @override
  String get inbound => 'وارد (إضافة للمخزون)';

  @override
  String get outbound => 'صادر (إخراج من المخزون)';

  @override
  String get adjustmentIn => 'تسوية (+)';

  @override
  String get adjustmentOut => 'تسوية (-)';

  @override
  String get quantity => 'الكمية';

  @override
  String get unitCost => 'تكلفة الوحدة';

  @override
  String get movementNote => 'ملاحظة (اختياري)';

  @override
  String get noProductsYet => 'لا توجد منتجات بعد';

  @override
  String get noProductsHint => 'أضف أول منتج لبدء تتبع المخزون.';

  @override
  String get noMovementsYet => 'لا توجد حركات مخزون بعد';

  @override
  String get deleteProductTitle => 'حذف المنتج؟';

  @override
  String get deleteProductMessage => 'سيتم حذف المنتج وجميع حركات مخزونه نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteMovementTitle => 'حذف حركة المخزون؟';

  @override
  String get deleteMovementMessage => 'سيتم إعادة حساب الكمية المتوفرة للمنتج. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String insufficientStock(String available, String unit) => 'مخزون غير كافٍ. المتوفر: $available $unit';

  @override
  String get stockValue => 'قيمة المخزون';

  @override
  String get totalProducts => 'إجمالي المنتجات';

  @override
  String get totalStockValue => 'إجمالي قيمة المخزون';

  @override
  String get lowStockItems => 'أصناف منخفضة المخزون';

  @override
  String get searchProducts => 'ابحث عن منتج';

  @override
  String get net => 'الصافي';

  @override
  String get dailyReminder => 'تذكير يومي';

  @override
  String get dailyReminderSubtitle => 'احصل على تذكير يومي لتسجيل معاملاتك';

  @override
  String get authenticateReason => 'يرجى المصادقة للوصول إلى الديوان';

  @override
  String get dailyReminderTitle => 'تذكير يومي';

  @override
  String get dailyReminderBody => 'لا تنس تسجيل معاملاتك اليوم!';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get budgetExceededTitle => 'تجاوزت الميزانية';

  @override
  String budgetExceededBody(Object name, Object amount, Object currency) {
    return 'تجاوز $name بمبلغ $amount $currency';
  }

  @override
  String get goalReachedTitle => 'تم تحقيق الهدف! 🎉';

  @override
  String goalReachedBody(Object name) {
    return 'حققت هدفك: $name';
  }

  @override
  String get goalContribution => 'مساهمة';

  @override
  String get budgetExceeded => 'تجاوز الميزانية';

  @override
  String get insufficientFundsTitle => 'رصيد غير كافٍ';

  @override
  String insufficientFundsMessage(
    String balance,
    String currency,
    String amount,
  ) {
    return 'رصيدك الحالي ($balance $currency) غير كافٍ لهذا المصروف بقيمة $amount $currency. يرجى إضافة المزيد من الأموال أولاً.';
  }

  @override
  String get tourWelcome => 'مرحباً بك في الديوان!';

  @override
  String get tourDialogTitle => 'مرحباً بك في الديوان!';

  @override
  String get tourDialogBody => 'خذ جولة سريعة لاكتشاف كل الميزات؟';

  @override
  String get tourStartButton => 'ابدأ الجولة';

  @override
  String get tourSkipButton => 'تخطي الآن';

  @override
  String get tour1Title => 'نظرة مالية شاملة';

  @override
  String get tour1Desc =>
      'شاهد وضعك المالي الإجمالي. بدّل بين \'الكل\' و\'هذا الشهر\' لعرض فترات مختلفة.';

  @override
  String get tour2Title => 'إجراءات سريعة';

  @override
  String get tour2Desc =>
      'أضف دخل أو مصاريف أو ديون أو امسح الفواتير. كل شيء يبدأ من هنا.';

  @override
  String get tour3Title => 'تتبع الميزانية';

  @override
  String get tour3Desc => 'حدد سقف إنفاق لكل فئة. نُنبهك قبل تجاوز الميزانية.';

  @override
  String get tour4Title => 'أهداف التوفير';

  @override
  String get tour4Desc =>
      'وفّر لأهداف مثل الطوارئ أو السفر أو المشتريات. تابع تقدمك بصريًا.';

  @override
  String get tour5Title => 'شبكتك';

  @override
  String get tour5Desc =>
      'العملاء والموردون الذين تتابعهم. اضغط على أي شخص لرؤية سجله الكامل ورصيده.';

  @override
  String get tour6Title => 'إضافة أشخاص';

  @override
  String get tour6Desc => 'اضغط هنا لإضافة عملاء أو موردين جدد إلى دفترك.';

  @override
  String get tour7Title => 'فلاتر ذكية';

  @override
  String get tour7Desc =>
      'فلتر حسب النوع (دخل/مصروف) والفترة الزمنية. اعثر على ما تحتاجه بالضبط.';

  @override
  String get tour8Title => 'بحث قوي';

  @override
  String get tour8Desc =>
      'ابحث بالمبلغ أو الملاحظة أو الفئة. يعمل على جميع معاملاتك.';

  @override
  String get tour9Title => 'كل المعاملات';

  @override
  String get tour9Desc =>
      'سجلك المالي الكامل. اضغط على أي عنصر للتفاصيل أو التعديل.';

  @override
  String get tour10Title => 'التقارير والرؤى';

  @override
  String get tour10Desc =>
      'شاهد التدفق النقدي ورسوم الدخل والمصروفات وتحليل الديون. صدّر التقارير في أي وقت.';

  @override
  String get tour11Title => 'النسخ الاحتياطي والاستعادة';

  @override
  String get tour11Desc =>
      'احفظ بياناتك في التخزين السحابي. لا تفقد سجلاتك أبداً.';

  @override
  String get tour12Title => 'مركز المساعدة';

  @override
  String get tour12Desc =>
      'الأسئلة الشائعة والفيديوهات التعليمية والدعم. أعد هذه الجولة في أي وقت من هنا.';

  @override
  String get tipQuickActions => 'أزرار سريعة تسهل عليك';

  @override
  String get tipFilterTransactions =>
      'فلتر الحركات حسب التاريخ أو النوع أو الاسم';

  @override
  String get tipPersonBalance => 'اضغط على الشخص تشوف حسابه';

  @override
  String get tipBudgetAlert => 'سنذكرك عند اقتراب ميزانيتك';

  @override
  String get tipGoalProgress => 'تابع توفيرك هنا';

  @override
  String get tipEditTransaction => 'اسحب أو اضغط للتعديل';

  @override
  String get tipDeleteTransaction => 'اضغط طويلاً للحذف';

  @override
  String get tipCurrencyChange => 'غيّر العملة من الإعدادات';

  @override
  String get tipBackup => 'احتفظ بنسخة احتياطية بانتظام';

  @override
  String get tipDarkMode => 'جرب الوضع الليلي';

  @override
  String get tipAppLock => 'فعّل قفل التطبيق للأمان';

  @override
  String get tipExportReport => 'احفظ التقارير كملفات';

  @override
  String get tourHelp => 'محتاج مساعدة؟ تعال هنا';

  @override
  String get tipGotIt => 'فهمت';

  @override
  String get goalDeposit => 'إيداع للهدف';

  @override
  String get goalWithdrawal => 'سحب من الهدف';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get helpCenterSubtitle => 'أسئلة شائعة ودروس';

  @override
  String get restartTour => 'إعادة الشرح';

  @override
  String get restartTourSubtitle => 'شوف دليل التطبيق مرة تانية';

  @override
  String get contactSupport => 'تواصل معنا';

  @override
  String get contactSupportSubtitle => 'محتاج مساعدة؟ كلمنا';

  @override
  String get faqGettingStarted => 'البداية';

  @override
  String get faqWhatIsAldeewan => 'ماهو الديوان؟';

  @override
  String get faqWhatIsAldeewaAnswer =>
      'الديوان تطبيق حسابات ذكي يساعدك تدير فلوسك وتتابع الديون وتحدد ميزانيتك.';

  @override
  String get faqHowToAddTransaction => 'كيف أضيف فلوس داخلة أو خارجة؟';

  @override
  String get faqHowToAddTransactionAnswer =>
      'اضغط على زر + في أي شاشة عشان تضيف دخل أو مصروف.';

  @override
  String get faqDataBackup => 'البيانات والنسخ الاحتياطي';

  @override
  String get faqDashboard => 'لوحة المعلومات';

  @override
  String get faqLedger => 'الديون (الأشخاص)';

  @override
  String get faqCashbook => 'دفتر النقدية (الدخل/المصروف)';

  @override
  String get faqBudgetsGoals => 'الميزانيات والأهداف';

  @override
  String get faqReports => 'التحليلات والتقارير';

  @override
  String get faqSettings => 'الإعدادات والبيانات';

  @override
  String get faqWhatIsTrueIncome => 'الفرق بين الأموال الواردة والدخل الحقيقي؟';

  @override
  String get faqWhatIsTrueIncomeAnswer =>
      '• الأموال الواردة: كل النقد المستلم، بما في ذلك سداد الديون والقروض المستلمة.\n• الدخل الحقيقي: أرباحك الفعلية فقط (مبيعات، راتب).\nاستخدم الدخل الحقيقي لمعرفة ربحك الفعلي.';

  @override
  String get faqWhatIsNetPosition => 'ما هو صافي المركز المالي؟';

  @override
  String get faqWhatIsNetPositionAnswer =>
      'يوضح صحتك المالية: (كل الأموال التي تملكها + ديون لك) - (ديون عليك).';

  @override
  String get faqHowToTrackDebt => 'كيف أتتبع الديون؟';

  @override
  String get faqHowToTrackDebtAnswer =>
      'اذهب إلى الديون > إضافة شخص > إضافة معاملة > اختر \'سلف\' (إذا اقترض منك) أو \'دين\' (إذا اقترضت منه).';

  @override
  String get faqWhatIsOldDebt => 'ما هو \'الدين القديم\'؟';

  @override
  String get faqWhatIsOldDebtAnswer =>
      'استخدم هذا للديون التي كانت موجودة قبل استخدام التطبيق. يسجل الدين دون تغيير رصيدك النقدي الحالي (رصيد افتتاحي).';

  @override
  String get faqCashbookVsLedger => 'الفرق بين دفتر النقدية والديون؟';

  @override
  String get faqCashbookVsLedgerAnswer =>
      '• دفتر النقدية: للمصروفات/الدخل العام (مثل الراتب، الإيجار) غير المرتبط بشخص.\n• سجل الديون: للديون والائتمانات المرتبطة بأشخاص (عملاء/موردين).';

  @override
  String get faqHowToBudget => 'كيف تعمل تنبيهات الميزانية؟';

  @override
  String get faqHowToBudgetAnswer =>
      'حدد حداً شهرياً لفئة (مثل الطعام). سيقوم التطبيق بإشعارك عندما تقترب من تجاوزه.';

  @override
  String get faqHowToExport => 'كيفية تصدير التقارير؟';

  @override
  String get faqHowToExportAnswer =>
      '• كشف حساب شخص: تفاصيل الشخص > تصدير CSV.\n• تقرير الديون: التحليلات > الديون > تصدير CSV.';

  @override
  String get initialBalanceTitle => 'أدخل رصيدك الحالي';

  @override
  String get initialBalanceDescription =>
      'أدخل المبلغ الموجود لديك الآن لبدء التتبع بدقة.';

  @override
  String get cashOnHand => 'النقد المتاح';

  @override
  String get bankBalance => 'الرصيد البنكي';

  @override
  String get skipForNow => 'تخطي الآن';

  @override
  String get letsGo => 'هيا نبدأ!';

  @override
  String get initialBalanceNote => 'الرصيد الافتتاحي';

  @override
  String get backupToCloud => 'نسخ احتياطي للسحابة';

  @override
  String get backupToCloudSubtitle =>
      'حفظ في جوجل درايف، دروبوكس، وان درايف، إلخ';

  @override
  String get restoreFromCloud => 'استعادة من النسخة الاحتياطية';

  @override
  String get restoreFromCloudSubtitle =>
      'استيراد البيانات من ملف النسخة الاحتياطية';

  @override
  String get restoreHelpTitle => 'كيفية الاستعادة من السحابة';

  @override
  String get restoreHelpStep1 =>
      '١. افتح تطبيق السحابة (جوجل درايف، دروبوكس، إلخ)';

  @override
  String get restoreHelpStep2 => '٢. ابحث عن ملف النسخة الاحتياطية للديوان';

  @override
  String get restoreHelpStep3 => '٣. حمّله على جهازك';

  @override
  String get restoreHelpStep4 =>
      '٤. ارجع هنا واضغط \'استعادة من النسخة الاحتياطية\'';

  @override
  String get restoreHelpStep5 => '٥. اختر الملف المُحمَّل';

  @override
  String get faqHowToBackup => 'كيف أنسخ بياناتي احتياطياً؟';

  @override
  String get faqHowToBackupAnswer =>
      'اذهب إلى الإعدادات > نسخ احتياطي للسحابة. سيتم حفظ بياناتك كملف JSON يمكنك تخزينه في جوجل درايف أو دروبوكس أو أي تطبيق سحابي.';

  @override
  String get faqHowToRestore => 'كيف أستعيد من النسخة الاحتياطية؟';

  @override
  String get faqHowToRestoreAnswer =>
      '١. حمّل ملف النسخة الاحتياطية من السحابة إلى جهازك. ٢. اذهب إلى الإعدادات > استعادة من النسخة الاحتياطية. ٣. اختر ملف JSON المُحمَّل.';

  @override
  String get faqWhereIsData => 'أين يتم تخزين بياناتي؟';

  @override
  String get faqWhereIsDataAnswer =>
      'يتم تخزين بياناتك محلياً على جهازك في قاعدة بيانات مشفرة. لا تغادر بياناتك جهازك أبداً إلا إذا اخترت النسخ الاحتياطي للسحابة.';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get moreItems => 'المزيد';

  @override
  String get deletePerson => 'حذف الشخص';

  @override
  String get archivePerson => 'أرشفة الشخص';

  @override
  String deletePersonConfirm(String name) {
    return 'هل أنت متأكد من حذف $name؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String deletePersonWithTransactions(String name, int count) {
    return '$name لديه $count معاملة. ماذا تريد أن تفعل؟';
  }

  @override
  String cannotDeleteWithBalance(String name, String amount) {
    return 'لا يمكن حذف $name. الرصيد المستحق: $amount. يرجى التسوية أولاً أو الأرشفة.';
  }

  @override
  String get personArchived => 'تم أرشفة الشخص بنجاح';

  @override
  String get personDeleted => 'تم حذف الشخص بنجاح';

  @override
  String get archive => 'أرشفة';

  @override
  String get deleteAll => 'حذف الكل';

  @override
  String get archivedPersons => 'المؤرشفون';

  @override
  String get showArchived => 'إظهار المؤرشفين';

  @override
  String get debtBreakdown => 'تفاصيل الديون';

  @override
  String get debtAnalysis => 'تحليل الديون';

  @override
  String get exportDebtReport => 'تصدير تقرير الديون';

  @override
  String customersCount(Object count) {
    return 'العملاء ($count)';
  }

  @override
  String suppliersCount(Object count) {
    return 'الموردون ($count)';
  }

  @override
  String get allTime => 'كل الوقت';

  @override
  String get customRange => 'فترة مخصصة';

  @override
  String get weeklySummaryTitle => 'ملخص الأسبوع';

  @override
  String weeklySummaryBody(Object income, Object expense) {
    return 'الدخل: $income | المصروفات: $expense';
  }

  @override
  String get saveFailed => 'فشل الحفظ. تحقق من مساحة التخزين.';

  @override
  String get lowStorageWarning =>
      'مساحة التخزين منخفضة. يرجى تفريغ بعض المساحة.';

  @override
  String get databaseError =>
      'حدث خطأ في قاعدة البيانات. قد لا يتم حفظ بياناتك.';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get appFeatures => 'مميزات التطبيق';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutAldeewanDescription =>
      'تطبيق الديوان هو رفيقك المالي الأمثل، صُمم لمساعدتك في تتبع أموالك، إدارة الديون، وتحقيق أهدافك المالية بكل سهولة وذكاء.';

  @override
  String get backupEncrypt => 'تشفير النسخة الاحتياطية';

  @override
  String get backupEncryptSubtitle => 'حماية بكلمة مرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get restoreStrategyTitle => 'طريقة الاستعادة';

  @override
  String get restoreStrategyDesc => 'كيف تود استعادة هذا الملف؟';

  @override
  String get restoreMerge => 'دمج البيانات';

  @override
  String get restoreMergeDesc =>
      'إضافة للبيانات الحالية. يتم تحديث العناصر الموجودة.';

  @override
  String get restoreReplace => 'استبدال الكل';

  @override
  String get restoreReplaceDesc => 'خطر: سيتم حذف جميع البيانات الحالية.';

  @override
  String get restoreReplaceWarning =>
      'سيتم حذف جميع البيانات الحالية نهائياً. هل أنت متأكد؟';

  @override
  String get invalidPassword => 'كلمة المرور غير صحيحة';

  @override
  String get schemaVersionMismatch =>
      'النسخة الاحتياطية من إصدار أحدث للتطبيق. يرجى تحديث الديوان.';
}
