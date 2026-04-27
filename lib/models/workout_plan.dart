class WorkoutPlan {
  int? id;
  String name;
  DateTime startDate;
  DateTime endDate;
  int daysPerWeek;
  String workoutDays;

  WorkoutPlan({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.daysPerWeek,
    required this.workoutDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'daysPerWeek': daysPerWeek,
      'workoutDays': workoutDays,
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      daysPerWeek: map['daysPerWeek'],
      workoutDays: map['workoutDays'],
    );
  }
}
