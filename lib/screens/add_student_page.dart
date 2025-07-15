// lib/pages/add_student_page.dart
import 'package:flutter/material.dart';
import 'dart:math';

import 'student_detail_page.dart';
import '../controllers/course_controller.dart';
import '../controllers/student_controller.dart';
import '../models/student_model.dart';
import '../services/send_email_service.dart';
import '../widgets/edit_student_dialog.dart';
import '../widgets/add_student_dialog.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  // Removed unused _emailExists and _openYearSelection (now handled in AddStudentDialog)

  final StudentController _studentController = StudentController();

  // Gera senha aleatória
  String _generateRandomPassword({int length = 8}) {
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

  // Lógica para enviar email ao aluno (adapte para seu serviço de email)
  Future<void> _sendStudentEmail({
    required String nome,
    required String email,
    required String password,
  }) async {
    try {
      await SendEmailService.sendProfessorEmail(
        nome: nome,
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erro ao enviar email: $e');
    }
  }

  List<String> allCourses = [];
  String? selectedCourse;
  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      // Busca os cursos do Firestore usando CourseController
      final courses = await CourseController().getCourses();
      setState(() {
        allCourses = courses.map((c) => c.name).toList();
      });
    } catch (e) {
      setState(() {
        allCourses = [];
      });
    }
  }

  // Controllers and field errors are now managed in AddStudentDialog
  void _openAddStudentDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AddStudentDialog(
          allCourses: allCourses,
          studentController: _studentController,
          onStudentAdded: (student) {
            // Optionally refresh or handle after add
          },
        );
      },
    );
  }

  // _submitStudent logic is now handled in AddStudentDialog

  // Modal para seleção de curso (apenas 1 pode ser selecionado)
  void _openCourseSelection() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Selecione o curso',
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
                          allCourses.map((course) {
                            final isSelected = selectedCourse == course;
                            return ListTile(
                              title: Text(
                                course,
                                style: TextStyle(
                                  color: isSelected ? Colors.red : Colors.white,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              trailing:
                                  isSelected
                                      ? Icon(Icons.check, color: Colors.red)
                                      : null,
                              onTap: () {
                                setState(() {
                                  selectedCourse = course;
                                });
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _searchText = '';

  void _openEditStudentDialog(Student student) {
    showDialog(
      context: context,
      builder:
          (context) => EditStudentDialog(
            student: student,
            allCourses: allCourses,
            studentController: _studentController,
            onStudentUpdated: (updatedStudent) {
              // Optionally refresh or handle after update
            },
          ),
    );
  }

  void _confirmDeleteStudent(Student student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: Text('Excluir Aluno', style: TextStyle(color: Colors.white)),
            content: Text(
              'Tem certeza que deseja excluir o aluno "${student.nome}"?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await _studentController.deleteStudent(student.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Aluno excluído com sucesso!')),
                  );
                },
                child: Text('Excluir'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text("Alunos", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            onPressed: _openAddStudentDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, email ou curso',
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
                  _searchText = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _studentController.getStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar alunos.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                final students = snapshot.data ?? [];
                final filteredStudents =
                    students.where((student) {
                      final nome = student.nome.toLowerCase();
                      final curso = student.courseId.toLowerCase();
                      final year = student.year.toString();
                      final search = _searchText;
                      return nome.contains(search) ||
                          curso.contains(search) ||
                          year.contains(search);
                    }).toList();
                if (filteredStudents.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum aluno cadastrado.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StudentDetailPage(
                                  studentId: student.id,
                                  onEdit: () => _openEditStudentDialog(student),
                                  onDelete:
                                      () => _confirmDeleteStudent(student),
                                ),
                          ),
                        );
                      },
                      title: Text(
                        student.nome,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${student.courseId} - Ano ${student.year}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            tooltip: 'Editar',
                            onPressed: () => _openEditStudentDialog(student),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            tooltip: 'Excluir',
                            onPressed: () => _confirmDeleteStudent(student),
                          ),
                        ],
                      ),
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
