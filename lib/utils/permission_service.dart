import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status == PermissionStatus.granted;
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.locationWhenInUse.status;
    return status == PermissionStatus.granted;
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status == PermissionStatus.granted;
  }

  /// Open app settings to allow user to grant permissions
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
