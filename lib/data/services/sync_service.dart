import 'package:smartone/utils/local_database.dart';
import 'package:smartone/data/providers/api_client.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/data/models/attendance.dart';
import 'package:dio/dio.dart';

class SyncRecord {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  bool isSynced;

  SyncRecord({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType,
        'entityId': entityId,
        'operation': operation,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'isSynced': isSynced,
      };

  factory SyncRecord.fromJson(Map<String, dynamic> json) => SyncRecord(
        id: json['id'],
        entityType: json['entityType'],
        entityId: json['entityId'],
        operation: json['operation'],
        data: Map<String, dynamic>.from(json['data']),
        timestamp: DateTime.parse(json['timestamp']),
        isSynced: json['isSynced'] ?? false,
      );
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiClient _apiClient = ApiClient();
  final LocalDatabase _localDatabase = LocalDatabase();

  /// Sinkronkan data lokal dengan server
  Future<void> syncWithServer() async {
    try {
      // Dapatkan semua record yang belum disinkronkan
      final unsyncedRecords = _localDatabase.getUnsyncedRecords();

      print('Menyinkronkan ${unsyncedRecords.length} record...');

      // Proses setiap record
      for (final record in unsyncedRecords) {
        try {
          switch (record.entityType) {
            case 'user':
              await _syncUser(record);
              break;
            case 'attendance':
              await _syncAttendance(record);
              break;
            default:
              print('Tipe entitas tidak dikenal: ${record.entityType}');
              continue;
          }

          // Tandai record sebagai sudah disinkronkan
          await _localDatabase.markRecordAsSynced(record.id);
          print('Berhasil menyinkronkan record: ${record.id}');
        } catch (e) {
          print('Gagal menyinkronkan record ${record.id}: $e');
          // Lanjutkan ke record berikutnya jika ada error
          continue;
        }
      }

      // Bersihkan record yang sudah disinkronkan
      await _localDatabase.clearSyncedRecords();
      print('Selesai menyinkronkan data');
    } catch (e) {
      print('Error saat sinkronisasi: $e');
      rethrow;
    }
  }

  /// Sinkronkan data user
  Future<void> _syncUser(dynamic record) async {
    switch (record.operation) {
      case 'create':
      case 'update':
        // Untuk user, biasanya tidak perlu sinkronisasi langsung
        // Kecuali untuk registrasi atau update profil
        break;
      case 'delete':
        // Hapus user dari server jika diperlukan
        try {
          await _apiClient.dio.delete('/users/${record.entityId}');
        } catch (e) {
          // Abaikan error jika user tidak ditemukan
          if (e is DioException && e.response?.statusCode != 404) {
            rethrow;
          }
        }
        break;
    }
  }

  /// Sinkronkan data attendance
  Future<void> _syncAttendance(dynamic record) async {
    switch (record.operation) {
      case 'create':
        // Kirim data attendance baru ke server
        final response = await _apiClient.dio.post(
          '/attendances',
          data: record.data,
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Jika berhasil, update ID lokal jika diperlukan
          final serverData = response.data['data'];
          final attendance = Attendance.fromJson(serverData);

          // Simpan ke database lokal
          await _localDatabase.saveAttendance(attendance);
        }
        break;
      case 'update':
        // Update data attendance di server
        await _apiClient.dio.put(
          '/attendances/${record.entityId}',
          data: record.data,
        );
        break;
      case 'delete':
        // Hapus data attendance dari server
        try {
          await _apiClient.dio.delete('/attendances/${record.entityId}');
        } catch (e) {
          // Abaikan error jika attendance tidak ditemukan
          if (e is DioException && e.response?.statusCode != 404) {
            rethrow;
          }
        }
        break;
    }
  }

  /// Tambahkan record sinkronisasi untuk user
  Future<void> addUserSyncRecord(User user, String operation) async {
    final record = SyncRecord(
      id: '${user.id}_${operation}_${DateTime.now().millisecondsSinceEpoch}',
      entityType: 'user',
      entityId: user.id,
      operation: operation,
      data: user.toJson(),
      timestamp: DateTime.now(),
    );

    await _localDatabase.addSyncRecord(record);
  }

  /// Tambahkan record sinkronisasi untuk attendance
  Future<void> addAttendanceSyncRecord(
    Attendance attendance,
    String operation,
  ) async {
    final record = SyncRecord(
      id: '${attendance.id}_${operation}_${DateTime.now().millisecondsSinceEpoch}',
      entityType: 'attendance',
      entityId: attendance.id,
      operation: operation,
      data: attendance.toJson(),
      timestamp: DateTime.now(),
    );

    await _localDatabase.addSyncRecord(record);
  }
}
