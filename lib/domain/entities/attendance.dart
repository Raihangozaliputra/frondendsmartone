import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

enum AttendanceStatus { present, late, absent, permission, sick }

@JsonSerializable()
class Attendance {
  final int id;
  final int userId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final double? latitude;
  final double? longitude;
  final String? location;
  final String? notes;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.latitude,
    this.longitude,
    this.location,
    this.notes,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  bool get isCheckedIn => checkIn != null;
  bool get isCheckedOut => checkOut != null;
  bool get isLate => status == AttendanceStatus.late.toString().split('.').last;
  bool get isAbsent => status == AttendanceStatus.absent.toString().split('.').last;

  Attendance copyWith({
    int? id,
    int? userId,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    double? latitude,
    double? longitude,
    String? location,
    String? notes,
    String? imageUrl,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
