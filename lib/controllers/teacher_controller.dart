// lib/services/professor_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher_model.dart';

class ProfessorService {
  Future<bool> emailJaExiste(String email) async {
    final snapshot =
        await professorsCollection.where('email', isEqualTo: email).get();
    return snapshot.docs.isNotEmpty;
  }

  final CollectionReference professorsCollection = FirebaseFirestore.instance
      .collection('professores');

  Future<void> createProfessor(Professor professor) async {
    await professorsCollection.doc(professor.id).set(professor.toMap());
  }

  Future<bool> disciplinaJaAtribuida(String disciplinaId) async {
    final snapshot =
        await professorsCollection
            .where('disciplinas', arrayContains: disciplinaId)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<Map<String, int>> countProfessoresByCurso() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final Map<String, Set<String>> cursoDisciplinas = {};

    final coursesSnapshot = await firestore.collection('courses').get();
    for (final courseDoc in coursesSnapshot.docs) {
      final courseId = courseDoc.id;
      final subjectsSnapshot =
          await firestore
              .collection('courses')
              .doc(courseId)
              .collection('subjects')
              .get();

      cursoDisciplinas[courseId] =
          subjectsSnapshot.docs
              .map(
                (e) =>
                    (e.data() as Map<String, dynamic>)['name']?.toString() ??
                    '',
              )
              .where((name) => name.isNotEmpty)
              .toSet();
    }

    final professoresSnapshot = await firestore.collection('professores').get();
    final Map<String, int> professoresPorCurso = {
      for (var curso in cursoDisciplinas.keys) curso: 0,
    };

    for (var profDoc in professoresSnapshot.docs) {
      final data = profDoc.data() as Map<String, dynamic>;
      final rawDisciplinas = data['disciplinas'];

      final List<String> disciplinas = [];
      if (rawDisciplinas is String) {
        disciplinas.add(rawDisciplinas);
      } else if (rawDisciplinas is List) {
        disciplinas.addAll(rawDisciplinas.map((e) => e.toString()));
      }

      for (var entry in cursoDisciplinas.entries) {
        final intersecao = entry.value.intersection(disciplinas.toSet());
        if (intersecao.isNotEmpty) {
          professoresPorCurso[entry.key] = professoresPorCurso[entry.key]! + 1;
          break;
        }
      }
    }

    print('Professores por Curso: $professoresPorCurso');
    return professoresPorCurso;
  }

  Stream<List<Professor>> getProfessores() {
    return professorsCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => Professor.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}
