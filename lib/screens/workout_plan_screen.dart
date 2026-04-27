import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/workout_plan.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  List<WorkoutPlan> _plans = [];
  WorkoutPlan? _activePlan;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final plans = await DatabaseHelper.instance.getWorkoutPlans();
    final active = await DatabaseHelper.instance.getActiveWorkoutPlan();
    setState(() {
      _plans = plans;
      _activePlan = active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健身周期'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _plans.isEmpty
          ? const Center(
              child: Text('还没有创建健身周期，点击右下角添加'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                final isActive = _activePlan?.id == plan.id;

                return Card(
                  elevation: isActive ? 4 : 1,
                  color: isActive
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                            ),
                            if (isActive)
                              Chip(
                                label: const Text('进行中'),
                                backgroundColor: Colors.green[100],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('每周 ${plan.daysPerWeek} 练'),
                        Text('训练日: ${plan.workoutDays}'),
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('yyyy-MM-dd').format(plan.startDate)} - ${DateFormat('yyyy-MM-dd').format(plan.endDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _calculateProgress(plan),
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _deletePlan(plan),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanDialog,
        child: const Icon(Icons.add),
      ),
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
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteWorkoutPlan(plan.id!);
      _loadPlans();
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
            FilledButton(
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

                final plan = WorkoutPlan(
                  name: nameController.text,
                  startDate: startDate!,
                  endDate: endDate!,
                  daysPerWeek: int.parse(daysController.text),
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
      _loadPlans();
    }
  }
}
