import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/dual_date_text.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';

class CashbookListItem extends StatelessWidget {
  final Transaction transaction;
  final String? personName;
  final dynamic category; // Can be Category or CategoryModel
  final String currency;
  final NumberFormat numberFormat;
  final String Function(TransactionType, AppLocalizations) getTransactionLabel;

  const CashbookListItem({
    super.key,
    required this.transaction,
    this.personName,
    this.category,
    required this.currency,
    required this.numberFormat,
    required this.getTransactionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Income = cash came in (including borrowed money)
    final isIncome = transaction.type == TransactionType.paymentReceived ||
        transaction.type == TransactionType.cashSale ||
        transaction.type == TransactionType.cashIncome ||
        transaction.type == TransactionType.debtTaken;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          onTap: () {
            context.push('/transaction', extra: transaction);
          },
          leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: category != null 
                  ? category.color.withValues(alpha: 0.1)
                  : (isIncome ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              category != null ? category.icon : (isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight),
              color: category != null ? category.color : (isIncome ? AppColors.success : AppColors.error),
              size: 20.sp,
            ),
          ),
          title: Text(
            category != null ? CategoryHelper.getLocalizedCategory(category.name, l10n) : getTransactionLabel(transaction.type, l10n),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Row(
                children: [
                  DualDateText(
                    date: transaction.date,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (personName != null) ...[
                    SizedBox(width: 8.w),
                    Icon(LucideIcons.user, size: 12.sp, color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        personName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  transaction.note!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.currencyCode ?? currency} ${numberFormat.format(transaction.amount)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppColors.success : AppColors.error,
                ),
              ),
              // Show currency badge when transaction currency differs
              // from the app default (passed in via `currency`).
              if (transaction.currencyCode != null &&
                  transaction.currencyCode != currency)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      transaction.currencyCode!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
