import 'package:dartz/dartz.dart';
import 'package:smartone/domain/entities/attendance.dart';
import 'package:smartone/utils/failure.dart';

abstract class AttendanceRepository {
  // Check-in operations
  Future<Either<Failure, Attendance>> checkIn({
    required String imagePath,
    required double latitude,
    required double longitude,
    String? notes,
  });

  // Check-out operations
  Future<Either<Failure, Attendance>> checkOut({
    required int attendanceId,
    required String imagePath,
    required double latitude,
    required double longitude,
    String? notes,
  });

  // Get attendance history
  Future<Either<Failure, List<Attendance>>> getAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
  });

  // Get today's attendance status
  Future<Either<Failure, Attendance?>> getTodaysAttendance();

  // Process face recognition for attendance
  Future<Either<Failure, Map<String, dynamic>>> processFaceRecognition({
    required String imagePath,
  });

  // Upload face image for registration
  Future<Either<Failure, void>> uploadFaceImage({
    required String imagePath,
    required String userId,
  });
}
