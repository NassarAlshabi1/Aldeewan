import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aldeewan_mobile/presentation/widgets/bottom_nav_bar.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _currentIndex = 0;
  int _prevIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndex();
  }

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIndex();
  }

  void _updateIndex() {
    final currentPath = GoRouterState.of(context).uri.toString();
    final newIndex = _getSelectedIndex(currentPath);
    
    if (newIndex != _currentIndex) {
      _prevIndex = _currentIndex;
      _currentIndex = newIndex;
    }
  }

  int _getSelectedIndex(String path) {
    if (path == '/home' || path == '/') return 0;
    if (path.startsWith('/ledger')) return 1;
    if (path.startsWith('/cashbook')) return 2;
    if (path.startsWith('/inventory')) return 3;
    if (path.startsWith('/analytics')) return 4;
    if (path.startsWith('/settings')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final isOnHome = currentPath == '/home' || currentPath.startsWith('/home?');
    
    // Determine direction: moving to higher index = slide from right (1.0), else left (-1.0)
    final isMovingRight = _currentIndex > _prevIndex;
    final offsetBegin = isMovingRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

    return PopScope(
      canPop: isOnHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            // We only want to animate the sliding for the incoming widget
            // The existing AnimatedSwitcher applies the same transition (reversed) to the outgoing widget
            // which causes the "Cover" effect.
            return SlideTransition(
              position: Tween<Offset>(
                begin: offsetBegin,
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: widget.child,
        ),
        bottomNavigationBar: BottomNavBar(
          currentPath: currentPath,
        ),
      ),
    );
  }
}
