import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceChart extends StatelessWidget {
  final List<double> attendanceData;
  final List<String> weekdays;

  const AttendanceChart({
    super.key,
    required this.attendanceData,
    required this.weekdays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.grey[800],
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${attendanceData[groupIndex].toStringAsFixed(1)}%',
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < weekdays.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        weekdays[index],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}%',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          barGroups: attendanceData.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: value >= 80
                      ? Colors.green
                      : value >= 60
                      ? Colors.orange
                      : Colors.red,
                  width: 16,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  rodStackItems: [
                    BarChartRodStackItem(
                      0,
                      value,
                      value >= 80
                          ? Colors.green
                          : value >= 60
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
