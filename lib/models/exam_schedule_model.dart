class ExamSchedule {
  final String id;
  final String courseId;
  final String subjectId;
  final int courseYear;
  final Map<String, DateTime> exams;

  ExamSchedule({
    required this.id,
    required this.courseId,
    required this.subjectId,
    required this.courseYear,
    required this.exams,
  });

  Map<String, dynamic> toMap() => {
    'courseId': courseId,
    'subjectId': subjectId,
    'courseYear': courseYear,
    'exams': exams.map((k, v) => MapEntry(k, v.toIso8601String())),
  };

  static ExamSchedule fromMap(String id, Map<String, dynamic> map) {
    return ExamSchedule(
      id: id,
      courseId: map['courseId'],
      subjectId: map['subjectId'],
      courseYear: map['courseYear'],
      exams: Map<String, DateTime>.from(
        (map['exams'] as Map).map(
          (k, v) => MapEntry(k, DateTime.parse(v)),
        ),
      ),
    );
  }
}
