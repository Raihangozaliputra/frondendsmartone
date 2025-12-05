import 'package:flutter/material.dart';

class FaceDetectionOverlay extends StatelessWidget {
  final Size imageSize;
  final List<Rect> faceRectangles;
  final String? instruction;

  const FaceDetectionOverlay({
    super.key,
    required this.imageSize,
    required this.faceRectangles,
    this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // This is where the camera preview would be
        Container(
          color: Colors.black,
          child: Center(
            child: Text(
              'Camera Preview',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        // Face detection overlay
        if (faceRectangles.isNotEmpty)
          ...faceRectangles.map((rect) {
            return Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.face,
                  color: Colors.green.withOpacity(0.5),
                  size: 30,
                ),
              ),
            );
          }).toList(),
        // Instruction overlay
        if (instruction != null)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  instruction!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        // Face count indicator
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: faceRectangles.length > 0
                    ? Colors.green.withOpacity(0.8)
                    : Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                faceRectangles.length > 0
                    ? 'Face Detected (${faceRectangles.length})'
                    : 'No Face Detected',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
