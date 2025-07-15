import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CourseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCourse(Course course) async {
    await _firestore.collection('courses').doc(course.id).set(course.toMap());
  }

  Future<void> createCourse(
    String id,
    String name,
    Map<int, Set<String>> subjectsByYear,
  ) async {
    await _firestore.collection('courses').doc(id).set({'name': name});
    for (final entry in subjectsByYear.entries) {
      final year = entry.key;
      for (final subjectName in entry.value) {
        await _firestore
            .collection('courses')
            .doc(id)
            .collection('subjects')
            .add({'name': subjectName, 'courseId': id, 'courseYear': year});
      }
    }
  }

  Future<void> deleteCourse(String id) async {
    final subjects =
        await _firestore
            .collection('courses')
            .doc(id)
            .collection('subjects')
            .get();
    for (var doc in subjects.docs) {
      await doc.reference.delete();
    }
    await _firestore.collection('courses').doc(id).delete();
  }

  Future<void> updateCourse(
    String id,
    String name,
    Map<int, Set<String>> subjectsByYear,
  ) async {
    // Atualiza o nome do curso
    await _firestore.collection('courses').doc(id).update({'name': name});

    // Remove todas as disciplinas existentes
    final existingSubjects =
        await _firestore
            .collection('courses')
            .doc(id)
            .collection('subjects')
            .get();
    for (var doc in existingSubjects.docs) {
      await doc.reference.delete();
    }

    // Adiciona as novas disciplinas
    for (final entry in subjectsByYear.entries) {
      final year = entry.key;
      for (final subjectName in entry.value) {
        await _firestore
            .collection('courses')
            .doc(id)
            .collection('subjects')
            .add({'name': subjectName, 'courseId': id, 'courseYear': year});
      }
    }
  }

  Future<Map<int, Set<String>>> getCourseSubjects(String courseId) async {
    final snapshot =
        await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('subjects')
            .get();

    final Map<int, Set<String>> subjectsByYear = {1: {}, 2: {}, 3: {}};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final year = data['courseYear'] as int;
      final subjectName = data['name'] as String;
      subjectsByYear[year]?.add(subjectName);
    }

    return subjectsByYear;
  }

  Future<List<Course>> getCourses() async {
    final snapshot = await _firestore.collection('courses').get();
    return snapshot.docs
        .map((doc) => Course.fromMap(doc.data(), doc.id))
        .toList();
  }
}
