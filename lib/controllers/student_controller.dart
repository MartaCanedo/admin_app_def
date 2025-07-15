import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentController {
  Future<bool> emailExists(String email) async {
    final snapshot =
        await _firestore
            .collection('students')
            .where('userId', isEqualTo: email)
            .get();
    return snapshot.docs.isNotEmpty;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addStudent(Student student) async {
    await _firestore
        .collection('students')
        .doc(student.id)
        .set(student.toMap());
  }

  Future<void> updateStudent(Student student) async {
    await _firestore
        .collection('students')
        .doc(student.id)
        .update(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _firestore.collection('students').doc(id).delete();
  }

  Future<Map<int, int>> countAllStudentsByYear() async {
    final snapshot = await _firestore.collection('students').get();
    final counts = <int, int>{};

    for (final doc in snapshot.docs) {
      final year = doc['year'] as int? ?? 0;
      counts[year] = (counts[year] ?? 0) + 1;
    }

    return counts;
  }

  Future<Map<String, int>> countStudentsByCourse() async {
    final snapshot = await _firestore.collection('students').get();
    final Map<String, int> counts = {};

    for (final doc in snapshot.docs) {
      final courseId = doc['courseId'] ?? '';
      if (courseId.isEmpty) continue;

      counts[courseId] = (counts[courseId] ?? 0) + 1;
    }

    return counts;
  }

  Stream<List<Student>> getStudents() {
    return _firestore.collection('students').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Student.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
