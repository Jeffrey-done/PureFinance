import 'package:flutter_test/flutter_test.dart';
import 'package:pure_finance/models/tag.dart';

void main() {
  group('Tag', () {
    final sampleJson = {
      'id': 'tag-001',
      'name': 'groceries',
      'color': '#4CAF50',
    };

    final sampleTag = Tag(
      id: 'tag-001',
      name: 'groceries',
      color: '#4CAF50',
    );

    test('fromJson creates correct object', () {
      final tag = Tag.fromJson(sampleJson);

      expect(tag.id, 'tag-001');
      expect(tag.name, 'groceries');
      expect(tag.color, '#4CAF50');
    });

    test('toJson produces correct map', () {
      final json = sampleTag.toJson();

      expect(json['id'], 'tag-001');
      expect(json['name'], 'groceries');
      expect(json['color'], '#4CAF50');
    });

    test('fromJson -> toJson roundtrip preserves all data', () {
      final tag = Tag.fromJson(sampleJson);
      final outputJson = tag.toJson();

      expect(outputJson['id'], sampleJson['id']);
      expect(outputJson['name'], sampleJson['name']);
      expect(outputJson['color'], sampleJson['color']);
    });

    test('nullable color field handles null', () {
      final json = {
        'id': 'tag-002',
        'name': 'travel',
        'color': null,
      };

      final tag = Tag.fromJson(json);
      expect(tag.color, isNull);

      final outputJson = tag.toJson();
      expect(outputJson['color'], isNull);
    });

    test('copyWith updates name', () {
      final updated = sampleTag.copyWith(name: 'shopping');

      expect(updated.name, 'shopping');
      expect(updated.id, sampleTag.id);
      expect(updated.color, sampleTag.color);
    });

    test('copyWith updates color', () {
      final updated = sampleTag.copyWith(color: '#FF0000');

      expect(updated.color, '#FF0000');
      expect(updated.id, sampleTag.id);
      expect(updated.name, sampleTag.name);
    });

    test('copyWith updates id', () {
      final updated = sampleTag.copyWith(id: 'tag-new');

      expect(updated.id, 'tag-new');
      expect(updated.name, sampleTag.name);
      expect(updated.color, sampleTag.color);
    });
  });
}
