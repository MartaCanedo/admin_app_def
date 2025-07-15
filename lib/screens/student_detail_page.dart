import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../controllers/student_controller.dart';

class StudentDetailPage extends StatefulWidget {
  final String studentId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentDetailPage({
    super.key,
    required this.studentId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  final StudentController _service = StudentController();

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(value, style: TextStyle(color: Colors.white70)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        title: Text('Aluno'),
        // Nenhum botão de editar ou eliminar
      ),
      body: StreamBuilder<List<Student>>(
        stream: _service.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar aluno'));
          }
          final students = snapshot.data ?? [];
          final student = students.firstWhere(
            (s) => s.id == widget.studentId,
            orElse:
                () => Student(
                  id: '',
                  userId: '',
                  nome: '',
                  courseId: '',
                  year: 0,
                  nacionalidade: '',
                  distrito: '',
                  morada: '',
                  codigoPostal: '',
                  dataNascimento: '',
                  profissao: '',
                  nif: '',
                  iban: '',
                  password: '',
                ),
          );
          if (student.id.isEmpty) {
            return Center(child: Text('Aluno não encontrado.'));
          }
          return ListView(
            children: [
              _buildInfoTile('Nome', student.nome),
              _buildInfoTile('Email', student.userId),
              _buildInfoTile('Curso', student.courseId),
              _buildInfoTile('Ano', student.year.toString()),
              _buildInfoTile('Nacionalidade', student.nacionalidade),
              _buildInfoTile('Distrito', student.distrito),
              _buildInfoTile('Morada', student.morada),
              _buildInfoTile('Código Postal', student.codigoPostal),
              _buildInfoTile('Data de Nascimento', student.dataNascimento),
              _buildInfoTile('Profissão', student.profissao),
              _buildInfoTile('NIF', student.nif),
              _buildInfoTile('IBAN', student.iban),
            ],
          );
        },
      ),
    );
  }
}
