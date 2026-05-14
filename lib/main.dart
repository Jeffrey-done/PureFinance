import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const PureFinanceApp());
}

class PureFinanceApp extends StatelessWidget {
  const PureFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => _PlaceholderProvider()),
      ],
      child: MaterialApp(
        title: 'PureFinance',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PureFinance'),
      ),
      body: const Center(
        child: Text('Welcome to PureFinance'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PlaceholderProvider extends ChangeNotifier {}
