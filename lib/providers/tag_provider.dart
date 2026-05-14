import 'package:flutter/foundation.dart';

import '../models/tag.dart';
import '../services/database_service.dart';

class TagProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Tag> _tags = [];

  List<Tag> get tags => _tags;

  Future<void> loadTags() async {
    final data = await _dbService.query('tags');
    _tags = data.map((map) => Tag.fromJson(Map<String, dynamic>.from(map))).toList();
    notifyListeners();
  }

  Future<void> addTag(Tag tag) async {
    await _dbService.insert('tags', tag.toJson());
    _tags.add(tag);
    notifyListeners();
  }

  Future<void> updateTag(Tag tag) async {
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
  }

  Future<void> deleteTag(String id) async {
    await _dbService.delete('tags', where: 'id = ?', whereArgs: [id]);
    _tags.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
