import 'package:flutter/material.dart';

import '../account/account_list_screen.dart';
import '../category/category_management_screen.dart';
import '../budget/budget_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSection(context, '外观', [
            _SettingsTile(
              icon: Icons.dark_mode,
              title: '深色模式',
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  // Theme switching handled by ThemeProvider
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('主题切换跟随系统设置')),
                  );
                },
              ),
            ),
          ]),
          _buildSection(context, '数据管理', [
            _SettingsTile(
              icon: Icons.account_balance_wallet,
              title: '账户管理',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountListScreen()),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.category,
              title: '分类管理',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CategoryManagementScreen(),
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.pie_chart,
              title: '预算管理',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BudgetScreen()),
                );
              },
            ),
          ]),
          _buildSection(context, '其他', [
            _SettingsTile(
              icon: Icons.currency_yuan,
              title: '默认货币',
              subtitle: 'CNY (人民币)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('当前仅支持人民币')),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.file_download,
              title: '数据导出',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('即将推出')),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: '关于',
              onTap: () => _showAboutDialog(context),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('关于 PureFinance'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PureFinance'),
              SizedBox(height: 8),
              Text('版本: 1.0.0'),
              SizedBox(height: 8),
              Text('一款简洁高效的个人财务管理应用，帮助您轻松记录和追踪日常收支。'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
