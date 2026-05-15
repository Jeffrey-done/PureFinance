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

  Object? initError;
  StackTrace? initStack;

  try {
    if (kIsWeb) {
      // Use the IndexedDB-backed factory on web. This requires the
      // sqflite worker assets (sqflite_sw.js + sqlite3.wasm) to be
      // present under web/. Run `dart run sqflite_common_ffi_web:setup`
      // before `flutter build web` to install them.
      databaseFactory = databaseFactoryFfiWeb;
    }
    await DatabaseService().database;
  } catch (e, st) {
    // Don't let DB init failures result in a permanent white screen.
    // Surface the error so users can see what went wrong on the deployed page.
    debugPrint('PureFinance init failed: $e\n$st');
    initError = e;
    initStack = st;
  }

  if (initError != null) {
    runApp(_StartupErrorApp(error: initError, stackTrace: initStack));
  } else {
    runApp(const PureFinanceApp());
  }
}

class PureFinanceApp extends StatelessWidget {
  const PureFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemeMode()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()..loadTransactions()),
        ChangeNotifierProvider(create: (_) => AccountProvider()..loadAccounts()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..loadCategories()),
        ChangeNotifierProvider(create: (_) => TagProvider()..loadTags()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()..loadSubscriptions()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..loadBudgets()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'PureFinance',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}

/// Fallback app shown when initialization fails. Prevents a permanent
/// white screen and gives the user actionable diagnostic information.
class _StartupErrorApp extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;

  const _StartupErrorApp({this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureFinance',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('启动失败')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '应用初始化失败',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (kIsWeb) ...[
                const Text(
                  'Web 版常见原因：缺少 sqflite 的 worker 资源文件。',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  '请在构建前运行：\n'
                  '  dart run sqflite_common_ffi_web:setup\n'
                  '然后执行：\n'
                  '  flutter build web --release\n'
                  '将 build/web/ 整个目录部署到服务器。\n'
                  '若部署在子路径，需附加 --base-href=/your-path/',
                ),
                const SizedBox(height: 16),
              ],
              const Text('错误信息：', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              SelectableText('$error'),
              if (stackTrace != null) ...[
                const SizedBox(height: 16),
                const Text('Stack trace：', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                SelectableText(
                  stackTrace.toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
