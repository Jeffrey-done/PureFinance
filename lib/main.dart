import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'providers/providers.dart';
import 'screens/main_navigation.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  await DatabaseService().database;
  runApp(const PureFinanceApp());
}

class PureFinanceApp extends StatelessWidget {
  const PureFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()..loadTransactions()),
        ChangeNotifierProvider(create: (_) => AccountProvider()..loadAccounts()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..loadCategories()),
        ChangeNotifierProvider(create: (_) => TagProvider()..loadTags()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()..loadSubscriptions()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..loadBudgets()),
      ],
      child: MaterialApp(
        title: 'PureFinance',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainNavigation(),
      ),
    );
  }
}
