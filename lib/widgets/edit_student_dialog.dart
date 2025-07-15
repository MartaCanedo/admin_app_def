import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';
import '../models/student_model.dart';
import 'student_course_selector.dart';
import 'student_year_selector.dart';

class EditStudentDialog extends StatefulWidget {
  final Student student;
  final List<String> allCourses;
  final Function(Student) onStudentUpdated;
  final StudentController studentController;
  const EditStudentDialog({
    super.key,
    required this.student,
    required this.allCourses,
    required this.onStudentUpdated,
    required this.studentController,
  });

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController nacionalidadeController;
  late TextEditingController distritoController;
  late TextEditingController moradaController;
  late TextEditingController codigoPostalController;
  late TextEditingController dataNascimentoController;
  late TextEditingController profissaoController;
  late TextEditingController nifController;
  late TextEditingController ibanController;
  String? selectedCourse;
  int? selectedYear;
  final List<int> availableYears = [1, 2, 3];
  Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    nomeController = TextEditingController(text: s.nome);
    emailController = TextEditingController(text: s.userId);
    nacionalidadeController = TextEditingController(text: s.nacionalidade);
    distritoController = TextEditingController(text: s.distrito);
    moradaController = TextEditingController(text: s.morada);
    codigoPostalController = TextEditingController(text: s.codigoPostal);
    dataNascimentoController = TextEditingController(text: s.dataNascimento);
    profissaoController = TextEditingController(text: s.profissao);
    nifController = TextEditingController(text: s.nif);
    ibanController = TextEditingController(text: s.iban);
    selectedCourse = s.courseId;
    selectedYear = s.year;
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    nacionalidadeController.dispose();
    distritoController.dispose();
    moradaController.dispose();
    codigoPostalController.dispose();
    dataNascimentoController.dispose();
    profissaoController.dispose();
    nifController.dispose();
    ibanController.dispose();
    super.dispose();
  }

  void _openCourseSelection() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StudentCourseSelector(
          allCourses: widget.allCourses,
          selectedCourse: selectedCourse,
          onCourseSelected: (course) {
            setState(() {
              selectedCourse = course;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _openYearSelection() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StudentYearSelector(
          availableYears: availableYears,
          selectedYear: selectedYear,
          onYearSelected: (year) {
            setState(() {
              selectedYear = year;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  InputDecoration fieldDecoration(String label, String key) {
    return InputDecoration(
      labelText: _fieldErrors[key] != null ? label + ' *' : label,
      labelStyle: TextStyle(
        color: _fieldErrors[key] != null ? Colors.redAccent : Colors.white70,
        fontWeight:
            _fieldErrors[key] != null ? FontWeight.bold : FontWeight.normal,
      ),
      errorText: _fieldErrors[key],
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: _fieldErrors[key] != null ? Colors.redAccent : Colors.white24,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: _fieldErrors[key] != null ? Colors.redAccent : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade800,
      title: Text('Editar Aluno', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: fieldDecoration('Nome Completo', 'nome'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: emailController,
              decoration: fieldDecoration('Email', 'email'),
              style: TextStyle(color: Colors.white),
              enabled: false,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openCourseSelection,
                    child: Container(
                      width: 90,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          selectedCourse != null ? selectedCourse! : 'Curso',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _openYearSelection,
                    child: Container(
                      width: 90,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          selectedYear != null ? 'Ano $selectedYear' : 'Ano',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: nacionalidadeController,
              decoration: fieldDecoration('Nacionalidade', 'nacionalidade'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: distritoController,
              decoration: fieldDecoration('Distrito', 'distrito'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: moradaController,
              decoration: fieldDecoration('Morada', 'morada'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: codigoPostalController,
              decoration: fieldDecoration('Código Postal', 'codigoPostal'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: dataNascimentoController,
              decoration: fieldDecoration(
                'Data de Nascimento',
                'dataNascimento',
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: profissaoController,
              decoration: fieldDecoration('Profissão', 'profissao'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: nifController,
              decoration: fieldDecoration('NIF', 'nif'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: ibanController,
              decoration: fieldDecoration('IBAN', 'iban'),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            Map<String, String?> errors = {};
            final nome = nomeController.text.trim();
            final curso = selectedCourse ?? '';
            final ano = selectedYear ?? 1;
            final nacionalidade = nacionalidadeController.text.trim();
            final distrito = distritoController.text.trim();
            final morada = moradaController.text.trim();
            final codigoPostal = codigoPostalController.text.trim();
            final dataNascimento = dataNascimentoController.text.trim();
            final profissao = profissaoController.text.trim();
            final nif = nifController.text.trim();
            final iban = ibanController.text.trim();
            if (nome.isEmpty) {
              errors['nome'] = 'O nome é obrigatório';
            } else if (nome.length < 3) {
              errors['nome'] = 'O nome deve ter pelo menos 3 letras';
            }

            if (curso.isEmpty) errors['curso'] = 'Selecione um curso';
            if (ano == null) {
              errors['ano'] = 'Selecione o ano';
            } else if (!(ano >= 1 && ano <= 3)) {
              errors['ano'] = 'Ano inválido';
            }
            if (nacionalidade.isEmpty) {
              errors['nacionalidade'] = 'A nacionalidade é obrigatória';
            } else if (!RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(nacionalidade)) {
              errors['nacionalidade'] =
                  'A nacionalidade deve conter apenas letras';
            }
            if (distrito.isEmpty) {
              errors['distrito'] = 'O distrito é obrigatório';
            } else if (!RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(distrito)) {
              errors['distrito'] = 'O distrito deve conter apenas letras';
            }
            if (morada.isEmpty) errors['morada'] = 'A morada é obrigatória';
            if (codigoPostal.isEmpty) {
              errors['codigoPostal'] = 'O código postal é obrigatório';
            } else if (!RegExp(r'^[0-9]{4}-[0-9]{3}$').hasMatch(codigoPostal)) {
              errors['codigoPostal'] = 'Formato: 1234-123';
            }
            if (dataNascimento.isEmpty) {
              errors['dataNascimento'] = 'A data de nascimento é obrigatória';
            } else if (!RegExp(
              r'^\d{2}/\d{2}/\d{4}$',
            ).hasMatch(dataNascimento)) {
              errors['dataNascimento'] = 'Formato: dd/MM/aaaa';
            } else {
              try {
                final parts = dataNascimento.split('/');
                final d = int.parse(parts[0]);
                final m = int.parse(parts[1]);
                final y = int.parse(parts[2]);
                final date = DateTime(y, m, d);
                final now = DateTime.now();
                int age = now.year - date.year;
                if (now.month < date.month ||
                    (now.month == date.month && now.day < date.day)) {
                  age--;
                }
                if (date.year != y || date.month != m || date.day != d) {
                  errors['dataNascimento'] = 'Data inválida';
                } else if (age < 18 || age > 100) {
                  errors['dataNascimento'] =
                      'O aluno deve ter entre 18 e 100 anos.';
                }
              } catch (_) {
                errors['dataNascimento'] = 'Data inválida';
              }
            }
            if (profissao.isEmpty)
              errors['profissao'] = 'A profissão é obrigatória';
            if (nif.isEmpty) {
              errors['nif'] = 'O NIF é obrigatório';
            } else if (!RegExp(r'^\d{9}$').hasMatch(nif)) {
              errors['nif'] = 'O NIF deve ter 9 dígitos numéricos';
            }
            if (iban.isEmpty) {
              errors['iban'] = 'O IBAN é obrigatório';
            } else if (!RegExp(r'^PT50[0-9A-Z]{21}$').hasMatch(iban)) {
              errors['iban'] = 'Formato: PT50 seguido de 21 dígitos/letras';
            }
            setState(() {
              _fieldErrors = errors;
            });
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(firstError ?? 'Erro nos campos!')),
              );
              return;
            }
            final updatedStudent = Student(
              id: widget.student.id,
              userId: widget.student.userId,
              nome: nome,
              courseId: curso,
              year: ano,
              nacionalidade: nacionalidade,
              distrito: distrito,
              morada: morada,
              codigoPostal: codigoPostal,
              dataNascimento: dataNascimento,
              profissao: profissao,
              nif: nif,
              iban: iban,
              password:
                  widget.student.password, // Preserving the original password
            );
            await widget.studentController.updateStudent(updatedStudent);
            Navigator.of(context).pop();
            widget.onStudentUpdated(updatedStudent);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Aluno atualizado com sucesso!')),
            );
          },
          child: Text('Salvar'),
        ),
      ],
    );
  }
}
