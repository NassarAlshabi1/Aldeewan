// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Aldeewan';

  @override
  String get appTitle => 'Aldeewan';

  @override
  String get appSlogan => 'Secure Financial Management';

  @override
  String get home => 'Home';

  @override
  String get ledger => 'Ledger';

  @override
  String get cashbook => 'Cashbook';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get featureManageCash => 'Manage Cash & Bank';

  @override
  String get featureTrackDebts => 'Track Debts & People';

  @override
  String get featureAnalytics => 'Financial Analytics';

  @override
  String get featureBackup => 'Secure Cloud Backup';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get general => 'General';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get addPerson => 'Add Person';

  @override
  String get search => 'Search...';

  @override
  String get noResults => 'No results found';

  @override
  String get addPersonPrompt =>
      'You need to add a person before adding a transaction';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get backupData => 'Backup Data (JSON)';

  @override
  String get backupDataSubtitle => 'Export all data to a JSON file';

  @override
  String get restoreData => 'Restore Data (JSON)';

  @override
  String get restoreDataSubtitle =>
      'Import data from a JSON file (Replaces current data)';

  @override
  String get exportPersons => 'Export Persons (CSV)';

  @override
  String get exportTransactions => 'Export Transactions (CSV)';

  @override
  String get personStatement => 'Person Statement';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get aboutDeveloper => 'About Developer';

  @override
  String get currency => 'Currency';

  @override
  String get currencyOptions => 'Currency Options';

  @override
  String get backupSuccess => 'Backup created successfully';

  @override
  String backupFailed(Object error) {
    return 'Backup failed: $error';
  }

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String restoreFailed(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String get exportSuccess => 'Export successful';

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get developerName => '@motaasl8';

  @override
  String get developerEmail => 'abdo13-m.azme@hotmail.com';

  @override
  String get version => 'Version';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get role => 'Role';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note';

  @override
  String get category => 'Category';

  @override
  String get type => 'Type';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get selectPerson => 'Select Person';

  @override
  String get noPersonsFound => 'No persons found';

  @override
  String get customer => 'Customer';

  @override
  String get supplier => 'Supplier';

  @override
  String get unknown => 'Unknown';

  @override
  String get dateRange => 'Date Range';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get generateReport => 'Generate Report';

  @override
  String statementFor(Object name) {
    return 'Statement for $name';
  }

  @override
  String period(Object end, Object start) {
    return 'Period: $start - $end';
  }

  @override
  String get balanceBroughtForward => 'Balance Brought Forward';

  @override
  String get closingBalance => 'Closing Balance';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get debt => 'Debt';

  @override
  String get payment => 'Payment';

  @override
  String get credit => 'Credit';

  @override
  String get transaction => 'Transaction';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get netProfitLoss => 'Net Profit/Loss';

  @override
  String get cashFlowReport => 'Cash Flow Report';

  @override
  String get madeWithLove => 'Made with ❤️ by Motaasl';

  @override
  String appVersionInfo(String version) {
    return 'Aldeewan Mobile v$version';
  }

  @override
  String get developerTagline =>
      'Media | Photography | Editing | Design | Web | Software Dev \"Professional, Quality and Art\" #motaasl';

  @override
  String get openSourceLink => 'View on GitHub';

  @override
  String get islamicEndowment =>
      'This app is an Islamic charitable endowment (Waqf).';

  @override
  String get facebook => 'Facebook';

  @override
  String get instagram => 'Instagram';

  @override
  String get email => 'Email';

  @override
  String get tagline => 'Your Personal Ledger & Cashbook';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get addCashEntry => 'Add Transaction';

  @override
  String get viewBalances => 'View Balances';

  @override
  String get allTransactions => 'All Transactions';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noEntriesYet => 'No entries yet';

  @override
  String get totalReceivable => 'People Owe You';

  @override
  String get totalPayable => 'You Owe Others';

  @override
  String get moneyIn => 'Money In';

  @override
  String get moneyOut => 'Money Out';

  @override
  String get trueIncome => 'True Income';

  @override
  String get trueExpense => 'True Expense';

  @override
  String get debtsSection => 'Debts';

  @override
  String get monthlySection => 'Monthly';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionConfirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get deletedSuccessfully => 'Deleted successfully';

  @override
  String get person => 'Person';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get cashLabel => 'Cash';

  @override
  String get bankLabel => 'Bank';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get addToLedger => 'Add to Ledger (Debt/Credit)';

  @override
  String get addToLedgerSubtitle => 'Requires selecting a person';

  @override
  String get addToCashbook => 'Add to Cashbook (Income/Expense)';

  @override
  String get addToCashbookSubtitle => 'No person required';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String scanError(Object error) {
    return 'Error scanning receipt: $error';
  }

  @override
  String get scanTimeout => 'Scanning timed out';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String goalReached(Object percent) {
    return '$percent% Reached';
  }

  @override
  String targetLabel(Object amount) {
    return 'Target: $amount';
  }

  @override
  String get goalProgress => 'Goal Progress';

  @override
  String budgetUsage(Object percentage) {
    return 'Budget Usage $percentage';
  }

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get me => 'Me';

  @override
  String get netPosition => 'Net Position';

  @override
  String get customersOweYouMore => 'Customers owe you more';

  @override
  String get youOweSuppliersMore => 'You owe suppliers more';

  @override
  String get profitThisMonth => 'Profit this month';

  @override
  String get lossThisMonth => 'Loss this month';

  @override
  String get all => 'All';

  @override
  String get thisMonth => 'This Month';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get custom => 'Custom';

  @override
  String get saleOnCredit => 'Sale (Credit)';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String get purchaseOnCredit => 'Purchase (Credit)';

  @override
  String get paymentMade => 'Payment Made';

  @override
  String get debtGiven => 'Lent (You gave)';

  @override
  String get debtTaken => 'Borrowed (You received)';

  @override
  String get cashSale => 'Cash Sale';

  @override
  String get cashIncome => 'Extra Income';

  @override
  String get cashExpense => 'Expenses';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get settled => 'Settled';

  @override
  String get receivable => 'Owes You';

  @override
  String get payable => 'You Owe';

  @override
  String get advance => 'Advance';

  @override
  String get advanceOwesYou => 'Owes You (Advance)';

  @override
  String get advanceYouOwe => 'You Owe (Advance)';

  @override
  String get analytics => 'Analytics';

  @override
  String get budgets => 'Budgets';

  @override
  String get goals => 'Goals';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get myAccounts => 'My Accounts';

  @override
  String get syncAccounts => 'Sync Accounts';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get budgetSummary => 'Budget Summary';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get goalName => 'Goal Name';

  @override
  String get monthlyLimit => 'Monthly Limit';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get currentSaved => 'Current Saved';

  @override
  String get addToGoal => 'Add to Goal';

  @override
  String get connectBank => 'Connect Bank';

  @override
  String get selectProvider => 'Select Provider';

  @override
  String get noExpensesToShow => 'No expenses to show';

  @override
  String get unlock => 'Unlock';

  @override
  String get appLocked => 'App Locked';

  @override
  String get link => 'Link';

  @override
  String get linkBankAccount => 'Link your bank account';

  @override
  String get errorLoadingAccounts => 'Error loading accounts';

  @override
  String get personNotFound => 'Person Not Found';

  @override
  String get appLock => 'App Lock';

  @override
  String get appLockSubtitle => 'Require authentication to open app';

  @override
  String get unlockApp => 'Unlock App';

  @override
  String get accountLinkedSuccess => 'Account linked successfully!';

  @override
  String get authFailed => 'Authentication failed. Please check credentials.';

  @override
  String get linkBankAccountTitle => 'Link Bank Account';

  @override
  String get connectAccount => 'Connect Account';

  @override
  String errorOccurred(Object error) {
    return 'Error: $error';
  }

  @override
  String get simpleMode => 'Simple Mode';

  @override
  String get simpleModeSubtitle => 'Use simplified terminology (Lent/Borrowed)';

  @override
  String get oldDebt => 'Old Debt / Opening Balance';

  @override
  String get oldDebtExplanation =>
      'Use this for debts that existed before you started using this app. It will record the debt on the person\'s profile but will NOT change your current cash/bank balance.';

  @override
  String get ok => 'OK';

  @override
  String get simpleLent => 'Lent';

  @override
  String get simpleBorrowed => 'Borrowed';

  @override
  String get simpleGotPaid => 'Got Paid';

  @override
  String get simplePaidBack => 'Paid Back';

  @override
  String get english => 'English';

  @override
  String get currencyQAR => 'QAR (ر.ق)';

  @override
  String get currencySAR => 'SAR (ر.س)';

  @override
  String get currencyEGP => 'EGP (ج.م)';

  @override
  String get currencySDG => 'Sudanese Pound (SDG)';

  @override
  String get currencyKWD => 'Kuwaiti Dinar (KWD)';

  @override
  String get loading => 'Loading';

  @override
  String get error => 'Error';

  @override
  String get deleteCategoryTitle => 'Delete Category?';

  @override
  String deleteCategoryContent(Object categoryName) {
    return 'Are you sure you want to delete \"$categoryName\"?';
  }

  @override
  String get newCategoryTitle => 'New Category';

  @override
  String get categoryType => 'Type: ';

  @override
  String get selectColor => 'Select Color';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get create => 'Create';

  @override
  String get active => 'Active';

  @override
  String get history => 'History';

  @override
  String get overBudget => 'Over Budget';

  @override
  String get remaining => 'Remaining';

  @override
  String get spent => 'Spent';

  @override
  String get limit => 'Limit';

  @override
  String get catHousing => 'Housing';

  @override
  String get catFood => 'Food & Dining';

  @override
  String get catTransportation => 'Transportation';

  @override
  String get catHealth => 'Health';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get catIncome => 'Income';

  @override
  String get catOther => 'Other';

  @override
  String get catSavings => 'Savings';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String budgetExceededMessage(String currency, String amount) {
    return 'You have exceeded your budget by $currency $amount';
  }

  @override
  String budgetRemainingMessage(String currency, String amount) {
    return 'You have $currency $amount remaining';
  }

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get deleteBudgetConfirmation =>
      'Are you sure you want to delete this budget?';

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get deleteGoalConfirmation =>
      'Are you sure you want to delete this goal?';

  @override
  String get goalDetails => 'Goal Details';

  @override
  String get budgetDetails => 'Budget Details';

  @override
  String get videoTutorials => 'Video Tutorials';

  @override
  String get faq => 'FAQ';

  @override
  String get hijriCalendar => 'Islamic Hijri Calendar';

  @override
  String get showHijriDate => 'Show Hijri Date';

  @override
  String get hijriAdjustment => 'Hijri Date Adjustment';

  @override
  String get hijriAdjustmentDesc =>
      'Adjust Hijri date by + or - days if needed';

  @override
  String get days => 'Days';

  @override
  String get deadline => 'Deadline';

  @override
  String get saved => 'Saved';

  @override
  String get target => 'Target';

  @override
  String get actions => 'Actions';

  @override
  String get addFunds => 'Add Funds';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get goalNotFound => 'Goal not found';

  @override
  String get budgetNotFound => 'Budget not found';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortNewest => 'Newest First';

  @override
  String get sortOldest => 'Oldest First';

  @override
  String get sortHighestAmount => 'Highest Amount';

  @override
  String get sortLowestAmount => 'Lowest Amount';

  @override
  String get goalExceededError =>
      'Cannot add funds. Total saved would exceed the target amount.';

  @override
  String get budgetExceededError =>
      'Cannot add expense. Total spent would exceed the budget limit.';

  @override
  String goalExceededErrorWithRemaining(String amount) {
    return 'Cannot add funds. You can only add up to $amount.';
  }

  @override
  String budgetExceededErrorWithRemaining(String amount) {
    return 'Cannot add expense. You only have $amount remaining in this budget.';
  }

  @override
  String get expenseBreakdown => 'Expense Breakdown';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get noDate => 'No Date';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get appSounds => 'App Sounds';

  @override
  String get appSoundsSubtitle => 'Play sounds on save and navigation';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get clearAll => 'Clear all';

  @override
  String get clearAllConfirmTitle => 'Clear all notifications?';

  @override
  String get clearAllConfirmMessage => 'This will permanently delete all notifications. This action cannot be undone.';

  @override
  String get clear => 'Clear';

  @override
  String get personCurrency => 'Currency';

  @override
  String get personCurrencyNote => 'Transactions for this person will be tracked in this currency.';

  @override
  String get personCurrencyDialogBody => 'Use the app\'s default currency, or pick a specific currency for this person.';

  @override
  String get useAppDefault => 'Use app default';

  @override
  String get chooseCurrency => 'Choose currency';

  @override
  String get appDefault => 'default';

  @override
  String personCurrencyBadge(String code) => 'Currency: $code';

  @override
  String get exchangeRates => 'Exchange rates';

  @override
  String get exchangeRatesSubtitle => 'Define how much 1 unit of the base currency equals in other currencies. Used to estimate the dashboard total across mixed currencies.';

  @override
  String get baseCurrency => 'Base currency';

  @override
  String get rate => 'Rate';

  @override
  String rateHint(String base, String code) => '1 $base = ? $code';

  @override
  String get mixedTotalNote => 'Totals combine multiple currencies using the rates you set. They are estimates only.';

  @override
  String get saveRate => 'Save rate';

  @override
  String get inventory => 'Inventory';

  @override
  String get inventorySubtitle => 'Track products, stock levels, and movements';

  @override
  String get product => 'Product';

  @override
  String get products => 'Products';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get productName => 'Product name';

  @override
  String get sku => 'SKU';

  @override
  String get category => 'Category';

  @override
  String get unit => 'Unit';

  @override
  String get costPrice => 'Cost price';

  @override
  String get salePrice => 'Sale price';

  @override
  String get lowStockThreshold => 'Low-stock threshold';

  @override
  String get lowStockThresholdHint => 'Alert when quantity on hand drops to or below this value. Leave empty to disable alerts.';

  @override
  String get quantityOnHand => 'Quantity on hand';

  @override
  String get inStock => 'In stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get lowStock => 'Low stock';

  @override
  String get stockMovements => 'Stock movements';

  @override
  String get addStockMovement => 'Record stock movement';

  @override
  String get movementType => 'Movement type';

  @override
  String get inbound => 'Inbound (add stock)';

  @override
  String get outbound => 'Outbound (remove stock)';

  @override
  String get adjustmentIn => 'Adjustment (+)';

  @override
  String get adjustmentOut => 'Adjustment (-)';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitCost => 'Unit cost';

  @override
  String get movementNote => 'Note (optional)';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get noProductsHint => 'Add your first product to start tracking inventory.';

  @override
  String get noMovementsYet => 'No stock movements yet';

  @override
  String get deleteProductTitle => 'Delete product?';

  @override
  String get deleteProductMessage => 'This will permanently delete the product and all its stock movements. This cannot be undone.';

  @override
  String get deleteMovementTitle => 'Delete stock movement?';

  @override
  String get deleteMovementMessage => 'This will recalculate the product\'s quantity on hand. This cannot be undone.';

  @override
  String insufficientStock(String available, String unit) => 'Insufficient stock. Available: $available $unit';

  @override
  String get stockValue => 'Stock value';

  @override
  String get totalProducts => 'Total products';

  @override
  String get totalStockValue => 'Total stock value';

  @override
  String get lowStockItems => 'Low stock items';

  @override
  String get searchProducts => 'Search products';

  @override
  String get net => 'Net';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get dailyReminderSubtitle =>
      'Get a daily reminder to record your transactions';

  @override
  String get authenticateReason => 'Please authenticate to access Aldeewan';

  @override
  String get dailyReminderTitle => 'Daily Reminder';

  @override
  String get dailyReminderBody =>
      'Don\'t forget to record your transactions for today!';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get budgetExceededTitle => 'Budget Exceeded';

  @override
  String budgetExceededBody(Object name, Object amount, Object currency) {
    return '$name exceeded by $amount $currency';
  }

  @override
  String get goalReachedTitle => 'Goal Achieved! 🎉';

  @override
  String goalReachedBody(Object name) {
    return 'You\'ve reached your goal: $name';
  }

  @override
  String get goalContribution => 'Contribution';

  @override
  String get budgetExceeded => 'Budget Exceeded';

  @override
  String get insufficientFundsTitle => 'Insufficient Funds';

  @override
  String insufficientFundsMessage(
    String balance,
    String currency,
    String amount,
  ) {
    return 'Your current balance ($balance $currency) is not enough for this expense of $amount $currency. Please add more funds first.';
  }

  @override
  String get tourWelcome => 'Welcome to Aldeewan!';

  @override
  String get tourDialogTitle => 'Welcome to Aldeewan!';

  @override
  String get tourDialogBody => 'Take a quick tour to discover all features?';

  @override
  String get tourStartButton => 'Start Tour';

  @override
  String get tourSkipButton => 'Skip for Now';

  @override
  String get tour1Title => 'Your Financial Overview';

  @override
  String get tour1Desc =>
      'See your net position at a glance. Toggle \'All Time\' or \'This Month\' for different views.';

  @override
  String get tour2Title => 'Quick Actions';

  @override
  String get tour2Desc =>
      'Add income, expenses, debts, or scan receipts. Everything starts here.';

  @override
  String get tour3Title => 'Budget Tracking';

  @override
  String get tour3Desc =>
      'Set spending limits by category. Get alerts before overspending.';

  @override
  String get tour4Title => 'Savings Goals';

  @override
  String get tour4Desc =>
      'Save toward targets like emergencies, travel, or purchases. Track your progress visually.';

  @override
  String get tour5Title => 'Your Network';

  @override
  String get tour5Desc =>
      'Customers and suppliers you track. Tap anyone to see full history and balance.';

  @override
  String get tour6Title => 'Add People';

  @override
  String get tour6Desc =>
      'Tap here to add new customers or suppliers to your ledger.';

  @override
  String get tour7Title => 'Smart Filters';

  @override
  String get tour7Desc =>
      'Filter by type (Income/Expense) and time period. Find exactly what you need.';

  @override
  String get tour8Title => 'Powerful Search';

  @override
  String get tour8Desc =>
      'Search by amount, note, or category. Works across all transactions.';

  @override
  String get tour9Title => 'All Transactions';

  @override
  String get tour9Desc =>
      'Your complete financial history. Tap any entry for details or to edit.';

  @override
  String get tour10Title => 'Reports & Insights';

  @override
  String get tour10Desc =>
      'View cash flow, income vs expense charts, and debt analysis. Export reports anytime.';

  @override
  String get tour11Title => 'Backup & Restore';

  @override
  String get tour11Desc =>
      'Save your data to cloud storage. Never lose your records.';

  @override
  String get tour12Title => 'Help Center';

  @override
  String get tour12Desc =>
      'FAQs, video tutorials, and support. Restart this tour anytime from here.';

  @override
  String get tipQuickActions => 'Use Quick Actions for faster entry';

  @override
  String get tipFilterTransactions =>
      'Filter and search transactions by date, type, or name';

  @override
  String get tipPersonBalance => 'Tap a person to see their account';

  @override
  String get tipBudgetAlert => 'We\'ll remind you when nearing your budget';

  @override
  String get tipGoalProgress => 'Track your savings here';

  @override
  String get tipEditTransaction => 'Swipe or tap to edit';

  @override
  String get tipDeleteTransaction => 'Long press to delete';

  @override
  String get tipCurrencyChange => 'Change currency in Settings';

  @override
  String get tipBackup => 'Back up regularly to avoid data loss';

  @override
  String get tipDarkMode => 'Try dark mode for nighttime use';

  @override
  String get tipAppLock => 'Enable app lock for security';

  @override
  String get tipExportReport => 'Save reports as files';

  @override
  String get tourHelp => 'Need help? Come here anytime';

  @override
  String get tipGotIt => 'Got it';

  @override
  String get goalDeposit => 'Deposit to Goal';

  @override
  String get goalWithdrawal => 'Withdrawal from Goal';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get helpCenterSubtitle => 'FAQs and tutorials';

  @override
  String get restartTour => 'Restart Tutorial';

  @override
  String get restartTourSubtitle => 'See the app guide again';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get contactSupportSubtitle => 'Need help? Reach out to us';

  @override
  String get faqGettingStarted => 'Getting Started';

  @override
  String get faqWhatIsAldeewan => 'What is Aldeewan?';

  @override
  String get faqWhatIsAldeewaAnswer =>
      'Aldeewan is a smart accounting app to manage your money, track debts, and set budgets.';

  @override
  String get faqHowToAddTransaction => 'How to add a transaction?';

  @override
  String get faqHowToAddTransactionAnswer =>
      'Tap the + button on any screen to add income or expense.';

  @override
  String get faqDataBackup => 'Data & Backup';

  @override
  String get faqDashboard => 'Dashboard & Home';

  @override
  String get faqLedger => 'Leger (People)';

  @override
  String get faqCashbook => 'Cashbook (Income/Expense)';

  @override
  String get faqBudgetsGoals => 'Budgets & Goals';

  @override
  String get faqReports => 'Analytics & Reports';

  @override
  String get faqSettings => 'Settings & Data';

  @override
  String get faqWhatIsTrueIncome => 'Money In vs True Income?';

  @override
  String get faqWhatIsTrueIncomeAnswer =>
      '• Money In: All cash you received, including loans or debt repayments.\n• True Income: Only your actual earnings (Sales, Salary).\nUse True Income to see your real profit.';

  @override
  String get faqWhatIsNetPosition => 'What is Net Position?';

  @override
  String get faqWhatIsNetPositionAnswer =>
      'It shows your overall financial health: (All Money You Have + People Owe You) minus (Debts You Owe).';

  @override
  String get faqHowToTrackDebt => 'How to track debts?';

  @override
  String get faqHowToTrackDebtAnswer =>
      'Go to Ledger > Add Person > Add Transaction > Choose \'Lent\' (if they borrow from you) or \'Borrowed\' (if you borrow from them).';

  @override
  String get faqWhatIsOldDebt => 'What is \'Old Debt\'?';

  @override
  String get faqWhatIsOldDebtAnswer =>
      'Use this for debts that existed before you started using the app. It records the debt without changing your current cash balance.';

  @override
  String get faqCashbookVsLedger => 'Cashbook vs Ledger?';

  @override
  String get faqCashbookVsLedgerAnswer =>
      '• Cashbook: For general income/expenses (e.g. Salary, Rent) not linked to a specific person.\n• Ledger: For debts and credits linked to people (Customers/Suppliers).';

  @override
  String get faqHowToBudget => 'How do budget alerts work?';

  @override
  String get faqHowToBudgetAnswer =>
      'Set a monthly limit for a category (e.g. Food). The app will notify you when you are close to exceeding it.';

  @override
  String get faqHowToExport => 'How to export reports?';

  @override
  String get faqHowToExportAnswer =>
      '• Person Statement: Go to Person Details > Export CSV.\n• Debt Report: Go to Analytics > Ledger > Export CSV.';

  @override
  String get initialBalanceTitle => 'Set Your Starting Balance';

  @override
  String get initialBalanceDescription =>
      'Enter the money you currently have to start tracking accurately.';

  @override
  String get cashOnHand => 'Cash on Hand';

  @override
  String get bankBalance => 'Bank Balance';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get letsGo => 'Let\'s Go!';

  @override
  String get initialBalanceNote => 'Opening Balance';

  @override
  String get backupToCloud => 'Backup to Cloud';

  @override
  String get backupToCloudSubtitle =>
      'Save to Google Drive, Dropbox, OneDrive, etc.';

  @override
  String get restoreFromCloud => 'Restore from Backup';

  @override
  String get restoreFromCloudSubtitle => 'Import data from a backup file';

  @override
  String get restoreHelpTitle => 'How to Restore from Cloud';

  @override
  String get restoreHelpStep1 =>
      '1. Open your cloud app (Google Drive, Dropbox, etc.)';

  @override
  String get restoreHelpStep2 => '2. Find your Aldeewan backup file';

  @override
  String get restoreHelpStep3 => '3. Download it to your device';

  @override
  String get restoreHelpStep4 =>
      '4. Return here and tap \'Restore from Backup\'';

  @override
  String get restoreHelpStep5 => '5. Select the downloaded file';

  @override
  String get faqHowToBackup => 'How do I backup my data?';

  @override
  String get faqHowToBackupAnswer =>
      'Go to Settings > Backup to Cloud. Your data will be saved as a JSON file that you can store in Google Drive, Dropbox, or any cloud app.';

  @override
  String get faqHowToRestore => 'How do I restore from a backup?';

  @override
  String get faqHowToRestoreAnswer =>
      '1. Download your backup file from cloud storage to your device. 2. Go to Settings > Restore from Backup. 3. Select the downloaded JSON file.';

  @override
  String get faqWhereIsData => 'Where is my data stored?';

  @override
  String get faqWhereIsDataAnswer =>
      'Your data is stored locally on your device in an encrypted database. It never leaves your device unless you choose to backup to cloud.';

  @override
  String get loadMore => 'Load More';

  @override
  String get moreItems => 'more';

  @override
  String get deletePerson => 'Delete Person';

  @override
  String get archivePerson => 'Archive Person';

  @override
  String deletePersonConfirm(String name) {
    return 'Are you sure you want to delete $name? This action cannot be undone.';
  }

  @override
  String deletePersonWithTransactions(String name, int count) {
    return '$name has $count transactions. What would you like to do?';
  }

  @override
  String cannotDeleteWithBalance(String name, String amount) {
    return 'Cannot delete $name. Outstanding balance: $amount. Please settle first or archive.';
  }

  @override
  String get personArchived => 'Person archived successfully';

  @override
  String get personDeleted => 'Person deleted successfully';

  @override
  String get archive => 'Archive';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get archivedPersons => 'Archived';

  @override
  String get showArchived => 'Show Archived';

  @override
  String get debtBreakdown => 'Debt Breakdown';

  @override
  String get debtAnalysis => 'Debt Analysis';

  @override
  String get exportDebtReport => 'Export Debt Report';

  @override
  String customersCount(Object count) {
    return 'Customers ($count)';
  }

  @override
  String suppliersCount(Object count) {
    return 'Suppliers ($count)';
  }

  @override
  String get allTime => 'All Time';

  @override
  String get customRange => 'Custom Range';

  @override
  String get weeklySummaryTitle => 'Weekly Summary';

  @override
  String weeklySummaryBody(Object income, Object expense) {
    return 'Income: $income | Expense: $expense';
  }

  @override
  String get saveFailed => 'Failed to save. Please check storage space.';

  @override
  String get lowStorageWarning =>
      'Storage is running low. Please free up space.';

  @override
  String get databaseError =>
      'A database error occurred. Your data may not have been saved.';

  @override
  String get aboutApp => 'About App';

  @override
  String get appFeatures => 'App Features';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutAldeewanDescription =>
      'Aldeewan is your ultimate financial companion, designed to help you track your money, manage debts, and achieve your financial goals with ease and intelligence.';

  @override
  String get backupEncrypt => 'Encrypt Backup';

  @override
  String get backupEncryptSubtitle => 'Protect with password';

  @override
  String get enterPassword => 'Enter Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get restoreStrategyTitle => 'Restore Method';

  @override
  String get restoreStrategyDesc => 'How would you like to restore this file?';

  @override
  String get restoreMerge => 'Merge Data';

  @override
  String get restoreMergeDesc => 'Add to current data. Updates existing items.';

  @override
  String get restoreReplace => 'Replace All';

  @override
  String get restoreReplaceDesc => 'Danger: Deletes all current data.';

  @override
  String get restoreReplaceWarning =>
      'This will PERMANENTLY DELETE all current data. Are you sure?';

  @override
  String get invalidPassword => 'Invalid Password';

  @override
  String get schemaVersionMismatch =>
      'Backup is from a newer version of the app. Please update Aldeewan.';
}
