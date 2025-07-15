class Aula {
  final String disciplina;
  final String diaSemana;
  final String horaInicio;
  final String horaFim;

  Aula({
    required this.disciplina,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFim,
  });

  Map<String, dynamic> toMap() {
    return {
      'disciplina': disciplina,
      'diaSemana': diaSemana,
      'horaInicio': horaInicio,
      'horaFim': horaFim,
    };
  }

  factory Aula.fromMap(Map<String, dynamic> map) {
    return Aula(
      disciplina: map['disciplina'],
      diaSemana: map['diaSemana'],
      horaInicio: map['horaInicio'],
      horaFim: map['horaFim'],
    );
  }
}

class Horario {
  String id;
  String courseId;
  Map<String, List<Map<String, dynamic>>> aulasPorAno;

  Horario({
    required this.id,
    required this.courseId,
    required this.aulasPorAno,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'aulasPorAno': aulasPorAno,
    };
  }

  factory Horario.fromMap(String id, Map<String, dynamic> map) {
    return Horario(
      id: id,
      courseId: map['courseId'],
      aulasPorAno: Map<String, List<Map<String, dynamic>>>.from(
        (map['aulasPorAno'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            List<Map<String, dynamic>>.from(value),
          ),
        ),
      ),
    );
  }
}