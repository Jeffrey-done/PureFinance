import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
import 'home_screen.dart';
import 'transaction/transaction_list_screen.dart';
import 'subscription/subscription_list_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionListScreen(),
    SubscriptionListScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Check due subscriptions after the first frame to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDueSubscriptions();
    });
  }

  void _checkDueSubscriptions() {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final dueSubscriptions = subscriptionProvider.checkDueSubscriptions(DateTime.now());
    if (dueSubscriptions.isNotEmpty && mounted) {
      final names = dueSubscriptions.map((s) => s.name).join('、');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('即将到期的订阅: $names'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '查看',
            onPressed: () {
              setState(() {
                _currentIndex = 2; // Switch to subscription tab
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: '账单',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_outlined),
            selectedIcon: Icon(Icons.subscriptions),
            label: '订阅',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '报表',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
