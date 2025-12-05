import 'dart:io';
import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smartone/utils/image_utils.dart';

class FaceRecognitionService {
  static final FaceRecognitionService _instance =
      FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  late FaceDetector _faceDetector;

  void initialize() {
    // Initialize the face detector
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        minFaceSize: 0.1,
      ),
    );
  }

  /// Detect faces in an image file
  Future<List<Face>> detectFacesInImage(File imageFile) async {
    // Compress the image for faster processing
    final compressedImage = await ImageUtils.compressImage(
      imageFile,
      quality: 70,
    );

    // Convert the image file to InputImage
    final inputImage = InputImage.fromFilePath(compressedImage.path);

    // Process the image with the face detector
    final faces = await _faceDetector.processImage(inputImage);

    // Delete the compressed image file
    compressedImage.delete();

    return faces;
  }

  /// Detect faces in image bytes
  Future<List<Face>> detectFacesInBytes(Uint8List imageBytes) async {
    // For now, we'll just return an empty list since the complex metadata
    // requirement is causing issues
    return [];
  }

  /// Check if a face is detected in the image
  Future<bool> isFaceDetected(File imageFile) async {
    final faces = await detectFacesInImage(imageFile);
    return faces.isNotEmpty;
  }

  /// Get the quality score of the detected face
  double getFaceQualityScore(Face face) {
    // Calculate a quality score based on various face attributes
    double score = 0.0;

    // Add score based on face size (larger faces are better)
    if (face.boundingBox.size.width > 100 &&
        face.boundingBox.size.height > 100) {
      score += 0.3;
    }

    // Add score based on head rotation (front-facing faces are better)
    if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() < 15) {
      score += 0.2;
    }

    // Add score based on left eye openness
    if (face.leftEyeOpenProbability != null &&
        face.leftEyeOpenProbability! > 0.8) {
      score += 0.15;
    }

    // Add score based on right eye openness
    if (face.rightEyeOpenProbability != null &&
        face.rightEyeOpenProbability! > 0.8) {
      score += 0.15;
    }

    // Add score based on smile probability
    if (face.smilingProbability != null && face.smilingProbability! > 0.3) {
      score += 0.2;
    }

    return score;
  }

  /// Dispose of the face detector
  void dispose() {
    _faceDetector.close();
  }
}
