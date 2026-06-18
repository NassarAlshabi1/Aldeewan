import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final String currentPath;

  const BottomNavBar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationBar(
      selectedIndex: _getSelectedIndex(currentPath),
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: [
        NavigationDestination(
          icon: const Icon(LucideIcons.home),
          label: l10n.home, // Overview
        ),
        NavigationDestination(
          icon: const Icon(LucideIcons.users),
          label: l10n.ledger, // People
        ),
        NavigationDestination(
          icon: const Icon(LucideIcons.landmark),
          label: l10n.cashbook,
        ),
        NavigationDestination(
          icon: const Icon(LucideIcons.package),
          label: l10n.inventory, // Inventory tab
        ),
        NavigationDestination(
          icon: const Icon(LucideIcons.pieChart),
          label: l10n.analytics,
        ),
        NavigationDestination(
          icon: const Icon(LucideIcons.settings),
          label: l10n.settings, // More
        ),
      ],
    );
  }

  int _getSelectedIndex(String path) {
    if (path == '/home' || path == '/') return 0;
    if (path.startsWith('/ledger')) return 1;
    if (path.startsWith('/cashbook')) return 2;
    if (path.startsWith('/inventory')) return 3;
    if (path.startsWith('/analytics')) return 4;
    if (path.startsWith('/settings')) return 5;
    return 0; // Default to Overview
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/ledger');
        break;
      case 2:
        context.go('/cashbook');
        break;
      case 3:
        context.go('/inventory');
        break;
      case 4:
        context.go('/analytics');
        break;
      case 5:
        context.go('/settings');
        break;
    }
  }
}
