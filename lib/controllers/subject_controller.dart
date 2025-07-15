import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectController {
  static Future<List<String>> getAllSubjects() async {
    final firestore = FirebaseFirestore.instance;
    final subjects = <String>[];

    final coursesSnapshot = await firestore.collection('courses').get();

    for (var courseDoc in coursesSnapshot.docs) {
      final subjectsSnapshot =
          await firestore
              .collection('courses')
              .doc(courseDoc.id)
              .collection('subjects')
              .get();

      for (var subjectDoc in subjectsSnapshot.docs) {
        final name = subjectDoc['name'];
        if (name != null && !subjects.contains(name)) {
          subjects.add(name);
        }
      }
    }

    print('✅ Disciplinas carregadas: $subjects');
    return subjects;
  }

  static Future<Map<int, List<Map<String, dynamic>>>> getSubjectsByCourse(String courseId) async {
  final firestore = FirebaseFirestore.instance;
  final result = <int, List<Map<String, dynamic>>>{};

  final snapshot = await firestore
      .collection('courses')
      .doc(courseId)
      .collection('subjects')
      .get();

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final year = data['courseYear'] ?? 1;

    result[year] ??= [];
    result[year]!.add({
      ...data,
      'id': doc.id, // <- aqui está a correção
    });
  }

  return result;
}

}
