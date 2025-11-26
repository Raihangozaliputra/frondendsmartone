import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartone/data/models/user.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

@freezed
class Attendance with _$Attendance {
  const factory Attendance({
    required String id,
    required String userId,
    required DateTime checkInTime,
    DateTime? checkOutTime,
    required double latitude,
    required double longitude,
    String? imageUrl,
    String? status, // "present", "late", "absent"
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);
}
