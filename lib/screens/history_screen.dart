import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/workout_record.dart';
import '../data/exercise_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WorkoutRecord> _records = [];
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper.instance.getWorkoutRecords();
    setState(() {
      _records = records;
    });
  }

  List<WorkoutRecord> get _filteredRecords {
    if (_selectedFilter == null) return _records;
    return _records.where((r) => r.bodyPart == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练历史'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('全部'),
              ),
              ...ExerciseData.getAllTags().map((tag) {
                return PopupMenuItem(
                  value: tag,
                  child: Text(ExerciseData.getTagDisplayName(tag)),
                );
              }),
            ],
          ),
        ],
      ),
      body: _records.isEmpty
          ? const Center(
              child: Text('还没有训练记录'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) {
                final record = _filteredRecords[index];
                return Dismissible(
                  key: Key(record.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteRecord(record),
                  child: Card(
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _getTagColor(record.bodyPart).withOpacity(0.2),
                        child: Text(
                          ExerciseData.getTagDisplayName(record.bodyPart),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTagColor(record.bodyPart),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        DateFormat('yyyy-MM-dd HH:mm')
                            .format(record.dateTime),
                      ),
                      subtitle: Text(
                        '时长: ${record.durationMinutes}分钟 | 疲劳度: ${record.fatigueLevel}/10',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '训练详情:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...record.exerciseSets.map((set) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(set.exerciseName),
                                      Text(
                                        '${set.weight}kg × ${set.reps}次',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getTagColor(String tag) {
    final colors = {
      'chest': Colors.red,
      'back': Colors.blue,
      'legs': Colors.green,
      'shoulders': Colors.orange,
      'arms': Colors.purple,
      'core': Colors.teal,
    };
    return colors[tag] ?? Colors.grey;
  }

  Future<void> _deleteRecord(WorkoutRecord record) async {
    await DatabaseHelper.instance.deleteWorkoutRecord(record.id!);
    _loadRecords();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('记录已删除')),
      );
    }
  }
}
