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
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan'**
  String get appName;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan'**
  String get appTitle;

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'Secure Financial Management'**
  String get appSlogan;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @cashbook.
  ///
  /// In en, this message translates to:
  /// **'Cashbook'**
  String get cashbook;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @featureManageCash.
  ///
  /// In en, this message translates to:
  /// **'Manage Cash & Bank'**
  String get featureManageCash;

  /// No description provided for @featureTrackDebts.
  ///
  /// In en, this message translates to:
  /// **'Track Debts & People'**
  String get featureTrackDebts;

  /// No description provided for @featureAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Financial Analytics'**
  String get featureAnalytics;

  /// No description provided for @featureBackup.
  ///
  /// In en, this message translates to:
  /// **'Secure Cloud Backup'**
  String get featureBackup;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add Person'**
  String get addPerson;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @addPersonPrompt.
  ///
  /// In en, this message translates to:
  /// **'You need to add a person before adding a transaction'**
  String get addPersonPrompt;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data (JSON)'**
  String get backupData;

  /// No description provided for @backupDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all data to a JSON file'**
  String get backupDataSubtitle;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data (JSON)'**
  String get restoreData;

  /// No description provided for @restoreDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import data from a JSON file (Replaces current data)'**
  String get restoreDataSubtitle;

  /// No description provided for @exportPersons.
  ///
  /// In en, this message translates to:
  /// **'Export Persons (CSV)'**
  String get exportPersons;

  /// No description provided for @exportTransactions.
  ///
  /// In en, this message translates to:
  /// **'Export Transactions (CSV)'**
  String get exportTransactions;

  /// No description provided for @personStatement.
  ///
  /// In en, this message translates to:
  /// **'Person Statement'**
  String get personStatement;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About Developer'**
  String get aboutDeveloper;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencyOptions.
  ///
  /// In en, this message translates to:
  /// **'Currency Options'**
  String get currencyOptions;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupSuccess;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(Object error);

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(Object error);

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'@motaasl8'**
  String get developerName;

  /// No description provided for @developerEmail.
  ///
  /// In en, this message translates to:
  /// **'abdo13-m.azme@hotmail.com'**
  String get developerEmail;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

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

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @selectPerson.
  ///
  /// In en, this message translates to:
  /// **'Select Person'**
  String get selectPerson;

  /// No description provided for @noPersonsFound.
  ///
  /// In en, this message translates to:
  /// **'No persons found'**
  String get noPersonsFound;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @statementFor.
  ///
  /// In en, this message translates to:
  /// **'Statement for {name}'**
  String statementFor(Object name);

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period: {start} - {end}'**
  String period(Object end, Object start);

  /// No description provided for @balanceBroughtForward.
  ///
  /// In en, this message translates to:
  /// **'Balance Brought Forward'**
  String get balanceBroughtForward;

  /// No description provided for @closingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing Balance'**
  String get closingBalance;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// No description provided for @netProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Net Profit/Loss'**
  String get netProfitLoss;

  /// No description provided for @cashFlowReport.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Report'**
  String get cashFlowReport;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by Motaasl'**
  String get madeWithLove;

  /// No description provided for @appVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan Mobile v{version}'**
  String appVersionInfo(String version);

  /// No description provided for @developerTagline.
  ///
  /// In en, this message translates to:
  /// **'Media | Photography | Editing | Design | Web | Software Dev \"Professional, Quality and Art\" #motaasl'**
  String get developerTagline;

  /// No description provided for @openSourceLink.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get openSourceLink;

  /// No description provided for @islamicEndowment.
  ///
  /// In en, this message translates to:
  /// **'This app is an Islamic charitable endowment (Waqf).'**
  String get islamicEndowment;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Ledger & Cashbook'**
  String get tagline;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @addCashEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addCashEntry;

  /// No description provided for @viewBalances.
  ///
  /// In en, this message translates to:
  /// **'View Balances'**
  String get viewBalances;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// No description provided for @totalReceivable.
  ///
  /// In en, this message translates to:
  /// **'People Owe You'**
  String get totalReceivable;

  /// No description provided for @totalPayable.
  ///
  /// In en, this message translates to:
  /// **'You Owe Others'**
  String get totalPayable;

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money In'**
  String get moneyIn;

  /// No description provided for @moneyOut.
  ///
  /// In en, this message translates to:
  /// **'Money Out'**
  String get moneyOut;

  /// No description provided for @trueIncome.
  ///
  /// In en, this message translates to:
  /// **'True Income'**
  String get trueIncome;

  /// No description provided for @trueExpense.
  ///
  /// In en, this message translates to:
  /// **'True Expense'**
  String get trueExpense;

  /// No description provided for @debtsSection.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debtsSection;

  /// No description provided for @monthlySection.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlySection;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionConfirm;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @cashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashLabel;

  /// No description provided for @bankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankLabel;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @addToLedger.
  ///
  /// In en, this message translates to:
  /// **'Add to Ledger (Debt/Credit)'**
  String get addToLedger;

  /// No description provided for @addToLedgerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requires selecting a person'**
  String get addToLedgerSubtitle;

  /// No description provided for @addToCashbook.
  ///
  /// In en, this message translates to:
  /// **'Add to Cashbook (Income/Expense)'**
  String get addToCashbook;

  /// No description provided for @addToCashbookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No person required'**
  String get addToCashbookSubtitle;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Error scanning receipt: {error}'**
  String scanError(Object error);

  /// No description provided for @scanTimeout.
  ///
  /// In en, this message translates to:
  /// **'Scanning timed out'**
  String get scanTimeout;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Reached'**
  String goalReached(Object percent);

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target: {amount}'**
  String targetLabel(Object amount);

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'Goal Progress'**
  String get goalProgress;

  /// No description provided for @budgetUsage.
  ///
  /// In en, this message translates to:
  /// **'Budget Usage {percentage}'**
  String budgetUsage(Object percentage);

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @netPosition.
  ///
  /// In en, this message translates to:
  /// **'Net Position'**
  String get netPosition;

  /// No description provided for @customersOweYouMore.
  ///
  /// In en, this message translates to:
  /// **'Customers owe you more'**
  String get customersOweYouMore;

  /// No description provided for @youOweSuppliersMore.
  ///
  /// In en, this message translates to:
  /// **'You owe suppliers more'**
  String get youOweSuppliersMore;

  /// No description provided for @profitThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Profit this month'**
  String get profitThisMonth;

  /// No description provided for @lossThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Loss this month'**
  String get lossThisMonth;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @saleOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Sale (Credit)'**
  String get saleOnCredit;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @purchaseOnCredit.
  ///
  /// In en, this message translates to:
  /// **'Purchase (Credit)'**
  String get purchaseOnCredit;

  /// No description provided for @paymentMade.
  ///
  /// In en, this message translates to:
  /// **'Payment Made'**
  String get paymentMade;

  /// No description provided for @debtGiven.
  ///
  /// In en, this message translates to:
  /// **'Lent (You gave)'**
  String get debtGiven;

  /// No description provided for @debtTaken.
  ///
  /// In en, this message translates to:
  /// **'Borrowed (You received)'**
  String get debtTaken;

  /// No description provided for @cashSale.
  ///
  /// In en, this message translates to:
  /// **'Cash Sale'**
  String get cashSale;

  /// No description provided for @cashIncome.
  ///
  /// In en, this message translates to:
  /// **'Extra Income'**
  String get cashIncome;

  /// No description provided for @cashExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get cashExpense;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @receivable.
  ///
  /// In en, this message translates to:
  /// **'Owes You'**
  String get receivable;

  /// No description provided for @payable.
  ///
  /// In en, this message translates to:
  /// **'You Owe'**
  String get payable;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advance;

  /// No description provided for @advanceOwesYou.
  ///
  /// In en, this message translates to:
  /// **'Owes You (Advance)'**
  String get advanceOwesYou;

  /// No description provided for @advanceYouOwe.
  ///
  /// In en, this message translates to:
  /// **'You Owe (Advance)'**
  String get advanceYouOwe;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccount;

  /// No description provided for @myAccounts.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get myAccounts;

  /// No description provided for @syncAccounts.
  ///
  /// In en, this message translates to:
  /// **'Sync Accounts'**
  String get syncAccounts;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @budgetSummary.
  ///
  /// In en, this message translates to:
  /// **'Budget Summary'**
  String get budgetSummary;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimit;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @currentSaved.
  ///
  /// In en, this message translates to:
  /// **'Current Saved'**
  String get currentSaved;

  /// No description provided for @addToGoal.
  ///
  /// In en, this message translates to:
  /// **'Add to Goal'**
  String get addToGoal;

  /// No description provided for @connectBank.
  ///
  /// In en, this message translates to:
  /// **'Connect Bank'**
  String get connectBank;

  /// No description provided for @selectProvider.
  ///
  /// In en, this message translates to:
  /// **'Select Provider'**
  String get selectProvider;

  /// No description provided for @noExpensesToShow.
  ///
  /// In en, this message translates to:
  /// **'No expenses to show'**
  String get noExpensesToShow;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'App Locked'**
  String get appLocked;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @linkBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Link your bank account'**
  String get linkBankAccount;

  /// No description provided for @errorLoadingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts'**
  String get errorLoadingAccounts;

  /// No description provided for @personNotFound.
  ///
  /// In en, this message translates to:
  /// **'Person Not Found'**
  String get personNotFound;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require authentication to open app'**
  String get appLockSubtitle;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'Unlock App'**
  String get unlockApp;

  /// No description provided for @accountLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully!'**
  String get accountLinkedSuccess;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please check credentials.'**
  String get authFailed;

  /// No description provided for @linkBankAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Bank Account'**
  String get linkBankAccountTitle;

  /// No description provided for @connectAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect Account'**
  String get connectAccount;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @simpleMode.
  ///
  /// In en, this message translates to:
  /// **'Simple Mode'**
  String get simpleMode;

  /// No description provided for @simpleModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use simplified terminology (Lent/Borrowed)'**
  String get simpleModeSubtitle;

  /// No description provided for @oldDebt.
  ///
  /// In en, this message translates to:
  /// **'Old Debt / Opening Balance'**
  String get oldDebt;

  /// No description provided for @oldDebtExplanation.
  ///
  /// In en, this message translates to:
  /// **'Use this for debts that existed before you started using this app. It will record the debt on the person\'s profile but will NOT change your current cash/bank balance.'**
  String get oldDebtExplanation;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @simpleLent.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get simpleLent;

  /// No description provided for @simpleBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get simpleBorrowed;

  /// No description provided for @simpleGotPaid.
  ///
  /// In en, this message translates to:
  /// **'Got Paid'**
  String get simpleGotPaid;

  /// No description provided for @simplePaidBack.
  ///
  /// In en, this message translates to:
  /// **'Paid Back'**
  String get simplePaidBack;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @currencyQAR.
  ///
  /// In en, this message translates to:
  /// **'QAR (ر.ق)'**
  String get currencyQAR;

  /// No description provided for @currencySAR.
  ///
  /// In en, this message translates to:
  /// **'SAR (ر.س)'**
  String get currencySAR;

  /// No description provided for @currencyEGP.
  ///
  /// In en, this message translates to:
  /// **'EGP (ج.م)'**
  String get currencyEGP;

  /// No description provided for @currencySDG.
  ///
  /// In en, this message translates to:
  /// **'Sudanese Pound (SDG)'**
  String get currencySDG;

  /// No description provided for @currencyKWD.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar (KWD)'**
  String get currencyKWD;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{categoryName}\"?'**
  String deleteCategoryContent(Object categoryName);

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategoryTitle;

  /// No description provided for @categoryType.
  ///
  /// In en, this message translates to:
  /// **'Type: '**
  String get categoryType;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @catHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get catHousing;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get catFood;

  /// No description provided for @catTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get catTransportation;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// No description provided for @catIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get catIncome;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @catSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get catSavings;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @budgetExceededMessage.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your budget by {currency} {amount}'**
  String budgetExceededMessage(String currency, String amount);

  /// No description provided for @budgetRemainingMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {currency} {amount} remaining'**
  String budgetRemainingMessage(String currency, String amount);

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @deleteBudgetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget?'**
  String get deleteBudgetConfirmation;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// No description provided for @deleteGoalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal?'**
  String get deleteGoalConfirmation;

  /// No description provided for @goalDetails.
  ///
  /// In en, this message translates to:
  /// **'Goal Details'**
  String get goalDetails;

  /// No description provided for @budgetDetails.
  ///
  /// In en, this message translates to:
  /// **'Budget Details'**
  String get budgetDetails;

  /// No description provided for @videoTutorials.
  ///
  /// In en, this message translates to:
  /// **'Video Tutorials'**
  String get videoTutorials;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @hijriCalendar.
  ///
  /// In en, this message translates to:
  /// **'Islamic Hijri Calendar'**
  String get hijriCalendar;

  /// No description provided for @showHijriDate.
  ///
  /// In en, this message translates to:
  /// **'Show Hijri Date'**
  String get showHijriDate;

  /// No description provided for @hijriAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date Adjustment'**
  String get hijriAdjustment;

  /// No description provided for @hijriAdjustmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Adjust Hijri date by + or - days if needed'**
  String get hijriAdjustmentDesc;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @addFunds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get addFunds;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @goalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Goal not found'**
  String get goalNotFound;

  /// No description provided for @budgetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Budget not found'**
  String get budgetNotFound;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get sortOldest;

  /// No description provided for @sortHighestAmount.
  ///
  /// In en, this message translates to:
  /// **'Highest Amount'**
  String get sortHighestAmount;

  /// No description provided for @sortLowestAmount.
  ///
  /// In en, this message translates to:
  /// **'Lowest Amount'**
  String get sortLowestAmount;

  /// No description provided for @goalExceededError.
  ///
  /// In en, this message translates to:
  /// **'Cannot add funds. Total saved would exceed the target amount.'**
  String get goalExceededError;

  /// No description provided for @budgetExceededError.
  ///
  /// In en, this message translates to:
  /// **'Cannot add expense. Total spent would exceed the budget limit.'**
  String get budgetExceededError;

  /// No description provided for @goalExceededErrorWithRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cannot add funds. You can only add up to {amount}.'**
  String goalExceededErrorWithRemaining(String amount);

  /// No description provided for @budgetExceededErrorWithRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cannot add expense. You only have {amount} remaining in this budget.'**
  String budgetExceededErrorWithRemaining(String amount);

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No Date'**
  String get noDate;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @appSounds.
  ///
  /// In en, this message translates to:
  /// **'App Sounds'**
  String get appSounds;

  /// No description provided for @appSoundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play sounds on save and navigation'**
  String get appSoundsSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @clearAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications?'**
  String get clearAllConfirmTitle;

  /// No description provided for @clearAllConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all notifications. This action cannot be undone.'**
  String get clearAllConfirmMessage;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @personCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get personCurrency;

  /// No description provided for @personCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Transactions for this person will be tracked in this currency.'**
  String get personCurrencyNote;

  /// No description provided for @personCurrencyDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Use the app\'s default currency, or pick a specific currency for this person.'**
  String get personCurrencyDialogBody;

  /// No description provided for @useAppDefault.
  ///
  /// In en, this message translates to:
  /// **'Use app default'**
  String get useAppDefault;

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose currency'**
  String get chooseCurrency;

  /// No description provided for @appDefault.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get appDefault;

  /// No description provided for @personCurrencyBadge.
  ///
  /// In en, this message translates to:
  /// **'Currency: {code}'**
  String personCurrencyBadge(String code);

  /// No description provided for @exchangeRates.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get exchangeRates;

  /// No description provided for @exchangeRatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define how much 1 unit of the base currency equals in other currencies. Used to estimate the dashboard total across mixed currencies.'**
  String get exchangeRatesSubtitle;

  /// No description provided for @baseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get baseCurrency;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @rateHint.
  ///
  /// In en, this message translates to:
  /// **'1 {base} = ? {code}'**
  String rateHint(String base, String code);

  /// No description provided for @mixedTotalNote.
  ///
  /// In en, this message translates to:
  /// **'Totals combine multiple currencies using the rates you set. They are estimates only.'**
  String get mixedTotalNote;

  /// No description provided for @saveRate.
  ///
  /// In en, this message translates to:
  /// **'Save rate'**
  String get saveRate;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @inventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track products, stock levels, and movements'**
  String get inventorySubtitle;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get costPrice;

  /// No description provided for @salePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale price'**
  String get salePrice;

  /// No description provided for @lowStockThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low-stock threshold'**
  String get lowStockThreshold;

  /// No description provided for @lowStockThresholdHint.
  ///
  /// In en, this message translates to:
  /// **'Alert when quantity on hand drops to or below this value. Leave empty to disable alerts.'**
  String get lowStockThresholdHint;

  /// No description provided for @quantityOnHand.
  ///
  /// In en, this message translates to:
  /// **'Quantity on hand'**
  String get quantityOnHand;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @stockMovements.
  ///
  /// In en, this message translates to:
  /// **'Stock movements'**
  String get stockMovements;

  /// No description provided for @addStockMovement.
  ///
  /// In en, this message translates to:
  /// **'Record stock movement'**
  String get addStockMovement;

  /// No description provided for @movementType.
  ///
  /// In en, this message translates to:
  /// **'Movement type'**
  String get movementType;

  /// No description provided for @inbound.
  ///
  /// In en, this message translates to:
  /// **'Inbound (add stock)'**
  String get inbound;

  /// No description provided for @outbound.
  ///
  /// In en, this message translates to:
  /// **'Outbound (remove stock)'**
  String get outbound;

  /// No description provided for @adjustmentIn.
  ///
  /// In en, this message translates to:
  /// **'Adjustment (+)'**
  String get adjustmentIn;

  /// No description provided for @adjustmentOut.
  ///
  /// In en, this message translates to:
  /// **'Adjustment (-)'**
  String get adjustmentOut;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get unitCost;

  /// No description provided for @movementNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get movementNote;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @noProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to start tracking inventory.'**
  String get noProductsHint;

  /// No description provided for @noMovementsYet.
  ///
  /// In en, this message translates to:
  /// **'No stock movements yet'**
  String get noMovementsYet;

  /// No description provided for @deleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product?'**
  String get deleteProductTitle;

  /// No description provided for @deleteProductMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the product and all its stock movements. This cannot be undone.'**
  String get deleteProductMessage;

  /// No description provided for @deleteMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete stock movement?'**
  String get deleteMovementTitle;

  /// No description provided for @deleteMovementMessage.
  ///
  /// In en, this message translates to:
  /// **'This will recalculate the product\'s quantity on hand. This cannot be undone.'**
  String get deleteMovementMessage;

  /// No description provided for @insufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock. Available: {available} {unit}'**
  String insufficientStock(String available, String unit);

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get stockValue;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total products'**
  String get totalProducts;

  /// No description provided for @totalStockValue.
  ///
  /// In en, this message translates to:
  /// **'Total stock value'**
  String get totalStockValue;

  /// No description provided for @lowStockItems.
  ///
  /// In en, this message translates to:
  /// **'Low stock items'**
  String get lowStockItems;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a daily reminder to record your transactions'**
  String get dailyReminderSubtitle;

  /// No description provided for @authenticateReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access Aldeewan'**
  String get authenticateReason;

  /// No description provided for @dailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminderTitle;

  /// No description provided for @dailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to record your transactions for today!'**
  String get dailyReminderBody;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @budgetExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded'**
  String get budgetExceededTitle;

  /// No description provided for @budgetExceededBody.
  ///
  /// In en, this message translates to:
  /// **'{name} exceeded by {amount} {currency}'**
  String budgetExceededBody(Object name, Object amount, Object currency);

  /// No description provided for @goalReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Achieved! 🎉'**
  String get goalReachedTitle;

  /// No description provided for @goalReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your goal: {name}'**
  String goalReachedBody(Object name);

  /// No description provided for @goalContribution.
  ///
  /// In en, this message translates to:
  /// **'Contribution'**
  String get goalContribution;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded'**
  String get budgetExceeded;

  /// No description provided for @insufficientFundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Funds'**
  String get insufficientFundsTitle;

  /// No description provided for @insufficientFundsMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current balance ({balance} {currency}) is not enough for this expense of {amount} {currency}. Please add more funds first.'**
  String insufficientFundsMessage(
    String balance,
    String currency,
    String amount,
  );

  /// No description provided for @tourWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aldeewan!'**
  String get tourWelcome;

  /// No description provided for @tourDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aldeewan!'**
  String get tourDialogTitle;

  /// No description provided for @tourDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Take a quick tour to discover all features?'**
  String get tourDialogBody;

  /// No description provided for @tourStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Tour'**
  String get tourStartButton;

  /// No description provided for @tourSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get tourSkipButton;

  /// No description provided for @tour1Title.
  ///
  /// In en, this message translates to:
  /// **'Your Financial Overview'**
  String get tour1Title;

  /// No description provided for @tour1Desc.
  ///
  /// In en, this message translates to:
  /// **'See your net position at a glance. Toggle \'All Time\' or \'This Month\' for different views.'**
  String get tour1Desc;

  /// No description provided for @tour2Title.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get tour2Title;

  /// No description provided for @tour2Desc.
  ///
  /// In en, this message translates to:
  /// **'Add income, expenses, debts, or scan receipts. Everything starts here.'**
  String get tour2Desc;

  /// No description provided for @tour3Title.
  ///
  /// In en, this message translates to:
  /// **'Budget Tracking'**
  String get tour3Title;

  /// No description provided for @tour3Desc.
  ///
  /// In en, this message translates to:
  /// **'Set spending limits by category. Get alerts before overspending.'**
  String get tour3Desc;

  /// No description provided for @tour4Title.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get tour4Title;

  /// No description provided for @tour4Desc.
  ///
  /// In en, this message translates to:
  /// **'Save toward targets like emergencies, travel, or purchases. Track your progress visually.'**
  String get tour4Desc;

  /// No description provided for @tour5Title.
  ///
  /// In en, this message translates to:
  /// **'Your Network'**
  String get tour5Title;

  /// No description provided for @tour5Desc.
  ///
  /// In en, this message translates to:
  /// **'Customers and suppliers you track. Tap anyone to see full history and balance.'**
  String get tour5Desc;

  /// No description provided for @tour6Title.
  ///
  /// In en, this message translates to:
  /// **'Add People'**
  String get tour6Title;

  /// No description provided for @tour6Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to add new customers or suppliers to your ledger.'**
  String get tour6Desc;

  /// No description provided for @tour7Title.
  ///
  /// In en, this message translates to:
  /// **'Smart Filters'**
  String get tour7Title;

  /// No description provided for @tour7Desc.
  ///
  /// In en, this message translates to:
  /// **'Filter by type (Income/Expense) and time period. Find exactly what you need.'**
  String get tour7Desc;

  /// No description provided for @tour8Title.
  ///
  /// In en, this message translates to:
  /// **'Powerful Search'**
  String get tour8Title;

  /// No description provided for @tour8Desc.
  ///
  /// In en, this message translates to:
  /// **'Search by amount, note, or category. Works across all transactions.'**
  String get tour8Desc;

  /// No description provided for @tour9Title.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get tour9Title;

  /// No description provided for @tour9Desc.
  ///
  /// In en, this message translates to:
  /// **'Your complete financial history. Tap any entry for details or to edit.'**
  String get tour9Desc;

  /// No description provided for @tour10Title.
  ///
  /// In en, this message translates to:
  /// **'Reports & Insights'**
  String get tour10Title;

  /// No description provided for @tour10Desc.
  ///
  /// In en, this message translates to:
  /// **'View cash flow, income vs expense charts, and debt analysis. Export reports anytime.'**
  String get tour10Desc;

  /// No description provided for @tour11Title.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get tour11Title;

  /// No description provided for @tour11Desc.
  ///
  /// In en, this message translates to:
  /// **'Save your data to cloud storage. Never lose your records.'**
  String get tour11Desc;

  /// No description provided for @tour12Title.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get tour12Title;

  /// No description provided for @tour12Desc.
  ///
  /// In en, this message translates to:
  /// **'FAQs, video tutorials, and support. Restart this tour anytime from here.'**
  String get tour12Desc;

  /// No description provided for @tipQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Use Quick Actions for faster entry'**
  String get tipQuickActions;

  /// No description provided for @tipFilterTransactions.
  ///
  /// In en, this message translates to:
  /// **'Filter and search transactions by date, type, or name'**
  String get tipFilterTransactions;

  /// No description provided for @tipPersonBalance.
  ///
  /// In en, this message translates to:
  /// **'Tap a person to see their account'**
  String get tipPersonBalance;

  /// No description provided for @tipBudgetAlert.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you when nearing your budget'**
  String get tipBudgetAlert;

  /// No description provided for @tipGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your savings here'**
  String get tipGoalProgress;

  /// No description provided for @tipEditTransaction.
  ///
  /// In en, this message translates to:
  /// **'Swipe or tap to edit'**
  String get tipEditTransaction;

  /// No description provided for @tipDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Long press to delete'**
  String get tipDeleteTransaction;

  /// No description provided for @tipCurrencyChange.
  ///
  /// In en, this message translates to:
  /// **'Change currency in Settings'**
  String get tipCurrencyChange;

  /// No description provided for @tipBackup.
  ///
  /// In en, this message translates to:
  /// **'Back up regularly to avoid data loss'**
  String get tipBackup;

  /// No description provided for @tipDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Try dark mode for nighttime use'**
  String get tipDarkMode;

  /// No description provided for @tipAppLock.
  ///
  /// In en, this message translates to:
  /// **'Enable app lock for security'**
  String get tipAppLock;

  /// No description provided for @tipExportReport.
  ///
  /// In en, this message translates to:
  /// **'Save reports as files'**
  String get tipExportReport;

  /// No description provided for @tourHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? Come here anytime'**
  String get tourHelp;

  /// No description provided for @tipGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tipGotIt;

  /// No description provided for @goalDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit to Goal'**
  String get goalDeposit;

  /// No description provided for @goalWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal from Goal'**
  String get goalWithdrawal;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs and tutorials'**
  String get helpCenterSubtitle;

  /// No description provided for @restartTour.
  ///
  /// In en, this message translates to:
  /// **'Restart Tutorial'**
  String get restartTour;

  /// No description provided for @restartTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See the app guide again'**
  String get restartTourSubtitle;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @contactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Need help? Reach out to us'**
  String get contactSupportSubtitle;

  /// No description provided for @faqGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get faqGettingStarted;

  /// No description provided for @faqWhatIsAldeewan.
  ///
  /// In en, this message translates to:
  /// **'What is Aldeewan?'**
  String get faqWhatIsAldeewan;

  /// No description provided for @faqWhatIsAldeewaAnswer.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan is a smart accounting app to manage your money, track debts, and set budgets.'**
  String get faqWhatIsAldeewaAnswer;

  /// No description provided for @faqHowToAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'How to add a transaction?'**
  String get faqHowToAddTransaction;

  /// No description provided for @faqHowToAddTransactionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button on any screen to add income or expense.'**
  String get faqHowToAddTransactionAnswer;

  /// No description provided for @faqDataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data & Backup'**
  String get faqDataBackup;

  /// No description provided for @faqDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard & Home'**
  String get faqDashboard;

  /// No description provided for @faqLedger.
  ///
  /// In en, this message translates to:
  /// **'Leger (People)'**
  String get faqLedger;

  /// No description provided for @faqCashbook.
  ///
  /// In en, this message translates to:
  /// **'Cashbook (Income/Expense)'**
  String get faqCashbook;

  /// No description provided for @faqBudgetsGoals.
  ///
  /// In en, this message translates to:
  /// **'Budgets & Goals'**
  String get faqBudgetsGoals;

  /// No description provided for @faqReports.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get faqReports;

  /// No description provided for @faqSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings & Data'**
  String get faqSettings;

  /// No description provided for @faqWhatIsTrueIncome.
  ///
  /// In en, this message translates to:
  /// **'Money In vs True Income?'**
  String get faqWhatIsTrueIncome;

  /// No description provided for @faqWhatIsTrueIncomeAnswer.
  ///
  /// In en, this message translates to:
  /// **'• Money In: All cash you received, including loans or debt repayments.\n• True Income: Only your actual earnings (Sales, Salary).\nUse True Income to see your real profit.'**
  String get faqWhatIsTrueIncomeAnswer;

  /// No description provided for @faqWhatIsNetPosition.
  ///
  /// In en, this message translates to:
  /// **'What is Net Position?'**
  String get faqWhatIsNetPosition;

  /// No description provided for @faqWhatIsNetPositionAnswer.
  ///
  /// In en, this message translates to:
  /// **'It shows your overall financial health: (All Money You Have + People Owe You) minus (Debts You Owe).'**
  String get faqWhatIsNetPositionAnswer;

  /// No description provided for @faqHowToTrackDebt.
  ///
  /// In en, this message translates to:
  /// **'How to track debts?'**
  String get faqHowToTrackDebt;

  /// No description provided for @faqHowToTrackDebtAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Ledger > Add Person > Add Transaction > Choose \'Lent\' (if they borrow from you) or \'Borrowed\' (if you borrow from them).'**
  String get faqHowToTrackDebtAnswer;

  /// No description provided for @faqWhatIsOldDebt.
  ///
  /// In en, this message translates to:
  /// **'What is \'Old Debt\'?'**
  String get faqWhatIsOldDebt;

  /// No description provided for @faqWhatIsOldDebtAnswer.
  ///
  /// In en, this message translates to:
  /// **'Use this for debts that existed before you started using the app. It records the debt without changing your current cash balance.'**
  String get faqWhatIsOldDebtAnswer;

  /// No description provided for @faqCashbookVsLedger.
  ///
  /// In en, this message translates to:
  /// **'Cashbook vs Ledger?'**
  String get faqCashbookVsLedger;

  /// No description provided for @faqCashbookVsLedgerAnswer.
  ///
  /// In en, this message translates to:
  /// **'• Cashbook: For general income/expenses (e.g. Salary, Rent) not linked to a specific person.\n• Ledger: For debts and credits linked to people (Customers/Suppliers).'**
  String get faqCashbookVsLedgerAnswer;

  /// No description provided for @faqHowToBudget.
  ///
  /// In en, this message translates to:
  /// **'How do budget alerts work?'**
  String get faqHowToBudget;

  /// No description provided for @faqHowToBudgetAnswer.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly limit for a category (e.g. Food). The app will notify you when you are close to exceeding it.'**
  String get faqHowToBudgetAnswer;

  /// No description provided for @faqHowToExport.
  ///
  /// In en, this message translates to:
  /// **'How to export reports?'**
  String get faqHowToExport;

  /// No description provided for @faqHowToExportAnswer.
  ///
  /// In en, this message translates to:
  /// **'• Person Statement: Go to Person Details > Export CSV.\n• Debt Report: Go to Analytics > Ledger > Export CSV.'**
  String get faqHowToExportAnswer;

  /// No description provided for @initialBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Starting Balance'**
  String get initialBalanceTitle;

  /// No description provided for @initialBalanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the money you currently have to start tracking accurately.'**
  String get initialBalanceDescription;

  /// No description provided for @cashOnHand.
  ///
  /// In en, this message translates to:
  /// **'Cash on Hand'**
  String get cashOnHand;

  /// No description provided for @bankBalance.
  ///
  /// In en, this message translates to:
  /// **'Bank Balance'**
  String get bankBalance;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go!'**
  String get letsGo;

  /// No description provided for @initialBalanceNote.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get initialBalanceNote;

  /// No description provided for @backupToCloud.
  ///
  /// In en, this message translates to:
  /// **'Backup to Cloud'**
  String get backupToCloud;

  /// No description provided for @backupToCloudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save to Google Drive, Dropbox, OneDrive, etc.'**
  String get backupToCloudSubtitle;

  /// No description provided for @restoreFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromCloud;

  /// No description provided for @restoreFromCloudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import data from a backup file'**
  String get restoreFromCloudSubtitle;

  /// No description provided for @restoreHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Restore from Cloud'**
  String get restoreHelpTitle;

  /// No description provided for @restoreHelpStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Open your cloud app (Google Drive, Dropbox, etc.)'**
  String get restoreHelpStep1;

  /// No description provided for @restoreHelpStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Find your Aldeewan backup file'**
  String get restoreHelpStep2;

  /// No description provided for @restoreHelpStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Download it to your device'**
  String get restoreHelpStep3;

  /// No description provided for @restoreHelpStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Return here and tap \'Restore from Backup\''**
  String get restoreHelpStep4;

  /// No description provided for @restoreHelpStep5.
  ///
  /// In en, this message translates to:
  /// **'5. Select the downloaded file'**
  String get restoreHelpStep5;

  /// No description provided for @faqHowToBackup.
  ///
  /// In en, this message translates to:
  /// **'How do I backup my data?'**
  String get faqHowToBackup;

  /// No description provided for @faqHowToBackupAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Backup to Cloud. Your data will be saved as a JSON file that you can store in Google Drive, Dropbox, or any cloud app.'**
  String get faqHowToBackupAnswer;

  /// No description provided for @faqHowToRestore.
  ///
  /// In en, this message translates to:
  /// **'How do I restore from a backup?'**
  String get faqHowToRestore;

  /// No description provided for @faqHowToRestoreAnswer.
  ///
  /// In en, this message translates to:
  /// **'1. Download your backup file from cloud storage to your device. 2. Go to Settings > Restore from Backup. 3. Select the downloaded JSON file.'**
  String get faqHowToRestoreAnswer;

  /// No description provided for @faqWhereIsData.
  ///
  /// In en, this message translates to:
  /// **'Where is my data stored?'**
  String get faqWhereIsData;

  /// No description provided for @faqWhereIsDataAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored locally on your device in an encrypted database. It never leaves your device unless you choose to backup to cloud.'**
  String get faqWhereIsDataAnswer;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @moreItems.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get moreItems;

  /// No description provided for @deletePerson.
  ///
  /// In en, this message translates to:
  /// **'Delete Person'**
  String get deletePerson;

  /// No description provided for @archivePerson.
  ///
  /// In en, this message translates to:
  /// **'Archive Person'**
  String get archivePerson;

  /// No description provided for @deletePersonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This action cannot be undone.'**
  String deletePersonConfirm(String name);

  /// No description provided for @deletePersonWithTransactions.
  ///
  /// In en, this message translates to:
  /// **'{name} has {count} transactions. What would you like to do?'**
  String deletePersonWithTransactions(String name, int count);

  /// No description provided for @cannotDeleteWithBalance.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete {name}. Outstanding balance: {amount}. Please settle first or archive.'**
  String cannotDeleteWithBalance(String name, String amount);

  /// No description provided for @personArchived.
  ///
  /// In en, this message translates to:
  /// **'Person archived successfully'**
  String get personArchived;

  /// No description provided for @personDeleted.
  ///
  /// In en, this message translates to:
  /// **'Person deleted successfully'**
  String get personDeleted;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @archivedPersons.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedPersons;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show Archived'**
  String get showArchived;

  /// No description provided for @debtBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Debt Breakdown'**
  String get debtBreakdown;

  /// No description provided for @debtAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Debt Analysis'**
  String get debtAnalysis;

  /// No description provided for @exportDebtReport.
  ///
  /// In en, this message translates to:
  /// **'Export Debt Report'**
  String get exportDebtReport;

  /// No description provided for @customersCount.
  ///
  /// In en, this message translates to:
  /// **'Customers ({count})'**
  String customersCount(Object count);

  /// No description provided for @suppliersCount.
  ///
  /// In en, this message translates to:
  /// **'Suppliers ({count})'**
  String suppliersCount(Object count);

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @weeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummaryTitle;

  /// No description provided for @weeklySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Income: {income} | Expense: {expense}'**
  String weeklySummaryBody(Object income, Object expense);

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please check storage space.'**
  String get saveFailed;

  /// No description provided for @lowStorageWarning.
  ///
  /// In en, this message translates to:
  /// **'Storage is running low. Please free up space.'**
  String get lowStorageWarning;

  /// No description provided for @databaseError.
  ///
  /// In en, this message translates to:
  /// **'A database error occurred. Your data may not have been saved.'**
  String get databaseError;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @appFeatures.
  ///
  /// In en, this message translates to:
  /// **'App Features'**
  String get appFeatures;

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

  /// No description provided for @aboutAldeewanDescription.
  ///
  /// In en, this message translates to:
  /// **'Aldeewan is your ultimate financial companion, designed to help you track your money, manage debts, and achieve your financial goals with ease and intelligence.'**
  String get aboutAldeewanDescription;

  /// No description provided for @backupEncrypt.
  ///
  /// In en, this message translates to:
  /// **'Encrypt Backup'**
  String get backupEncrypt;

  /// No description provided for @backupEncryptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect with password'**
  String get backupEncryptSubtitle;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @restoreStrategyTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Method'**
  String get restoreStrategyTitle;

  /// No description provided for @restoreStrategyDesc.
  ///
  /// In en, this message translates to:
  /// **'How would you like to restore this file?'**
  String get restoreStrategyDesc;

  /// No description provided for @restoreMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge Data'**
  String get restoreMerge;

  /// No description provided for @restoreMergeDesc.
  ///
  /// In en, this message translates to:
  /// **'Add to current data. Updates existing items.'**
  String get restoreMergeDesc;

  /// No description provided for @restoreReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get restoreReplace;

  /// No description provided for @restoreReplaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Danger: Deletes all current data.'**
  String get restoreReplaceDesc;

  /// No description provided for @restoreReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'This will PERMANENTLY DELETE all current data. Are you sure?'**
  String get restoreReplaceWarning;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid Password'**
  String get invalidPassword;

  /// No description provided for @schemaVersionMismatch.
  ///
  /// In en, this message translates to:
  /// **'Backup is from a newer version of the app. Please update Aldeewan.'**
  String get schemaVersionMismatch;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next Month'**
  String get nextMonth;

  /// No description provided for @splitBill.
  ///
  /// In en, this message translates to:
  /// **'Split Bill'**
  String get splitBill;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @equal.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get equal;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @exact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get exact;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @fullyAllocated.
  ///
  /// In en, this message translates to:
  /// **'Fully Allocated'**
  String get fullyAllocated;

  /// No description provided for @splitBillSaved.
  ///
  /// In en, this message translates to:
  /// **'Split bill saved successfully'**
  String get splitBillSaved;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;
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
