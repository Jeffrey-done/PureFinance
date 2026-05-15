import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/tag_provider.dart';
import '../../widgets/category_icon_widget.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedTags = [];

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final txn = widget.transaction!;
      _amountController.text = txn.amount.toStringAsFixed(2);
      _notesController.text = txn.notes ?? '';
      _type = txn.type;
      _selectedCategoryId = txn.categoryId;
      _selectedAccountId = txn.accountId;
      _selectedDate = txn.date;
      _selectedTags = txn.tags ?? [];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑交易' : '添加交易'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 20),
            _buildAmountField(),
            const SizedBox(height: 20),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            _buildAccountSelector(),
            if (_type == TransactionType.transfer) ...[
              const SizedBox(height: 20),
              _buildToAccountSelector(),
            ],
            const SizedBox(height: 20),
            _buildDatePicker(),
            const SizedBox(height: 20),
            _buildNotesField(),
            const SizedBox(height: 20),
            _buildTagsSelector(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(value: TransactionType.expense, label: Text('支出')),
        ButtonSegment(value: TransactionType.income, label: Text('收入')),
        ButtonSegment(value: TransactionType.transfer, label: Text('转账')),
      ],
      selected: {_type},
      onSelectionChanged: (selected) {
        setState(() {
          _type = selected.first;
          _selectedCategoryId = null;
        });
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      decoration: const InputDecoration(
        labelText: '金额',
        prefixText: '\u00a5 ',
        hintText: '0.00',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '请输入金额';
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) return '请输入有效金额';
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = _type == TransactionType.income
        ? categoryProvider.getIncomeCategories()
        : categoryProvider.getExpenseCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('分类', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((cat) {
            final isSelected = _selectedCategoryId == cat.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryId = cat.id;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CategoryIconWidget(
                      iconCode: cat.icon,
                      colorHex: cat.color,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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
      validator: (value) => value == null ? '请选择账户' : null,
    );
  }

  Widget _buildToAccountSelector() {
    final accounts = context.watch<AccountProvider>().accounts;
    return DropdownButtonFormField<String>(
      value: _selectedToAccountId,
      decoration: const InputDecoration(labelText: '转入账户'),
      items: accounts
          .where((a) => a.id != _selectedAccountId)
          .map((a) {
        return DropdownMenuItem(value: a.id, child: Text(a.name));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedToAccountId = value;
        });
      },
      validator: (value) =>
          _type == TransactionType.transfer && value == null ? '请选择转入账户' : null,
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: const Text('日期'),
      subtitle: Text(DateFormat('yyyy年M月d日').format(_selectedDate)),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          setState(() {
            _selectedDate = DateTime(
              date.year,
              date.month,
              date.day,
              _selectedDate.hour,
              _selectedDate.minute,
            );
          });
        }
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: '备注',
        hintText: '添加备注...',
      ),
      maxLines: 2,
    );
  }

  Widget _buildTagsSelector() {
    final tagProvider = context.watch<TagProvider>();
    final tags = tagProvider.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('标签', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            final isSelected = _selectedTags.contains(tag.id);
            return FilterChip(
              label: Text(tag.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag.id);
                  } else {
                    _selectedTags.remove(tag.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return FilledButton(
      onPressed: _saveTransaction,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Text(_isEditing ? '更新' : '保存'),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);
    final txnProvider = context.read<TransactionProvider>();
    final accountProvider = context.read<AccountProvider>();

    final transaction = Transaction(
      id: _isEditing ? widget.transaction!.id : const Uuid().v4(),
      type: _type,
      amount: amount,
      currency: 'CNY',
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      toAccountId: _type == TransactionType.transfer ? _selectedToAccountId : null,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      tags: _selectedTags.isEmpty ? null : _selectedTags,
      isRecurring: false,
    );

    if (_isEditing) {
      final oldTxn = widget.transaction!;
      await txnProvider.updateTransaction(transaction);

      // Reverse the old transaction's balance effect
      if (oldTxn.type == TransactionType.expense) {
        await accountProvider.updateBalance(oldTxn.accountId, oldTxn.amount);
      } else if (oldTxn.type == TransactionType.income) {
        await accountProvider.updateBalance(oldTxn.accountId, -oldTxn.amount);
      } else if (oldTxn.type == TransactionType.transfer) {
        // Reverse old transfer: credit source, debit destination
        await accountProvider.updateBalance(oldTxn.accountId, oldTxn.amount);
        if (oldTxn.toAccountId != null) {
          await accountProvider.updateBalance(oldTxn.toAccountId!, -oldTxn.amount);
        }
      }

      // Apply the new transaction's balance effect
      if (_type == TransactionType.expense) {
        await accountProvider.updateBalance(_selectedAccountId!, -amount);
      } else if (_type == TransactionType.income) {
        await accountProvider.updateBalance(_selectedAccountId!, amount);
      } else if (_type == TransactionType.transfer &&
          _selectedToAccountId != null) {
        await accountProvider.transferBalance(
          _selectedAccountId!,
          amount,
          _selectedToAccountId!,
        );
      }
    } else {
      await txnProvider.addTransaction(transaction);
      // Update account balance
      if (_type == TransactionType.expense) {
        await accountProvider.updateBalance(_selectedAccountId!, -amount);
      } else if (_type == TransactionType.income) {
        await accountProvider.updateBalance(_selectedAccountId!, amount);
      } else if (_type == TransactionType.transfer &&
          _selectedToAccountId != null) {
        await accountProvider.transferBalance(
          _selectedAccountId!,
          amount,
          _selectedToAccountId!,
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
