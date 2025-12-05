import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/data/services/report_service.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/data/services/auth_service.dart';
import 'package:smartone/utils/date_utils.dart' as custom_date_utils;
import 'package:intl/intl.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

// Move enum outside of class to fix compilation error
enum ReportType { daily, monthly, late, custom }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;
  ReportType _selectedReportType = ReportType.daily;
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService().getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _reportData = null;
    });

    try {
      switch (_selectedReportType) {
        case ReportType.daily:
          _reportData = await ReportService().getDailyReport(_selectedDate);
          break;
        case ReportType.monthly:
          _reportData = await ReportService().getMonthlyReport(
            _selectedDate.year,
            _selectedDate.month,
          );
          break;
        case ReportType.late:
          _reportData = await ReportService().getLateReport(
            _startDate,
            _endDate,
          );
          break;
        case ReportType.custom:
          _reportData = await ReportService().getCustomReport(
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('attendance_reports')),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.translate('generate_report'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            DropdownButton<ReportType>(
              value: _selectedReportType,
              onChanged: (ReportType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedReportType = newValue;
                  });
                }
              },
              items: ReportType.values.map<DropdownMenuItem<ReportType>>((
                ReportType value,
              ) {
                return DropdownMenuItem<ReportType>(
                  value: value,
                  child: Text(_getReportTypeName(value, languageProvider)),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            if (_selectedReportType == ReportType.daily ||
                _selectedReportType == ReportType.monthly) ...[
              Row(
                children: [
                  Text('${languageProvider.translate('date')}: '),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  ),
                ],
              ),
            ] else if (_selectedReportType == ReportType.late ||
                _selectedReportType == ReportType.custom) ...[
              Row(
                children: [
                  Text('${languageProvider.translate('start_date')}: '),
                  TextButton(
                    onPressed: () => _selectStartDate(context),
                    child: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('${languageProvider.translate('end_date')}: '),
                  TextButton(
                    onPressed: () => _selectEndDate(context),
                    child: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                  ),
                ],
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateReport,
              child: _isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                        SizedBox(width: 10),
                        Text(languageProvider.translate('generating')),
                      ],
                    )
                  : Text(languageProvider.translate('generate_report')),
            ),
            SizedBox(height: 20),
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (_reportData != null) ...[
              SizedBox(height: 20),
              Text(
                languageProvider.translate('report_summary'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryItem(
                        languageProvider.translate('total_records'),
                        '${_reportData!['total_records'] ?? 0}',
                      ),
                      SizedBox(height: 10),
                      _buildSummaryItem(
                        languageProvider.translate('present'),
                        '${_reportData!['present'] ?? 0}',
                      ),
                      SizedBox(height: 10),
                      _buildSummaryItem(
                        languageProvider.translate('late'),
                        '${_reportData!['late'] ?? 0}',
                      ),
                      SizedBox(height: 10),
                      _buildSummaryItem(
                        languageProvider.translate('absent'),
                        '${_reportData!['absent'] ?? 0}',
                      ),
                      SizedBox(height: 10),
                      _buildSummaryItem(
                        languageProvider.translate('attendance_rate'),
                        '${(_reportData!['attendance_rate'] != null ? (_reportData!['attendance_rate'] * 100).toStringAsFixed(1) : '0.0')}',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                languageProvider.translate('detailed_records'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(child: _buildReportTable(languageProvider)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildReportTable(LanguageProvider languageProvider) {
    final List<dynamic> records = _reportData!['records'] ?? [];

    if (records.isEmpty) {
      return Center(
        child: Text(languageProvider.translate('no_records_found')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(languageProvider.translate('name'))),
          DataColumn(label: Text(languageProvider.translate('date'))),
          DataColumn(label: Text(languageProvider.translate('status'))),
          DataColumn(label: Text(languageProvider.translate('check_in'))),
          DataColumn(label: Text(languageProvider.translate('check_out'))),
        ],
        rows: records.map((record) {
          return DataRow(
            cells: [
              DataCell(Text(record['user']['name'] ?? 'Unknown')),
              DataCell(
                Text(
                  custom_date_utils.DateUtils.formatdate(
                    DateTime.parse(record['date']),
                  ),
                ),
              ),
              DataCell(
                Text(
                  record['status'] ?? 'Unknown',
                  style: TextStyle(
                    color: _getStatusColor(record['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Text(
                  record['check_in_time'] != null
                      ? custom_date_utils.DateUtils.formatTime(
                          DateTime.parse(record['check_in_time']),
                        )
                      : '-',
                ),
              ),
              DataCell(
                Text(
                  record['check_out_time'] != null
                      ? custom_date_utils.DateUtils.formatTime(
                          DateTime.parse(record['check_out_time']),
                        )
                      : '-',
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getReportTypeName(
    ReportType type,
    LanguageProvider languageProvider,
  ) {
    switch (type) {
      case ReportType.daily:
        return languageProvider.translate('daily_report');
      case ReportType.monthly:
        return languageProvider.translate('monthly_report');
      case ReportType.late:
        return languageProvider.translate('late_arrivals_report');
      case ReportType.custom:
        return languageProvider.translate('custom_report');
      default:
        return languageProvider.translate('report');
    }
  }
}
