import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam_schedule_model.dart';

class ExamScheduleController {
  static final _collection = FirebaseFirestore.instance.collection('exam_schedules');

  static Future<void> saveSchedule(ExamSchedule schedule) async {
    await _collection.doc(schedule.id).set(schedule.toMap());
  }

  static Future<ExamSchedule?> getScheduleBySubject(String subjectId) async {
    final snapshot = await _collection
        .where('subjectId', isEqualTo: subjectId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return ExamSchedule.fromMap(doc.id, doc.data());
  }

  static Stream<List<ExamSchedule>> getSchedulesByCourse(String courseId) {
    return _collection
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExamSchedule.fromMap(doc.id, doc.data()))
            .toList());
  }

  static Future<void> deleteSchedule(String id) async {
    await _collection.doc(id).delete();
  }
}
