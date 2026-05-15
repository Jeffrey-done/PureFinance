import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../services/database_service.dart';

class CategoryProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _dbService.query('categories');
      _categories = data.map((map) => Category.fromJson(Map<String, dynamic>.from(map))).toList();
      if (_categories.isEmpty) {
        await _seedDefaultCategories();
      }
    } catch (e) {
      debugPrint('CategoryProvider.loadCategories failed: $e');
      _error = '加载分类失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(Category category) async {
    try {
      await _dbService.insert('categories', category.toJson());
      _categories.add(category);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CategoryProvider.addCategory failed: $e');
      _error = '添加分类失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      await _dbService.update(
        'categories',
        category.toJson(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('CategoryProvider.updateCategory failed: $e');
      _error = '更新分类失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _dbService.delete('categories', where: 'id = ?', whereArgs: [id]);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CategoryProvider.deleteCategory failed: $e');
      _error = '删除分类失败: $e';
      notifyListeners();
      return false;
    }
  }

  List<Category> getExpenseCategories() {
    return _categories.where((c) => c.type == CategoryType.expense && c.parentId == null).toList();
  }

  List<Category> getIncomeCategories() {
    return _categories.where((c) => c.type == CategoryType.income && c.parentId == null).toList();
  }

  List<Category> getSubCategories(String parentId) {
    return _categories.where((c) => c.parentId == parentId).toList();
  }

  Future<void> _seedDefaultCategories() async {
    const uuid = Uuid();

    final defaultCategories = <Category>[
      // Expense categories
      Category(
        id: uuid.v4(),
        name: '\u9910\u996e',
        type: CategoryType.expense,
        icon: '0xe56c',
        color: '#FF6B6B',
      ),
      Category(
        id: uuid.v4(),
        name: '\u4ea4\u901a',
        type: CategoryType.expense,
        icon: '0xe1d7',
        color: '#4ECDC4',
      ),
      Category(
        id: uuid.v4(),
        name: '\u8d2d\u7269',
        type: CategoryType.expense,
        icon: '0xf37e',
        color: '#45B7D1',
      ),
      Category(
        id: uuid.v4(),
        name: '\u4f4f\u623f',
        type: CategoryType.expense,
        icon: '0xe318',
        color: '#96CEB4',
      ),
      Category(
        id: uuid.v4(),
        name: '\u5a31\u4e50',
        type: CategoryType.expense,
        icon: '0xe40f',
        color: '#FFEAA7',
      ),
      Category(
        id: uuid.v4(),
        name: '\u533b\u7597',
        type: CategoryType.expense,
        icon: '0xe3f3',
        color: '#DDA0DD',
      ),
      Category(
        id: uuid.v4(),
        name: '\u6559\u80b2',
        type: CategoryType.expense,
        icon: '0xe80c',
        color: '#98D8C8',
      ),
      Category(
        id: uuid.v4(),
        name: '\u5176\u4ed6',
        type: CategoryType.expense,
        icon: '0xe3e0',
        color: '#95A5A6',
      ),
      // Income categories
      Category(
        id: uuid.v4(),
        name: '\u5de5\u8d44',
        type: CategoryType.income,
        icon: '0xe0af',
        color: '#2ECC71',
      ),
      Category(
        id: uuid.v4(),
        name: '\u517c\u804c',
        type: CategoryType.income,
        icon: '0xeb3d',
        color: '#3498DB',
      ),
      Category(
        id: uuid.v4(),
        name: '\u6295\u8d44\u6536\u76ca',
        type: CategoryType.income,
        icon: '0xe8e5',
        color: '#F39C12',
      ),
      Category(
        id: uuid.v4(),
        name: '\u5176\u4ed6\u6536\u5165',
        type: CategoryType.income,
        icon: '0xe05c',
        color: '#1ABC9C',
      ),
    ];

    for (final category in defaultCategories) {
      await _dbService.insert('categories', category.toJson());
    }
    _categories = defaultCategories;
  }
}
