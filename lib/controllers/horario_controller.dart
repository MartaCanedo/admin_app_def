import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/horario_model.dart';

class HorarioController {
  final _db = FirebaseFirestore.instance;

  Future<void> criarOuAtualizarHorario(Horario horario) async {
    final docRef = _db
        .collection('horarios')
        .doc(horario.courseId); // courseId como ID
    await docRef.set(horario.toMap());
  }

  Future<Horario?> buscarHorarioPorCurso(String courseId) async {
    final doc = await _db.collection('horarios').doc(courseId).get();
    if (doc.exists) {
      return Horario.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<void> eliminarHorario(String courseId) async {
    await _db.collection('horarios').doc(courseId).delete();
  }

  // Novo método para remover uma aula específica
  Future<void> removerAula(
    String courseId,
    int ano,
    String diaSemana,
    String horaInicio,
  ) async {
    final horario = await buscarHorarioPorCurso(courseId);
    if (horario != null) {
      final anoKey = ano.toString();
      if (horario.aulasPorAno.containsKey(anoKey)) {
        horario.aulasPorAno[anoKey]!.removeWhere(
          (aula) =>
              aula['diaSemana'] == diaSemana &&
              aula['horaInicio'] == horaInicio,
        );
        await criarOuAtualizarHorario(horario);
      }
    }
  }

  // Novo método para adicionar uma aula a um horário existente
  Future<void> adicionarAula(
    String courseId,
    int ano,
    Map<String, dynamic> novaAula,
  ) async {
    final horario = await buscarHorarioPorCurso(courseId);
    if (horario != null) {
      final anoKey = ano.toString();
      if (horario.aulasPorAno.containsKey(anoKey)) {
        // Verificar se já existe uma aula no mesmo dia e horário
        final exists = horario.aulasPorAno[anoKey]!.any(
          (aula) =>
              aula['diaSemana'] == novaAula['diaSemana'] &&
              aula['horaInicio'] == novaAula['horaInicio'],
        );

        if (!exists) {
          horario.aulasPorAno[anoKey]!.add(novaAula);
          await criarOuAtualizarHorario(horario);
        }
      }
    }
  }
}
