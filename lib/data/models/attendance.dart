import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartone/data/models/user.dart';
import 'package:hive/hive.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

@freezed
class Attendance with _$Attendance {
  @HiveType(typeId: 1)
  const factory Attendance({
    @HiveField(0) required String id,
    @HiveField(1) required String userId,
    @HiveField(2) required DateTime checkInTime,
    @HiveField(3) DateTime? checkOutTime,
    @HiveField(4) required double latitude,
    @HiveField(5) required double longitude,
    @HiveField(6) String? imageUrl,
    @HiveField(7) String? status, // "present", "late", "absent"
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
}
