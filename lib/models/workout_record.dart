import 'exercise.dart';

class WorkoutRecord {
  int? id;
  DateTime dateTime;
  String bodyPart;
  int durationMinutes;
  int fatigueLevel;
  List<ExerciseSet> exerciseSets;

  WorkoutRecord({
    this.id,
    required this.dateTime,
    required this.bodyPart,
    required this.durationMinutes,
    required this.fatigueLevel,
    this.exerciseSets = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'bodyPart': bodyPart,
      'durationMinutes': durationMinutes,
      'fatigueLevel': fatigueLevel,
    };
  }

  factory WorkoutRecord.fromMap(Map<String, dynamic> map) {
    return WorkoutRecord(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      bodyPart: map['bodyPart'],
      durationMinutes: map['durationMinutes'],
      fatigueLevel: map['fatigueLevel'],
    );
  }
}
