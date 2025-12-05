import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:smartone/data/models/attendance.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/data/models/sync_record.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static Box<User>? _userBox;
  static Box<Attendance>? _attendanceBox;
  static Box<SyncRecord>? _syncBox;

  static Box<User> get userBox => _userBox!;
  static Box<Attendance> get attendanceBox => _attendanceBox!;
  static Box<SyncRecord> get syncBox => _syncBox!;

  Future<void> init() async {
    // Initialize Hive
    final appDocumentDir = await path_provider
        .getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(UserImplAdapter());
    Hive.registerAdapter(AttendanceImplAdapter());
    Hive.registerAdapter(SyncRecordAdapter());

    // Open boxes
    _userBox = await Hive.openBox<User>('users');
    _attendanceBox = await Hive.openBox<Attendance>('attendances');
    _syncBox = await Hive.openBox<SyncRecord>('sync_records');
  }

  // User operations
  Future<void> saveUser(User user) async {
    await userBox.put(user.id, user);
  }

  User? getUser(String id) {
    return userBox.get(id);
  }

  Future<void> deleteUser(String id) async {
    await userBox.delete(id);
  }

  List<User> getAllUsers() {
    return userBox.values.toList();
  }

  // Attendance operations
  Future<void> saveAttendance(Attendance attendance) async {
    await attendanceBox.put(attendance.id, attendance);
  }

  Attendance? getAttendance(String id) {
    return attendanceBox.get(id);
  }

  Future<void> deleteAttendance(String id) async {
    await attendanceBox.delete(id);
  }

  List<Attendance> getAllAttendances() {
    return attendanceBox.values.toList();
  }

  // Sync operations
  Future<void> addSyncRecord(SyncRecord record) async {
    await syncBox.put(record.id, record);
  }

  List<SyncRecord> getUnsyncedRecords() {
    return syncBox.values.where((record) => !record.synced).toList();
  }

  Future<void> markRecordAsSynced(String recordId) async {
    final record = syncBox.get(recordId);
    if (record != null) {
      final updatedRecord = record.copyWith(synced: true);
      await syncBox.put(recordId, updatedRecord);
    }
  }

  Future<void> clearSyncedRecords() async {
    final syncedKeys = syncBox.keys
        .where((key) => syncBox.get(key)?.synced == true)
        .toList();
    await syncBox.deleteAll(syncedKeys);
  }

  Future<void> clearAllData() async {
    await userBox.clear();
    await attendanceBox.clear();
    await syncBox.clear();
  }

  Future<void> closeBoxes() async {
    await userBox?.close();
    await attendanceBox?.close();
    await syncBox?.close();
  }
}
