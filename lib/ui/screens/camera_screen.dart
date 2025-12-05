import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:smartone/presentation/widgets/face_detection_overlay.dart';
import 'package:smartone/utils/face_recognition_service.dart';
import 'package:smartone/utils/permission_service.dart';
import 'package:smartone/data/providers/api_client.dart';
import 'package:smartone/presentation/providers/language_provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  List<Rect> _faceRectangles = [];
  String _instruction = '';
  bool _isCameraPermissionGranted = false;
  bool _isDetectingFaces = false;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final isGranted = await PermissionService().requestCameraPermission();
    setState(() {
      _isCameraPermissionGranted = isGranted;
    });

    if (isGranted) {
      _initializeCamera();
      // Initialize face recognition service
      FaceRecognitionService().initialize();
    } else {
      setState(() {
        _instruction = '';
      });
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras.first, ResolutionPreset.high);

      await _controller!.initialize();
      if (mounted) {
        setState(() {});
        // Start face detection
        _startFaceDetection();
      }
    }
  }

  // Start continuous face detection
  void _startFaceDetection() {
    if (_isDetectingFaces) return;
    _isDetectingFaces = true;
    _processFrames();
  }

  // Process frames continuously for face detection
  void _processFrames() async {
    if (!_isDetectingFaces ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    try {
      // Capture a frame
      final image = await _controller!.takePicture();
      final imageFile = File(image.path);

      // Detect faces in the image
      final faces = await FaceRecognitionService().detectFacesInImage(
        imageFile,
      );

      // Convert face positions to rectangles for overlay
      final faceRectangles = faces.map((face) => face.boundingBox).toList();

      if (mounted) {
        setState(() {
          _faceRectangles = faceRectangles;
        });
      }

      // Clean up temporary file
      imageFile.delete();
    } catch (e) {
      print('Error in face detection: $e');
    }

    // Continue processing frames
    await Future.delayed(Duration(milliseconds: 300));
    _processFrames();
  }

  @override
  void dispose() {
    _isDetectingFaces = false;
    _controller?.dispose();
    // Dispose of face recognition service
    FaceRecognitionService().dispose();
    super.dispose();
  }

  Future<void> _uploadFaceImage(File imageFile) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'face.jpg',
        ),
      });

      // Upload to Laravel API
      final response = await _apiClient.dio.post(
        '/face/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        // Process face recognition
        await _processFaceRecognition();
      } else {
        throw Exception('Failed to upload image');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<void> _processFaceRecognition() async {
    try {
      final response = await _apiClient.dio.post('/attendance/process');

      if (response.statusCode == 200) {
        // Success - show confirmation
        if (mounted) {
          final languageProvider = Provider.of<LanguageProvider>(
            context,
            listen: false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                languageProvider.translate('attendance_recorded_successfully'),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to process attendance');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Processing failed: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture the image
      final image = await _controller!.takePicture();

      // Convert XFile to File
      final imageFile = File(image.path);

      // Process the image with face recognition
      final faces = await FaceRecognitionService().detectFacesInImage(
        imageFile,
      );

      if (faces.isNotEmpty) {
        // Calculate quality score for the first detected face
        final qualityScore = FaceRecognitionService().getFaceQualityScore(
          faces.first,
        );

        if (qualityScore > 0.7) {
          // High quality face detected - upload to server
          await _uploadFaceImage(imageFile);
        } else {
          // Low quality face detected
          if (mounted) {
            final languageProvider = Provider.of<LanguageProvider>(
              context,
              listen: false,
            );
            // Show quality warning dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(languageProvider.translate('low_quality')),
                content: Text(
                  '${languageProvider.translate('low_quality_description')} Quality Score: ${(qualityScore * 100).toStringAsFixed(1)}%',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(languageProvider.translate('ok')),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        // No face detected
        if (mounted) {
          final languageProvider = Provider.of<LanguageProvider>(
            context,
            listen: false,
          );
          // Show no face detected dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(languageProvider.translate('no_face_detected')),
              content: Text(languageProvider.translate('no_face_description')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(languageProvider.translate('ok')),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final languageProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(languageProvider.translate('error')),
            content: Text(
              '${languageProvider.translate('failed')} ${languageProvider.translate('capture_image').toLowerCase()}: $e',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(languageProvider.translate('ok')),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    // Initialize instruction text
    if (_instruction.isEmpty) {
      _instruction = languageProvider.translate('position_face_frame');
    }

    if (!_isCameraPermissionGranted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                languageProvider.translate('camera'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                languageProvider.translate('camera_permission_denied'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: Text(languageProvider.translate('grant_permission')),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          FaceDetectionOverlay(
            imageSize: MediaQuery.of(context).size,
            faceRectangles: _faceRectangles,
            instruction: _faceRectangles.isNotEmpty
                ? languageProvider.translate('face_detected')
                : languageProvider.translate('position_face_frame'),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: _isProcessing
                  ? CircularProgressIndicator()
                  : FloatingActionButton(
                      onPressed: _captureImage,
                      child: Icon(Icons.camera),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
