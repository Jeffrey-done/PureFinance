import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';

class AddAccountScreen extends StatefulWidget {
  final Account? account;

  const AddAccountScreen({super.key, this.account});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _selectedType = AccountType.cash;
  String _selectedColor = '#1565C0';
  String _selectedIcon = '0xe0af';

  bool get _isEditing => widget.account != null;

  static const List<String> _colorOptions = [
    '#1565C0',
    '#2E7D32',
    '#E65100',
    '#4A148C',
    '#B71C1C',
    '#01579B',
    '#F57F17',
    '#1B5E20',
    '#880E4F',
    '#311B92',
  ];

  static const List<String> _iconOptions = [
    '0xe0af', // attach_money
    '0xe25c', // account_balance
    '0xe06d', // credit_card
    '0xe8e5', // trending_up
    '0xe57f', // savings
    '0xe263', // wallet
    '0xe870', // store
    '0xe80b', // school
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final account = widget.account!;
      _nameController.text = account.name;
      _balanceController.text = account.balance.toStringAsFixed(2);
      _selectedType = account.type;
      _selectedColor = account.color ?? '#1565C0';
      _selectedIcon = account.icon ?? '0xe0af';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑账户' : '添加账户'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '账户名称'),
              validator: (v) => v == null || v.isEmpty ? '请输入账户名称' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: '账户类型'),
              items: const [
                DropdownMenuItem(value: AccountType.cash, child: Text('现金')),
                DropdownMenuItem(value: AccountType.bank, child: Text('银行卡')),
                DropdownMenuItem(value: AccountType.creditCard, child: Text('信用卡')),
                DropdownMenuItem(value: AccountType.investment, child: Text('投资')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '初始余额',
                prefixText: '\u00a5 ',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入初始余额';
                if (double.tryParse(v) == null) return '请输入有效金额';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('颜色', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions.map((color) {
                final isSelected = _selectedColor == color;
                final parsedColor = Color(int.parse('FF${color.replaceFirst('#', '')}', radix: 16));
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: parsedColor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('图标', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _iconOptions.map((iconCode) {
                final isSelected = _selectedIcon == iconCode;
                final codePoint = int.parse(iconCode);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconCode;
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Icon(
                      IconData(codePoint, fontFamily: 'MaterialIcons'),
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saveAccount,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(_isEditing ? '更新' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AccountProvider>();
    final account = Account(
      id: _isEditing ? widget.account!.id : const Uuid().v4(),
      name: _nameController.text,
      type: _selectedType,
      balance: double.parse(_balanceController.text),
      currency: 'CNY',
      icon: _selectedIcon,
      color: _selectedColor,
    );

    if (_isEditing) {
      await provider.updateAccount(account);
    } else {
      await provider.addAccount(account);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
