import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/all_subject_model.dart';

class AllSubjectController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria nova disciplina na coleção `all_subjects`
  Future<void> createSubject(String name) async {
    await _firestore.collection('all_subjects').add({'name': name});
  }

  /// Lista todas as disciplinas da coleção `all_subjects`
  Future<List<AllSubjectModel>> getAllSubjects() async {
    final snapshot = await _firestore.collection('all_subjects').get();
    return snapshot.docs
        .map((doc) => AllSubjectModel.fromDocument(doc))
        .toList();
  }

  /// Verifica se a disciplina está a ser usada em algum curso
  Future<bool> isSubjectInUse(String subjectName) async {
    final coursesSnapshot = await _firestore.collection('courses').get();

    for (final courseDoc in coursesSnapshot.docs) {
      final subjectsSnapshot = await _firestore
          .collection('courses')
          .doc(courseDoc.id)
          .collection('subjects')
          .where('name', isEqualTo: subjectName)
          .limit(1)
          .get();

      if (subjectsSnapshot.docs.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  Future<bool> updateSubject(String id,String oldName ,String newName) async {
    final inUse = await isSubjectInUse(oldName);

    if (inUse) {
      return false;
    }
    if (newName.isEmpty) {
      return false; // Nome inválido
    }

    await FirebaseFirestore.instance
        .collection('all_subjects')
        .doc(id)
        .update({'name': newName});
    return true;
  }


  /// Apaga a disciplina **apenas se não estiver a ser usada**
  Future<bool> deleteSubjectIfUnused(AllSubjectModel subject) async {
    final inUse = await isSubjectInUse(subject.name);

    if (inUse) {
      return false; // Não pode apagar
    }

    await _firestore.collection('all_subjects').doc(subject.id).delete();
    return true; // Sucesso
  }
}
