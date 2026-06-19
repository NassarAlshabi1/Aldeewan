import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/data/models/savings_goal_model.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart';

import 'package:aldeewan_mobile/utils/icon_helper.dart';
import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);
    final currency = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##0.##');

    // Calculate totals
    double totalTarget = 0;
    double totalSaved = 0;
    for (var g in budgetState.goals) {
      totalTarget += g.targetAmount;
      totalSaved += g.currentSaved;
    }
    double totalProgress = totalTarget > 0 ? totalSaved / totalTarget : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goals),
      ),
      body: budgetState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade700, Colors.amber.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.currentSaved,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$currency ${formatter.format(totalSaved)}',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.trophy, color: Colors.white, size: 32),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.goalReached((totalProgress * 100).toStringAsFixed(0)),
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                                ),
                                Text(
                                  l10n.targetLabel('$currency ${formatter.format(totalTarget)}'),
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: totalProgress.clamp(0.0, 1.0)),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOut,
                                builder: (context, value, _) => LinearProgressIndicator(
                                  value: value,
                                  minHeight: 8,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                  color: Colors.white,
                                  semanticsLabel: l10n.goalProgress,
                                  semanticsValue: '${(value * 100).toStringAsFixed(0)}%',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Goal progress tip
                  const GoalProgressTip(),

                  // Goals Grid
                  if (budgetState.goals.isEmpty)
                    EmptyState(
                      message: l10n.noEntriesYet,
                      icon: LucideIcons.target,
                      actionLabel: l10n.createGoal,
                      onAction: () => _showAddGoalDialog(context, ref),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: budgetState.goals.length,
                      itemBuilder: (context, index) {
                        final goal = budgetState.goals[index];
                        final progress = goal.targetAmount > 0 ? goal.currentSaved / goal.targetAmount : 0.0;

                        return InkWell(
                          onTap: () => context.push('/goals/${goal.id}'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        IconHelper.getIcon(goal.icon ?? 'target'),
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.plus, size: 20),
                                      onPressed: () => _showAddSavingsDialog(context, ref, goal),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.name,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$currency ${formatter.format(goal.currentSaved)} / $currency ${formatter.format(goal.targetAmount)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
                                        duration: const Duration(milliseconds: 800),
                                        curve: Curves.easeOut,
                                        builder: (context, value, _) => LinearProgressIndicator(
                                          value: value,
                                          minHeight: 6,
                                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
      floatingActionButton: budgetState.goals.isEmpty ? null : FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context, ref),
        icon: const Icon(LucideIcons.plus),
        label: Text(l10n.createGoal),
      ),
    );
  }

  Future<void> _showAddGoalDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    String selectedIcon = 'target';
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.createGoal),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.goalName),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  decoration: InputDecoration(labelText: l10n.targetAmount),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: amountFormatters(allowFraction: true),
                ),
                const SizedBox(height: 24),
                Text(l10n.selectIcon, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: IconHelper.allIconNames.take(12).map((iconName) {
                    final isSelected = selectedIcon == iconName;
                    return InkWell(
                      onTap: () => setState(() => selectedIcon = iconName),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconHelper.getIcon(iconName),
                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                final goal = SavingsGoalModel(
                  ObjectId(),
                  nameController.text,
                  double.tryParse(targetController.text.replaceAll(',', '')) ?? 0,
                  0,
                  icon: selectedIcon,
                );
                
                ref.read(budgetProvider.notifier).addGoal(goal);
                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddSavingsDialog(BuildContext context, WidgetRef ref, SavingsGoalModel goal) async {
    final amountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.addToGoal} ${goal.name}'),
        content: TextField(
          controller: amountController,
          decoration: InputDecoration(labelText: l10n.amount),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: amountFormatters(allowFraction: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
              if (amount > 0) {
                try {
                  await ref.read(budgetProvider.notifier).updateGoal(goal, amount);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context); // Close dialog first
                  final message = switch (e) {
                    InsufficientFundsFailure f => f.toString(),
                    InsufficientSavingsFailure f => f.toString(),
                    _ => e.toString().replaceAll('Exception: ', ''),
                  };
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
