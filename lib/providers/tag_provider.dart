import 'package:flutter/foundation.dart';

import '../models/tag.dart';
import '../services/database_service.dart';

class TagProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Tag> _tags = [];
  bool _isLoading = false;
  String? _error;

  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTags() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _dbService.query('tags');
      _tags = data.map((map) => Tag.fromJson(Map<String, dynamic>.from(map))).toList();
    } catch (e) {
      debugPrint('TagProvider.loadTags failed: $e');
      _error = '加载标签失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTag(Tag tag) async {
    try {
      await _dbService.insert('tags', tag.toJson());
      _tags.add(tag);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('TagProvider.addTag failed: $e');
      _error = '添加标签失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTag(Tag tag) async {
    try {
      await _dbService.update(
        'tags',
        tag.toJson(),
        where: 'id = ?',
        whereArgs: [tag.id],
      );
      final index = _tags.indexWhere((t) => t.id == tag.id);
      if (index != -1) {
        _tags[index] = tag;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('TagProvider.updateTag failed: $e');
      _error = '更新标签失败: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTag(String id) async {
    try {
      await _dbService.delete('tags', where: 'id = ?', whereArgs: [id]);
      _tags.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('TagProvider.deleteTag failed: $e');
      _error = '删除标签失败: $e';
      notifyListeners();
      return false;
    }
  }
}
