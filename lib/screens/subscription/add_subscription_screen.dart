import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/recurring_transaction.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/account_provider.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final RecurringTransaction? subscription;

  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  Frequency _frequency = Frequency.monthly;
  SubscriptionStatus _status = SubscriptionStatus.active;
  DateTime _startDate = DateTime.now();
  String? _selectedCategoryId;
  String? _selectedAccountId;
  int _remindBeforeDays = 3;

  bool get _isEditing => widget.subscription != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final sub = widget.subscription!;
      _nameController.text = sub.name;
      _amountController.text = sub.amount.toStringAsFixed(2);
      _notesController.text = sub.notes ?? '';
      _frequency = sub.frequency;
      _status = sub.status;
      _startDate = sub.startDate;
      _selectedCategoryId = sub.categoryId;
      _selectedAccountId = sub.accountId;
      _remindBeforeDays = sub.remindBeforeDays;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑订阅' : '添加订阅'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '订阅名称'),
              validator: (v) => v == null || v.isEmpty ? '请输入订阅名称' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '金额',
                prefixText: '\u00a5 ',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入金额';
                if (double.tryParse(v) == null) return '请输入有效金额';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Frequency>(
              value: _frequency,
              decoration: const InputDecoration(labelText: '频率'),
              items: const [
                DropdownMenuItem(value: Frequency.monthly, child: Text('月付')),
                DropdownMenuItem(value: Frequency.quarterly, child: Text('季付')),
                DropdownMenuItem(value: Frequency.yearly, child: Text('年付')),
                DropdownMenuItem(value: Frequency.custom, child: Text('自定义')),
              ],
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SubscriptionStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: '状态'),
              items: const [
                DropdownMenuItem(value: SubscriptionStatus.active, child: Text('活跃')),
                DropdownMenuItem(value: SubscriptionStatus.paused, child: Text('暂停')),
                DropdownMenuItem(value: SubscriptionStatus.cancelled, child: Text('已取消')),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('开始日期'),
              subtitle: Text(DateFormat('yyyy年M月d日').format(_startDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildAccountSelector(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: '备注'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text(
              '提前提醒: $_remindBeforeDays 天',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _remindBeforeDays.toDouble(),
              min: 1,
              max: 14,
              divisions: 13,
              label: '$_remindBeforeDays天',
              onChanged: (value) {
                setState(() {
                  _remindBeforeDays = value.round();
                });
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saveSubscription,
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

  Widget _buildCategorySelector() {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.getExpenseCategories();
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(labelText: '分类'),
      items: categories.map((c) {
        return DropdownMenuItem(value: c.id, child: Text(c.name));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (v) => v == null ? '请选择分类' : null,
    );
  }

  Widget _buildAccountSelector() {
    final accounts = context.watch<AccountProvider>().accounts;
    return DropdownButtonFormField<String>(
      value: _selectedAccountId,
      decoration: const InputDecoration(labelText: '账户'),
      items: accounts.map((a) {
        return DropdownMenuItem(value: a.id, child: Text(a.name));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedAccountId = value;
        });
      },
      validator: (v) => v == null ? '请选择账户' : null,
    );
  }

  DateTime _computeNextDueDate() {
    switch (_frequency) {
      case Frequency.monthly:
        return DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
      case Frequency.quarterly:
        return DateTime(_startDate.year, _startDate.month + 3, _startDate.day);
      case Frequency.yearly:
        return DateTime(_startDate.year + 1, _startDate.month, _startDate.day);
      case Frequency.custom:
        return DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
    }
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SubscriptionProvider>();
    final subscription = RecurringTransaction(
      id: _isEditing ? widget.subscription!.id : const Uuid().v4(),
      name: _nameController.text,
      amount: double.parse(_amountController.text),
      currency: 'CNY',
      startDate: _startDate,
      nextDueDate: _isEditing ? widget.subscription!.nextDueDate : _computeNextDueDate(),
      frequency: _frequency,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      status: _status,
      remindBeforeDays: _remindBeforeDays,
    );

    if (_isEditing) {
      await provider.updateSubscription(subscription);
    } else {
      await provider.addSubscription(subscription);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
