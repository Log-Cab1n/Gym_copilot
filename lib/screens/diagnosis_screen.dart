import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String _dbPath = '';
  int _dbVersion = 0;
  List<String> _tables = [];
  List<Map<String, dynamic>> _workoutRecords = [];
  List<Map<String, dynamic>> _exerciseSets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = await DatabaseHelper.instance.database;
      final path = await DatabaseHelper.instance.getDatabasePath();
      final version = await db.getVersion();

      final tablesResult = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );

      final records = await db.query('workout_records');
      final sets = await db.query('exercise_sets');

      setState(() {
        _dbPath = path;
        _dbVersion = version;
        _tables = tablesResult.map((r) => r['name'] as String).toList();
        _workoutRecords = records;
        _exerciseSets = sets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _insertTestData() async {
    try {
      await DatabaseHelper.instance.insertTestData();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('测试数据插入成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('插入失败: $e')),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无数据'),
        ),
      );
    }

    final columns = data.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        columns: columns
            .map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600))))
            .toList(),
        rows: data.map((row) {
          return DataRow(
            cells: columns.map((c) {
              final value = row[c];
              return DataCell(
                Text(
                  value?.toString() ?? 'NULL',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据库诊断'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '错误: $_error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSectionTitle('数据库信息'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('文件路径:', _dbPath),
                              _buildInfoRow('数据库版本:', '$_dbVersion'),
                              _buildInfoRow('表数量:', '${_tables.length}'),
                            ],
                          ),
                        ),
                      ),
                      _buildSectionTitle('所有表'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _tables.isEmpty
                              ? const Text('暂无表')
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _tables
                                      .map((t) => Chip(label: Text(t)))
                                      .toList(),
                                ),
                        ),
                      ),
                      _buildSectionTitle('workout_records (${_workoutRecords.length} 条)'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _buildDataTable(_workoutRecords),
                        ),
                      ),
                      _buildSectionTitle('exercise_sets (${_exerciseSets.length} 条)'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _buildDataTable(_exerciseSets),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _insertTestData,
                          icon: const Icon(Icons.add),
                          label: const Text('插入测试数据'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
