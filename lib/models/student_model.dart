class Student {
  final String id;
  final String userId;
  final String nome;
  final String courseId;
  final int year;
  final String nacionalidade;
  final String distrito;
  final String morada;
  final String codigoPostal;
  final String dataNascimento;
  final String profissao;
  final String nif;
  final String iban;
  final String password;

  Student({
    required this.id,
    required this.userId,
    required this.nome,
    required this.courseId,
    required this.year,
    required this.nacionalidade,
    required this.distrito,
    required this.morada,
    required this.codigoPostal,
    required this.dataNascimento,
    required this.profissao,
    required this.nif,
    required this.iban,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nome': nome,
      'courseId': courseId,
      'year': year,
      'nacionalidade': nacionalidade,
      'distrito': distrito,
      'morada': morada,
      'codigoPostal': codigoPostal,
      'dataNascimento': dataNascimento,
      'profissao': profissao,
      'nif': nif,
      'iban': iban,
      'password': password,
    };
  }

  factory Student.fromMap(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      userId: data['userId'] ?? '',
      nome: data['nome'] ?? '',
      courseId: data['courseId'] ?? '',
      year: data['year'] ?? 1,
      nacionalidade: data['nacionalidade'] ?? '',
      distrito: data['distrito'] ?? '',
      morada: data['morada'] ?? '',
      codigoPostal: data['codigoPostal'] ?? '',
      dataNascimento: data['dataNascimento'] ?? '',
      profissao: data['profissao'] ?? '',
      nif: data['nif'] ?? '',
      iban: data['iban'] ?? '',
      password: data['password'] ?? '',
    );
  }
}
