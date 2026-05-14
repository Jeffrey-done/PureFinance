import 'package:flutter/foundation.dart';

@immutable
class Tag {
  final String id;
  final String name;
  final String? color;

  const Tag({
    required this.id,
    required this.name,
    this.color,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    String? color,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
