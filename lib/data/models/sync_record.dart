import 'package:hive/hive.dart';

part 'sync_record.g.dart';

@HiveType(typeId: 2)
class SyncRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String entityType; // 'user', 'attendance', etc.

  @HiveField(2)
  final String entityId;

  @HiveField(3)
  final String operation; // 'create', 'update', 'delete'

  @HiveField(4)
  final Map<String, dynamic> data;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final bool synced;

  SyncRecord({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.synced = false,
  });

  SyncRecord copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? synced,
  }) {
    return SyncRecord(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }
}
