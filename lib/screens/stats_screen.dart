import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

import '../database/database_helper.dart';
import '../models/workout_record.dart';
import '../data/exercise_data.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const Color _backgroundColor = Color(0xFF0B0F19);
  static const Color _cardColor = Color(0xFF1A1F2E);
  static const Color _surfaceVariant = Color(0xFF242B3D);
  static const Color _primaryColor = Color(0xFFF97316);
  static const Color _textColor = Color(0xFFF8FAFC);
  static const Color _mutedColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFF2D3748);
  static const Color _accentColor = Color(0xFF22C55E);
  static const List<Color> _chartColors = [
    Color(0xFFF97316),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
  ];

  List<WorkoutRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final records = await DatabaseHelper.instance.getWorkoutRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  List<MapEntry<String, int>> get _weeklyDurationData {
    final Map<String, int> durationData = {};
    final Map<String, bool> hasRecordData = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = DateFormat('MM/dd').format(day);
      durationData[key] = 0;
      hasRecordData[key] = false;
    }
    for (var record in _records) {
      final key = DateFormat('MM/dd').format(record.dateTime);
      if (durationData.containsKey(key)) {
        durationData[key] = durationData[key]! + record.durationMinutes;
        hasRecordData[key] = true;
      }
    }
    return durationData.entries.toList();
  }

  Map<String, int> get _bodyPartDistribution {
    final Map<String, int> data = {};
    for (var record in _records) {
      data[record.bodyPart] = (data[record.bodyPart] ?? 0) + 1;
    }
    return data;
  }

  List<MapEntry<String, double>> get _fatigueTrend {
    final Map<String, List<int>> data = {};
    for (var record in _records) {
      final key = DateFormat('MM/dd').format(record.dateTime);
      data.putIfAbsent(key, () => []).add(record.fatigueLevel);
    }
    final sortedKeys = data.keys.toList()..sort();
    return sortedKeys.take(7).map((key) {
      final values = data[key]!;
      final avg = values.reduce((a, b) => a + b) / values.length;
      return MapEntry(key, avg);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '数据统计',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        iconTheme: const IconThemeData(color: _textColor),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: _primaryColor,
              backgroundColor: _cardColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: _buildSectionTitle('近7天训练时长'),
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: _buildWeeklyChart(),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildSectionTitle('部位分布'),
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: _buildPieChart(),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: _buildSectionTitle('疲劳度趋势'),
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: _buildFatigueChart(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final data = _weeklyDurationData;
    if (data.every((e) => e.value == 0)) {
      return _buildEmptyChart('近7天暂无训练数据');
    }

    final maxValue =
        data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue < 5 ? 5.0 : maxValue * 1.2).toDouble();
    final interval = maxY / 4;

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: _borderColor.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      if (value != value.toInt().toDouble()) {
                        return const SizedBox();
                      }
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _mutedColor,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[index].key,
                          style: TextStyle(
                            fontSize: 12,
                            color: _mutedColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: _primaryColor,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: _primaryColor,
                        strokeWidth: 2,
                        strokeColor: _cardColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: _primaryColor.withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final data = _bodyPartDistribution;
    if (data.isEmpty) {
      return _buildEmptyChart('暂无部位分布数据');
    }

    final colorKeys = data.keys.toList();

    final total = data.values.reduce((a, b) => a + b);

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: data.entries.toList().asMap().entries.map((mapEntry) {
                    final index = mapEntry.key;
                    final entry = mapEntry.value;
                    final percentage =
                        (entry.value / total * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      color: _chartColors[index % _chartColors.length],
                      value: entry.value.toDouble(),
                      title: '$percentage%',
                      radius: 50,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        color: _textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.entries.toList().asMap().entries.map((mapEntry) {
                final index = mapEntry.key;
                final entry = mapEntry.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _chartColors[index % _chartColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${ExerciseData.getTagDisplayName(entry.key)} (${entry.value}次)',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFatigueChart() {
    final data = _fatigueTrend;
    if (data.isEmpty) {
      return _buildEmptyChart('暂无疲劳度数据');
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: _borderColor.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 2,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _mutedColor,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[index].key,
                          style: TextStyle(
                            fontSize: 12,
                            color: _mutedColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 1,
              maxY: 10,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.value);
                  }).toList(),
                  isCurved: true,
                  color: _accentColor,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: _accentColor,
                        strokeWidth: 2,
                        strokeColor: _cardColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: _accentColor.withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: SizedBox(
        height: 180,
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: _mutedColor,
            ),
          ),
        ),
      ),
    );
  }
}
