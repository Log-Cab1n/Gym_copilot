import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/workout_record.dart';
import '../data/exercise_data.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('近7天训练时长', theme),
                    _buildWeeklyChart(theme),
                    const SizedBox(height: 32),
                    _buildSectionTitle('部位分布', theme),
                    _buildPieChart(theme),
                    const SizedBox(height: 32),
                    _buildSectionTitle('疲劳度趋势', theme),
                    _buildFatigueChart(theme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(ThemeData theme) {
    final data = _weeklyDurationData;
    if (data.every((e) => e.value == 0)) {
      return _buildEmptyChart('近7天暂无训练数据', theme);
    }

    final maxValue =
        data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    // 确保最小刻度范围，避免纵坐标显示重复数字
    final maxY = (maxValue < 5 ? 5.0 : maxValue * 1.2).toDouble();
    // 计算合适的刻度间隔，确保为整数
    final interval = maxY / 4;

    return Card(
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
                  color: theme.colorScheme.outline.withOpacity(0.3),
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
                      // 只显示整数刻度，避免重复
                      if (value != value.toInt().toDouble()) {
                        return const SizedBox();
                      }
                      return Text(
                        '${value.toInt()}',
                        style: theme.textTheme.labelSmall,
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
                          style: theme.textTheme.labelSmall,
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
                  color: theme.colorScheme.primary,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: theme.colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme) {
    final data = _bodyPartDistribution;
    if (data.isEmpty) {
      return _buildEmptyChart('暂无部位分布数据', theme);
    }

    final colors = {
      'chest': const Color(0xFFFF8A65),
      'back': const Color(0xFF4FC3F7),
      'legs': const Color(0xFF81C784),
      'shoulders': const Color(0xFFFFB74D),
      'arms': const Color(0xFF9575CD),
      'core': const Color(0xFF4DB6AC),
    };

    final total = data.values.reduce((a, b) => a + b);

    return Card(
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
                  sections: data.entries.map((entry) {
                    final percentage =
                        (entry.value / total * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      color: colors[entry.key] ?? theme.colorScheme.outline,
                      value: entry.value.toDouble(),
                      title: '$percentage%',
                      radius: 50,
                      titleStyle: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
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
              children: data.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[entry.key] ?? theme.colorScheme.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${ExerciseData.getTagDisplayName(entry.key)} (${entry.value}次)',
                      style: theme.textTheme.bodySmall,
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

  Widget _buildFatigueChart(ThemeData theme) {
    final data = _fatigueTrend;
    if (data.isEmpty) {
      return _buildEmptyChart('暂无疲劳度数据', theme);
    }

    return Card(
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
                  color: theme.colorScheme.outline.withOpacity(0.3),
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
                      style: theme.textTheme.labelSmall,
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
                          style: theme.textTheme.labelSmall,
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
                  color: theme.colorScheme.secondary,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: theme.colorScheme.secondary,
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.secondary.withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message, ThemeData theme) {
    return Card(
      child: SizedBox(
        height: 180,
        child: Center(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
