import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/models/category.dart';

void main() {
  group('Category', () {
    final sampleJson = {
      'id': 'cat-001',
      'name': 'Food',
      'type': 'CategoryType.expense',
      'parentId': null,
      'icon': '0xe56c',
      'color': '#FF6B6B',
    };

    final sampleCategory = Category(
      id: 'cat-001',
      name: 'Food',
      type: CategoryType.expense,
      parentId: null,
      icon: '0xe56c',
      color: '#FF6B6B',
    );

    test('fromJson creates correct object', () {
      final category = Category.fromJson(sampleJson);

      expect(category.id, 'cat-001');
      expect(category.name, 'Food');
      expect(category.type, CategoryType.expense);
      expect(category.parentId, isNull);
      expect(category.icon, '0xe56c');
      expect(category.color, '#FF6B6B');
    });

    test('toJson produces correct map', () {
      final json = sampleCategory.toJson();

      expect(json['id'], 'cat-001');
      expect(json['name'], 'Food');
      expect(json['type'], 'CategoryType.expense');
      expect(json['parentId'], isNull);
      expect(json['icon'], '0xe56c');
      expect(json['color'], '#FF6B6B');
    });

    test('fromJson -> toJson roundtrip preserves all data', () {
      final category = Category.fromJson(sampleJson);
      final outputJson = category.toJson();

      expect(outputJson['id'], sampleJson['id']);
      expect(outputJson['name'], sampleJson['name']);
      expect(outputJson['type'], sampleJson['type']);
      expect(outputJson['parentId'], sampleJson['parentId']);
      expect(outputJson['icon'], sampleJson['icon']);
      expect(outputJson['color'], sampleJson['color']);
    });

    test('both CategoryType values parse correctly', () {
      for (final type in CategoryType.values) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['type'] = type.toString();
        final category = Category.fromJson(json);
        expect(category.type, type);
      }
    });

    test('CategoryType has expense and income', () {
      expect(CategoryType.values, contains(CategoryType.expense));
      expect(CategoryType.values, contains(CategoryType.income));
      expect(CategoryType.values.length, 2);
    });

    test('parentId null for top-level categories', () {
      final topLevel = Category.fromJson(sampleJson);
      expect(topLevel.parentId, isNull);
    });

    test('parentId non-null for subcategories', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['id'] = 'cat-002';
      json['name'] = 'Fast Food';
      json['parentId'] = 'cat-001';

      final subCategory = Category.fromJson(json);
      expect(subCategory.parentId, 'cat-001');
    });

    test('copyWith updates fields correctly', () {
      final updated = sampleCategory.copyWith(
        name: 'Dining',
        color: '#00FF00',
      );

      expect(updated.name, 'Dining');
      expect(updated.color, '#00FF00');
      // Preserved fields
      expect(updated.id, sampleCategory.id);
      expect(updated.type, sampleCategory.type);
      expect(updated.parentId, sampleCategory.parentId);
      expect(updated.icon, sampleCategory.icon);
    });

    test('copyWith can set parentId to make subcategory', () {
      final subCategory = sampleCategory.copyWith(parentId: 'parent-001');
      expect(subCategory.parentId, 'parent-001');
    });
  });
}
