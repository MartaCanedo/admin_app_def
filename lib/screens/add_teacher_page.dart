import 'dart:math';
import 'package:admin_app/widgets/add_teacher_dialog.dart';
import 'package:admin_app/widgets/edit_teacher_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/teacher_model.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/subject_controller.dart'; // IMPORTANTE!
import '../services/send_email_service.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
  final _service = ProfessorService();
  List<Professor> teachers = [];
  late final Stream<List<Professor>> _teachersStream;

  // Removed duplicate build method to resolve the error.

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nacionalidadeController = TextEditingController();
  final TextEditingController distritoController = TextEditingController();
  final TextEditingController moradaController = TextEditingController();
  final TextEditingController codigoPostalController = TextEditingController();
  final TextEditingController dataNascimentoController =
      TextEditingController();
  final TextEditingController nifController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();

  List<String> selectedSubjects = [];
  List<String> allSubjects = [];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadSubjects();
    _teachersStream = _service.getProfessores();
  }

  // Fix: define loadSubjects as an alias for carregarDisciplinas
  void loadSubjects() => carregarDisciplinas();

  Future<void> carregarDisciplinas() async {
    final list = await SubjectController.getAllSubjects();
    setState(() {
      allSubjects = list;
    });
  }

  String generateRandomPassword({int length = 8}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%&*';
    final rnd = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }

  void _openAddTeacherDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddTeacherDialog(
            allSubjects: allSubjects,
            teacherController: _service,
            onTeacherAdded: (professor) {
              setState(() {
                teachers.add(professor);
              });
            },
          ),
    );
  }

  void _abrirSelecaoDisciplinas() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey.shade800,
      isScrollControlled: true,
      builder: (context) {
        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 350, maxHeight: 400),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Selecione as disciplinas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Divider(color: Colors.white24, height: 1),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children:
                            allSubjects.map((subject) {
                              final alreadySelected = selectedSubjects.contains(
                                subject,
                              );
                              return ListTile(
                                title: Text(
                                  subject,
                                  style: TextStyle(
                                    color:
                                        alreadySelected
                                            ? Colors.red
                                            : Colors.white,
                                    fontWeight:
                                        alreadySelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                trailing:
                                    alreadySelected
                                        ? Icon(Icons.check, color: Colors.red)
                                        : null,
                                onTap: () {
                                  setModalState(() {
                                    if (alreadySelected) {
                                      selectedSubjects.clear();
                                    } else {
                                      selectedSubjects
                                        ..clear()
                                        ..add(subject);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // English alias for subject selection
  void _openSubjectSelection() => _abrirSelecaoDisciplinas();

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<bool> _emailExists(String email) async {
    // Verifica se já existe um professor com este email no Firestore
    final query =
        await _service.professorsCollection
            .where('email', isEqualTo: email)
            .get();
    return query.docs.isNotEmpty;
  }

  void _submitTeacher() async {
    final name = nomeController.text.trim();
    final email = emailController.text.trim();
    final nationality = nacionalidadeController.text.trim();
    final district = distritoController.text.trim();
    final address = moradaController.text.trim();
    final postalCode = codigoPostalController.text.trim();
    final birthDate = dataNascimentoController.text.trim();
    final nif = nifController.text.trim();
    final iban = ibanController.text.trim();
    final String disciplinaSelecionadaId = selectedSubjects.first;

    if ([
          name,
          email,
          nationality,
          district,
          address,
          postalCode,
          birthDate,
          nif,
          iban,
        ].any((field) => field.isEmpty) ||
        selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor preencha todos os campos e selecione pelo menos uma disciplina!',
          ),
        ),
      );
      return;
    }

    // Verifica se o email já existe
    bool emailJaExiste = await _emailExists(email);
    if (emailJaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Já existe um professor com este email.')),
      );
      return;
    }

    final password = generateRandomPassword();
    final id = Uuid().v4();

    // Agora salva todas as disciplinas selecionadas
    final professor = Professor(
      id: id,
      nome: name,
      email: email,
      disciplinas: List<String>.from(selectedSubjects),
      nacionalidade: nationality,
      distrito: district,
      morada: address,
      codigoPostal: postalCode,
      dataNascimento: birthDate,
      nif: nif,
      iban: iban,
      password: password,
    );

    try {
      bool jaAtribuida = await _service.disciplinaJaAtribuida(
        disciplinaSelecionadaId,
      );

      if (jaAtribuida) {
        print("Disciplina já atribuída a outro professor.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disciplina já atribuída a outro professor.')),
        );
        // Mostrar alerta ao utilizador
      } else {
        await _service.createProfessor(professor);
        await SendEmailService.sendProfessorEmail(
          nome: name,
          email: email,
          password: password,
        );

        setState(() {
          teachers.add(professor);
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Professor "$name" adicionado!\nSenha: $password'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao adicionar professor.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Professores', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            onPressed: _openAddTeacherDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, email ou disciplina',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.grey.shade700,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Professor>>(
              stream: _teachersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar professores',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                final teachers = snapshot.data ?? [];
                final filteredTeachers =
                    _searchQuery.isEmpty
                        ? teachers
                        : teachers.where((t) {
                          final name = t.nome.toLowerCase();
                          final email = t.email.toLowerCase();
                          final subjects =
                              t.disciplinas.join(', ').toLowerCase();
                          return name.contains(_searchQuery) ||
                              email.contains(_searchQuery) ||
                              subjects.contains(_searchQuery);
                        }).toList();
                if (filteredTeachers.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum professor cadastrado.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredTeachers.length,
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];
                    return ListTile(
                      title: Text(
                        teacher.nome,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        teacher.disciplinas.join(', '),
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () async {
                              nomeController.text = teacher.nome;
                              emailController.text = teacher.email;
                              nacionalidadeController.text =
                                  teacher.nacionalidade;
                              distritoController.text = teacher.distrito;
                              moradaController.text = teacher.morada;
                              codigoPostalController.text =
                                  teacher.codigoPostal;
                              dataNascimentoController.text =
                                  teacher.dataNascimento;
                              nifController.text = teacher.nif;
                              ibanController.text = teacher.iban;
                              setState(() {
                                selectedSubjects = List<String>.from(
                                  teacher.disciplinas,
                                );
                              });
                              await showDialog(
                                context: context,
                                builder:
                                    (context) => EditTeacherDialog(
                                      teacher: teacher,
                                      allSubjects: allSubjects,
                                      onTeacherUpdated: (updated) async {
                                        await _service.professorsCollection
                                            .doc(updated.id)
                                            .set(updated.toMap());
                                        setState(() {
                                          final idx = teachers.indexWhere(
                                            (t) => t.id == updated.id,
                                          );
                                          if (idx != -1)
                                            teachers[idx] = updated;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Professor atualizado!',
                                            ),
                                          ),
                                        );
                                      },
                                      teacherController: _service,
                                    ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      backgroundColor: Colors.grey.shade800,
                                      title: Text(
                                        'Eliminar Professor',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: Text(
                                        'Tem certeza que deseja eliminar este professor?',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                await _service.professorsCollection
                                    .doc(teacher.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Professor eliminado!'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/teacher_detail',
                          arguments: teacher.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
