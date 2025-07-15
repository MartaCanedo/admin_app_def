import 'package:cloud_firestore/cloud_firestore.dart';

// ⚡ Atualiza SEMPRE que mudares disciplinas/cursos/pin
const int SEED_VERSION = 4;

Future<void> runSeedingIfNeeded() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('config').doc('seeding_status');
    final doc = await docRef.get();

    final currentVersion = doc.exists ? (doc.data()?['version'] ?? 0) : 0;

    if (currentVersion >= SEED_VERSION) {
      print('✅ Seeding já está atualizado (versão $currentVersion).');
      return;
    }

    await _seedAdminPin(firestore);
    await _seedCoursesAndSubjects(firestore);

    await docRef.set({'version': SEED_VERSION});
    print('📦 Seeding atualizado para versão $SEED_VERSION');
  } catch (e) {
    print("❌ Erro ao fazer seeding: $e");
  }
}

Future<void> _seedAdminPin(FirebaseFirestore firestore) async {
  const defaultAdminPin = '123456';
  final adminDocRef = firestore.collection('settings').doc('admin');

  await adminDocRef.set({'pin': defaultAdminPin}, SetOptions(merge: true));
  print('✅ PIN de admin definido ou atualizado.');
}

Future<void> _seedCoursesAndSubjects(FirebaseFirestore firestore) async {
  // Apaga todos os cursos e suas subjects antes de semear novamente
  final coursesCollection = firestore.collection('courses');
  final existingCourses = await coursesCollection.get();
  for (var courseDoc in existingCourses.docs) {
    // Apaga todas as subjects deste curso
    final subjects = await courseDoc.reference.collection('subjects').get();
    for (var subjectDoc in subjects.docs) {
      await subjectDoc.reference.delete();
    }
    // Apaga o curso
    await courseDoc.reference.delete();
  }

  final courses = [
    {'name': 'Engenharia Informática'},
    {'name': 'Gestão'},
  ];

  for (var course in courses) {
    // Usa o nome do curso como ID (slug simples)
    final courseId = course['name']!.toLowerCase().replaceAll(' ', '_');
    final courseDoc = coursesCollection.doc(courseId);
    await courseDoc.set({'name': course['name']});

    final subjects = _getSubjectsForCourse(course['name']!, courseId);
    final subjectsCollection = courseDoc.collection('subjects');
    for (var subject in subjects) {
      await subjectsCollection.add(subject);
    }
  }
  print('✅ Cursos e disciplinas semeados.');
}

List<Map<String, dynamic>> _getSubjectsForCourse(
  String courseName,
  String courseId,
) {
  if (courseName == 'Engenharia Informática') {
    return [
      {'name': 'Programação', 'courseYear': 1, 'courseId': courseId},
      {'name': 'Matemática Discreta', 'courseYear': 1, 'courseId': courseId},
      {'name': 'Redes de Computadores', 'courseYear': 2, 'courseId': courseId},
      {'name': 'Sistemas Operativos', 'courseYear': 2, 'courseId': courseId},
      {'name': 'IA', 'courseYear': 3, 'semester': 1, 'courseId': courseId},
      {'name': 'Projeto Final', 'courseYear': 3, 'courseId': courseId},
    ];
  } else if (courseName == 'Gestão') {
    return [
      {'name': 'Contabilidade', 'courseYear': 1, 'courseId': courseId},
      {'name': 'Economia', 'courseYear': 1, 'courseId': courseId},
      {'name': 'Gestão de RH', 'courseYear': 2, 'courseId': courseId},
      {'name': 'Marketing', 'courseYear': 2, 'courseId': courseId},
      {'name': 'Finanças Empresariais', 'courseYear': 3, 'courseId': courseId},
      {'name': 'Projeto de Gestão', 'courseYear': 3, 'courseId': courseId},
    ];
  }
  return [];
}
