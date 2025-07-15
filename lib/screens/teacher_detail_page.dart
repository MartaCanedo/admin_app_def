import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../controllers/teacher_controller.dart';

class TeacherDetailPage extends StatefulWidget {
  final String teacherId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TeacherDetailPage({
    super.key,
    required this.teacherId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TeacherDetailPage> createState() => _TeacherDetailPageState();
}

class _TeacherDetailPageState extends State<TeacherDetailPage> {
  final _service = ProfessorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Professor', style: TextStyle(color: Colors.white)),
        // Nenhum botão de editar ou remover
      ),
      body: StreamBuilder<List<Professor>>(
        stream: _service.getProfessores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar professor'));
          }
          final teachers = snapshot.data ?? [];
          final teacher = teachers.firstWhere(
            (t) => t.id == widget.teacherId,
            orElse:
                () => Professor(
                  id: '',
                  nome: '',
                  email: '',
                  disciplinas: [],
                  nacionalidade: '',
                  distrito: '',
                  morada: '',
                  codigoPostal: '',
                  dataNascimento: '',
                  nif: '',
                  iban: '',
                  password: '',
                ),
          );
          if (teacher.id.isEmpty) {
            return Center(child: Text('Professor não encontrado.'));
          }
          return ListView(
            children: [
              ListTile(
                title: Text(
                  'Nome',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.nome,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.email,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'Disciplinas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.disciplinas.join(', '),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'Nacionalidade',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.nacionalidade,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'Distrito',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.distrito,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'Morada',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.morada,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'Código Postal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.codigoPostal,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'Data de Nascimento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.dataNascimento,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'NIF',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.nif,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  'IBAN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  teacher.iban,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
