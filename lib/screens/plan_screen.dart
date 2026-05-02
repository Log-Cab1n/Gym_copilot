import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/workout_plan.dart';
import '../models/workout_record.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  List<WorkoutPlan> _plans = [];
  WorkoutPlan? _activePlan;
  List<WorkoutRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final plans = await DatabaseHelper.instance.getWorkoutPlans();
    final active = await DatabaseHelper.instance.getActiveWorkoutPlan();
    final records = await DatabaseHelper.instance.getWorkoutRecords();
    setState(() {
      _plans = plans;
      _activePlan = active;
      _records = records;
      _isLoading = false;
    });
  }

  double get _planProgress {
    if (_activePlan == null) return 0;
    final totalDays =
        _activePlan!.endDate.difference(_activePlan!.startDate).inDays;
    final passedDays = DateTime.now().difference(_activePlan!.startDate).inDays;
    if (totalDays <= 0) return 1;
    return (passedDays / totalDays).clamp(0, 1);
  }

  List<bool> get _weekCompletion {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      final dayStr = DateFormat('yyyy-MM-dd').format(day);
      return _records
          .any((r) => DateFormat('yyyy-MM-dd').format(r.dateTime) == dayStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练周期'),
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
                    if (_activePlan != null) ...[
                      _buildProgressCard(theme),
                      const SizedBox(height: 32),
                      _buildWeekCalendar(theme),
                      const SizedBox(height: 32),
                    ],
                    _buildPlansList(theme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProgressCard(ThemeData theme) {
    final percentage = (_planProgress * 100).toStringAsFixed(0);

    return FadeInUp(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activePlan!.name,
                        style: TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('yyyy.MM.dd').format(_activePlan!.startDate)} - ${DateFormat('yyyy.MM.dd').format(_activePlan!.endDate)}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '进行中',
                      style: TextStyle(
                          fontSize: 11, color: theme.colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: _planProgress,
                        strokeWidth: 8,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$percentage%',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w300),
                        ),
                        Text(
                          '已完成',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem('每周训练', '${_activePlan!.daysPerWeek}天', theme),
                  Container(
                    width: 1,
                    height: 30,
                    color: theme.colorScheme.outline,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _buildStatItem(
                    '剩余天数',
                    '${_activePlan!.endDate.difference(DateTime.now()).inDays}天',
                    theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildWeekCalendar(ThemeData theme) {
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final completion = _weekCompletion;

    return FadeInUp(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '本周训练计划',
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final isCompleted = completion[index];
                  return Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(Icons.check,
                                  color: theme.colorScheme.onPrimary, size: 18)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weekDays[index],
                        style: TextStyle(
                            fontSize: 11,
                            color: isCompleted
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlansList(ThemeData theme) {
    if (_plans.isEmpty) {
      return Center(
        child: FadeInUp(
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                '还没有健身周期',
                style: TextStyle(
                    fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '所有周期',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ..._plans.map((plan) {
          final isActive = _activePlan?.id == plan.id;
          return FadeInUp(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '进行中',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateFormat('yyyy.MM.dd').format(plan.startDate)} - ${DateFormat('yyyy.MM.dd').format(plan.endDate)}',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '每周${plan.daysPerWeek}练 · ${plan.workoutDays}',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: _calculateProgress(plan),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(_calculateProgress(plan) * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _deletePlan(plan),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '删除',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  double _calculateProgress(WorkoutPlan plan) {
    final totalDays = plan.endDate.difference(plan.startDate).inDays;
    final passedDays = DateTime.now().difference(plan.startDate).inDays;
    if (totalDays <= 0) return 1;
    return (passedDays / totalDays).clamp(0, 1);
  }

  Future<void> _deletePlan(WorkoutPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除周期 "${plan.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteWorkoutPlan(plan.id!);
      _loadData();
    }
  }

  Future<void> _showAddPlanDialog() async {
    final nameController = TextEditingController();
    final daysController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    final List<String> selectedDays = [];
    final List<String> weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    final result = await showDialog<WorkoutPlan?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新建健身周期'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '周期名称',
                    hintText: '例如：减脂期、增肌期',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '每周训练天数',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('开始日期'),
                  subtitle: Text(startDate != null
                      ? DateFormat('yyyy-MM-dd').format(startDate!)
                      : '请选择'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('结束日期'),
                  subtitle: Text(endDate != null
                      ? DateFormat('yyyy-MM-dd').format(endDate!)
                      : '请选择'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        endDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('训练日安排:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: weekDays.map((day) {
                    final isSelected = selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          if (isSelected) {
                            selectedDays.remove(day);
                          } else {
                            selectedDays.add(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    daysController.text.isEmpty ||
                    startDate == null ||
                    endDate == null ||
                    selectedDays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写完整信息')),
                  );
                  return;
                }

                final days = int.tryParse(daysController.text);
                if (days == null || days <= 0 || days > 7) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入有效的训练天数(1-7)')),
                  );
                  return;
                }

                final plan = WorkoutPlan(
                  name: nameController.text,
                  startDate: startDate!,
                  endDate: endDate!,
                  daysPerWeek: days,
                  workoutDays: selectedDays.join(', '),
                );
                Navigator.pop(context, plan);
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await DatabaseHelper.instance.insertWorkoutPlan(result);
      _loadData();
    }
  }
}
