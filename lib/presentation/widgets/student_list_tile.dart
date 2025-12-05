import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class StudentListTile extends StatelessWidget {
  final String name;
  final String studentId;
  final String? profileImageUrl;
  final String status;
  final DateTime? checkInTime;
  final VoidCallback? onMarkAbsent;
  final VoidCallback? onViewDetails;

  const StudentListTile({
    super.key,
    required this.name,
    required this.studentId,
    this.profileImageUrl,
    required this.status,
    this.checkInTime,
    this.onMarkAbsent,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage: profileImageUrl != null
              ? NetworkImage(profileImageUrl!)
              : null,
          child: profileImageUrl == null ? Icon(Icons.person, size: 20) : null,
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${languageProvider.translate('id')}: $studentId'),
            if (checkInTime != null)
              Text(
                '${languageProvider.translate('check_in_time')}: ${_formatTime(checkInTime!)}',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, color: statusColor),
                Text(
                  _getStatusTranslation(status, languageProvider),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'mark_absent' && onMarkAbsent != null) {
                  onMarkAbsent!();
                } else if (result == 'view_details' && onViewDetails != null) {
                  onViewDetails!();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (status.toLowerCase() != 'absent')
                  PopupMenuItem<String>(
                    value: 'mark_absent',
                    child: Text(languageProvider.translate('mark_absent')),
                  ),
                PopupMenuItem<String>(
                  value: 'view_details',
                  child: Text(languageProvider.translate('view_details')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusTranslation(
    String status,
    LanguageProvider languageProvider,
  ) {
    switch (status.toLowerCase()) {
      case 'present':
        return languageProvider.translate('present');
      case 'absent':
        return languageProvider.translate('absent');
      case 'late':
        return languageProvider.translate('late');
      default:
        return status;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
