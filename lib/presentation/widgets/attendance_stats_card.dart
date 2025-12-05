import 'package:flutter/material.dart';

class AttendanceStatsCard extends StatelessWidget {
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;

  const AttendanceStatsCard({
    super.key,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });

  @override
  Widget build(BuildContext context) {
    final double presentPercentage = totalStudents > 0
        ? (presentCount + lateCount) / totalStudents * 100
        : 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalStudents.toString(), Colors.blue),
                _buildStatItem(
                  'Present',
                  presentCount.toString(),
                  Colors.green,
                ),
                _buildStatItem('Absent', absentCount.toString(), Colors.red),
                _buildStatItem('Late', lateCount.toString(), Colors.orange),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: presentPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      presentPercentage >= 80
                          ? Colors.green
                          : presentPercentage >= 60
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '${presentPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
