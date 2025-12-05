import 'package:json_annotation/json_annotation.dart';

part 'classroom.g.dart';

@JsonSerializable()
class Classroom {
  final int id;
  final String name;
  final String? description;
  final int? teacherId;
  final String? academicYear;
  final String? gradeLevel;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Classroom({
    required this.id,
    required this.name,
    this.description,
    this.teacherId,
    this.academicYear,
    this.gradeLevel,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) => _$ClassroomFromJson(json);
  Map<String, dynamic> toJson() => _$ClassroomToJson(this);

  Classroom copyWith({
    int? id,
    String? name,
    String? description,
    int? teacherId,
    String? academicYear,
    String? gradeLevel,
    bool? isActive,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      academicYear: academicYear ?? this.academicYear,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
