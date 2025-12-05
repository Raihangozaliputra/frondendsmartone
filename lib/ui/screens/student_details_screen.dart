import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/presentation/widgets/user_profile_card.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class StudentDetailsScreen extends StatelessWidget {
  final String name;
  final String studentId;
  final String email;
  final String profileImageUrl;
  final String className;
  final int attendanceRate;
  final int totalClasses;
  final int attendedClasses;

  const StudentDetailsScreen({
    super.key,
    required this.name,
    required this.studentId,
    required this.email,
    required this.profileImageUrl,
    required this.className,
    required this.attendanceRate,
    required this.totalClasses,
    required this.attendedClasses,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('student_details')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileCard(
              name: name,
              email: email,
              profileImageUrl: profileImageUrl,
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('class_information'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(
                      languageProvider.translate('class'),
                      className,
                      languageProvider,
                    ),
                    _buildInfoRow(
                      languageProvider.translate('student_id'),
                      studentId,
                      languageProvider,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('attendance_summary'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(
                      languageProvider.translate('total_classes'),
                      '$totalClasses',
                      languageProvider,
                    ),
                    _buildInfoRow(
                      languageProvider.translate('attended_classes'),
                      '$attendedClasses',
                      languageProvider,
                    ),
                    _buildInfoRow(
                      languageProvider.translate('absent_classes'),
                      '${totalClasses - attendedClasses}',
                      languageProvider,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            languageProvider.translate('attendance_rate'),
                          ),
                        ),
                        Text(
                          '$attendanceRate%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: attendanceRate >= 80
                                ? Colors.green
                                : attendanceRate >= 60
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: attendanceRate / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        attendanceRate >= 80
                            ? Colors.green
                            : attendanceRate >= 60
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    LanguageProvider languageProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(value),
        ],
      ),
    );
  }
}
