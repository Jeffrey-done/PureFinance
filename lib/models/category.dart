import 'package:flutter/foundation.dart';

enum CategoryType { expense, income }

@immutable
class Category {
  final String id;
  final String name;
  final CategoryType type;
  final String? parentId;
  final String? icon;
  final String? color;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.icon,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      parentId: json['parentId'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'parentId': parentId,
      'icon': icon,
      'color': color,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? parentId,
    String? icon,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
