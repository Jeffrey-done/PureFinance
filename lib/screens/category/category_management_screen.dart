import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/category_icon_widget.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('分类管理'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '支出'),
              Tab(text: '收入'),
            ],
          ),
        ),
        body: Consumer<CategoryProvider>(
          builder: (context, provider, _) {
            return TabBarView(
              children: [
                _CategoryGrid(
                  categories: provider.getExpenseCategories(),
                  type: CategoryType.expense,
                ),
                _CategoryGrid(
                  categories: provider.getIncomeCategories(),
                  type: CategoryType.income,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final CategoryType type;

  const _CategoryGrid({required this.categories, required this.type});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return _buildAddButton(context);
        }
        final category = categories[index];
        return _buildCategoryItem(context, category);
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () => _showEditDialog(context, category),
      onLongPress: () => _showDeleteDialog(context, category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryIconWidget(
            iconCode: category.icon,
            colorHex: category.color,
            size: 44,
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEditDialog(context, null),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '添加',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Category? category) {
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedColor = category?.color ?? '#1565C0';
    String selectedIcon = category?.icon ?? '0xe3e0';

    const colorOptions = [
      '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4',
      '#FFEAA7', '#DDA0DD', '#98D8C8', '#95A5A6',
      '#2ECC71', '#3498DB', '#F39C12', '#1ABC9C',
    ];

    const iconOptions = [
      '0xe56c', '0xe1d7', '0xf37e', '0xe318',
      '0xe40f', '0xe3f3', '0xe80c', '0xe3e0',
      '0xe0af', '0xeb3d', '0xe8e5', '0xe05c',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(category != null ? '编辑分类' : '添加分类'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '分类名称'),
                    ),
                    const SizedBox(height: 16),
                    const Text('颜色'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colorOptions.map((color) {
                        final isSelected = selectedColor == color;
                        final parsedColor = Color(
                          int.parse('FF${color.replaceFirst('#', '')}', radix: 16),
                        );
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: parsedColor,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(width: 2, color: Colors.black)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('图标'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: iconOptions.map((iconCode) {
                        final isSelected = selectedIcon == iconCode;
                        final codePoint = int.parse(iconCode);
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = iconCode;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              IconData(codePoint, fontFamily: 'MaterialIcons'),
                              size: 18,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) return;
                    final provider = ctx.read<CategoryProvider>();
                    if (category != null) {
                      provider.updateCategory(category.copyWith(
                        name: nameController.text,
                        icon: selectedIcon,
                        color: selectedColor,
                      ));
                    } else {
                      provider.addCategory(Category(
                        id: const Uuid().v4(),
                        name: nameController.text,
                        type: type,
                        icon: selectedIcon,
                        color: selectedColor,
                      ));
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除分类"${category.name}"吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ctx.read<CategoryProvider>().deleteCategory(category.id);
                Navigator.pop(ctx);
              },
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
