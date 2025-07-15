import 'package:flutter/material.dart';
import '../controllers/teacher_controller.dart';
import '../models/teacher_model.dart';
import 'teacher_subject_selector.dart';

class EditTeacherDialog extends StatefulWidget {
  final Professor teacher;
  final List<String> allSubjects;
  final Function(Professor) onTeacherUpdated;
  final ProfessorService teacherController;

  EditTeacherDialog({
    Key? key,
    required this.teacher,
    required this.allSubjects,
    required this.onTeacherUpdated,
    required this.teacherController,
  }) : super(key: key);

  @override
  State<EditTeacherDialog> createState() => _EditTeacherDialogState();
}

class _EditTeacherDialogState extends State<EditTeacherDialog> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController nacionalidadeController;
  late TextEditingController distritoController;
  late TextEditingController moradaController;
  late TextEditingController codigoPostalController;
  late TextEditingController dataNascimentoController;
  late TextEditingController nifController;
  late TextEditingController ibanController;
  late List<String> selectedSubjects;
  Map<String, String?> errors = {};

  @override
  void initState() {
    super.initState();
    final t = widget.teacher;
    nomeController = TextEditingController(text: t.nome);
    emailController = TextEditingController(text: t.email);
    nacionalidadeController = TextEditingController(text: t.nacionalidade);
    distritoController = TextEditingController(text: t.distrito);
    moradaController = TextEditingController(text: t.morada);
    codigoPostalController = TextEditingController(text: t.codigoPostal);
    dataNascimentoController = TextEditingController(text: t.dataNascimento);
    nifController = TextEditingController(text: t.nif);
    ibanController = TextEditingController(text: t.iban);
    selectedSubjects = List<String>.from(t.disciplinas);
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
    nifController.dispose();
    ibanController.dispose();
    super.dispose();
  }

  void _openSubjectSelection() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey.shade800,
      isScrollControlled: true,
      builder: (context) {
        return TeacherSubjectSelector(
          allSubjects: widget.allSubjects,
          selectedSubjects: selectedSubjects,
          onSubjectSelected: (subject) {
            setState(() {
              if (selectedSubjects.contains(subject)) {
                selectedSubjects.clear();
              } else {
                selectedSubjects
                  ..clear()
                  ..add(subject);
              }
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> validateFields() async {
    setState(() {
      errors.clear();
    });
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final nacionalidade = nacionalidadeController.text.trim();
    final distrito = distritoController.text.trim();
    final morada = moradaController.text.trim();
    final codigoPostal = codigoPostalController.text.trim();
    final dataNascimento = dataNascimentoController.text.trim();
    final nif = nifController.text.trim();
    final iban = ibanController.text.trim();
    if (nome.isEmpty) {
      errors['nome'] = 'O nome é obrigatório';
    } else if (nome.length < 3) {
      errors['nome'] = 'O nome deve ter pelo menos 3 letras';
    }

    if (selectedSubjects.isEmpty) {
      errors['disciplinas'] = 'Selecione pelo menos uma disciplina';
    }
    if (nacionalidade.isEmpty) {
      errors['nacionalidade'] = 'A nacionalidade é obrigatória';
    } else if (!RegExp(r'^[A-Za-zÀ-ÿ\s]+').hasMatch(nacionalidade)) {
      errors['nacionalidade'] = 'A nacionalidade deve conter apenas letras';
    }
    if (distrito.isEmpty) {
      errors['distrito'] = 'O distrito é obrigatório';
    } else if (!RegExp(r'^[A-Za-zÀ-ÿ\s]+').hasMatch(distrito)) {
      errors['distrito'] = 'O distrito deve conter apenas letras';
    }
    if (morada.isEmpty) errors['morada'] = 'A morada é obrigatória';
    if (codigoPostal.isEmpty) {
      errors['codigoPostal'] = 'O código postal é obrigatório';
    } else if (!RegExp(r'^[0-9]{4}-[0-9]{3}').hasMatch(codigoPostal)) {
      errors['codigoPostal'] = 'Formato: 1234-123';
    }
    if (dataNascimento.isEmpty) {
      errors['dataNascimento'] = 'A data de nascimento é obrigatória';
    } else if (!RegExp(r'^\d{2}/\d{2}/\d{4}').hasMatch(dataNascimento)) {
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
              'O professor deve ter entre 18 e 100 anos.';
        }
      } catch (_) {
        errors['dataNascimento'] = 'Data inválida';
      }
    }
    if (nif.isEmpty) {
      errors['nif'] = 'O NIF é obrigatório';
    } else if (!RegExp(r'^\d{9}').hasMatch(nif)) {
      errors['nif'] = 'O NIF deve ter 9 dígitos numéricos';
    }
    if (iban.isEmpty) {
      errors['iban'] = 'O IBAN é obrigatório';
    } else if (!RegExp(r'^PT50[0-9A-Z]{21}').hasMatch(iban)) {
      errors['iban'] = 'Formato: PT50 seguido de 21 dígitos/letras';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade800,
      title: Text('Editar Professor', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['nome'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['nome'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['nome'] != null
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: emailController,
              readOnly: true,
              focusNode: FocusNode(canRequestFocus: false),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['email'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['email'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['email'] != null
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            TextField(
              controller: nacionalidadeController,
              decoration: InputDecoration(
                labelText: 'Nacionalidade',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['nacionalidade'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['nacionalidade'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['nacionalidade'] != null
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: distritoController,
              decoration: InputDecoration(
                labelText: 'Distrito',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['distrito'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['distrito'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['distrito'] != null
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: moradaController,
              decoration: InputDecoration(
                labelText: 'Morada',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['morada'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['morada'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['morada'] != null
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: codigoPostalController,
              decoration: InputDecoration(
                labelText: 'Código Postal',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['codigoPostal'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['codigoPostal'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['codigoPostal'] != null
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: dataNascimentoController,
              decoration: InputDecoration(
                labelText: 'Data de Nascimento',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['dataNascimento'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['dataNascimento'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['dataNascimento'] != null
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: nifController,
              decoration: InputDecoration(
                labelText: 'NIF',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['nif'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['nif'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['nif'] != null ? Colors.redAccent : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: ibanController,
              decoration: InputDecoration(
                labelText: 'IBAN',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: errors['iban'],
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['iban'] != null
                            ? Colors.redAccent
                            : Colors.white24,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        errors['iban'] != null
                            ? Colors.redAccent
                            : Colors.white,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            GestureDetector(
              onTap: _openSubjectSelection,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errors['disciplinas'] ?? '',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            await validateFields();
            if (errors.isEmpty) {
              final updatedTeacher = Professor(
                id: widget.teacher.id,
                nome: nomeController.text.trim(),
                email: emailController.text.trim(),
                password: widget.teacher.password,
                nacionalidade: nacionalidadeController.text.trim(),
                distrito: distritoController.text.trim(),
                morada: moradaController.text.trim(),
                codigoPostal: codigoPostalController.text.trim(),
                dataNascimento: dataNascimentoController.text.trim(),
                nif: nifController.text.trim(),
                iban: ibanController.text.trim(),
                disciplinas: List<String>.from(selectedSubjects),
              );
              widget.onTeacherUpdated(updatedTeacher);
              Navigator.of(context).pop();
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
