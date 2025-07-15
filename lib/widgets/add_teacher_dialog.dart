import 'package:flutter/material.dart';
import '../controllers/teacher_controller.dart';
// Ensure that TeacherController is defined in the imported file.
import '../controllers/subject_controller.dart';
import '../models/teacher_model.dart';
import '../services/send_email_service.dart';
import 'teacher_subject_selector.dart';

class AddTeacherDialog extends StatefulWidget {
  final List<String> allSubjects;
  final Function(Professor) onTeacherAdded;
  final ProfessorService teacherController;
  const AddTeacherDialog({
    Key? key,
    required this.allSubjects,
    required this.onTeacherAdded,
    required this.teacherController,
  }) : super(key: key);

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
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
  Map<String, String?> errors = {};

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
    errors.clear();
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
    if (email.isEmpty) {
      errors['email'] = 'O email é obrigatório';
    } else if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(email)) {
      errors['email'] = 'Email inválido';
    } else {
      bool emailExists = await widget.teacherController.emailJaExiste(email);
      if (emailExists) {
        errors['email'] = 'Já existe um professor com este email';
      }
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

  InputDecoration fieldDecoration(String label, String key) {
    return InputDecoration(
      labelText: label + (errors[key] != null ? ' *' : ''),
      labelStyle: TextStyle(
        color: errors[key] != null ? Colors.redAccent : Colors.white70,
        fontWeight: errors[key] != null ? FontWeight.bold : FontWeight.normal,
      ),
      errorText: errors[key],
    );
  }

  String generateRandomPassword({int length = 8}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%&*';
    final rnd = DateTime.now().millisecondsSinceEpoch % 1000000;
    return List.generate(
      length,
      (i) => chars[(rnd + i * 37) % chars.length],
    ).join();
  }

  Future<void> _submitTeacher() async {
    final name = nomeController.text.trim();
    final email = emailController.text.trim();
    final nationality = nacionalidadeController.text.trim();
    final district = distritoController.text.trim();
    final address = moradaController.text.trim();
    final postalCode = codigoPostalController.text.trim();
    final birthDate = dataNascimentoController.text.trim();
    final nif = nifController.text.trim();
    final iban = ibanController.text.trim();
    final String disciplinaSelecionadaId =
        selectedSubjects.isNotEmpty ? selectedSubjects.first : '';

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

    bool emailJaExiste = await widget.teacherController.emailJaExiste(email);
    if (emailJaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Já existe um professor com este email.')),
      );
      return;
    }

    final password = generateRandomPassword();
    final id = UniqueKey().toString();

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
      bool jaAtribuida = await widget.teacherController.disciplinaJaAtribuida(
        disciplinaSelecionadaId,
      );
      if (jaAtribuida) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disciplina já atribuída a outro professor.')),
        );
      } else {
        await widget.teacherController.createProfessor(professor);
        await SendEmailService.sendProfessorEmail(
          nome: name,
          email: email,
          password: password,
        );
        widget.onTeacherAdded(professor);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Professor "$name" adicionado! Senha: $password'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao adicionar professor.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade800,
      title: Text('Adicionar Professor', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ),
            GestureDetector(
              onTap: _openSubjectSelection,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color:
                      errors['disciplinas'] != null
                          ? Colors.red.shade200.withOpacity(0.2)
                          : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      errors['disciplinas'] != null
                          ? Border.all(color: Colors.redAccent)
                          : null,
                ),
                child: Text(
                  'Selecionar Disciplina' +
                      (errors['disciplinas'] != null ? ' *' : ''),
                  style: TextStyle(
                    color:
                        errors['disciplinas'] != null
                            ? Colors.redAccent
                            : Colors.white70,
                  ),
                ),
              ),
            ),
            if (errors['disciplinas'] != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                  child: Text(
                    errors['disciplinas']!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ),
            if (selectedSubjects.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 12),
                child: Column(
                  children:
                      selectedSubjects.map((subject) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 6),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subject,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSubjects.remove(subject);
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
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
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: fieldDecoration(
                'Data de Nascimento (dd/MM/aaaa)',
                'dataNascimento',
              ).copyWith(hintText: 'dd/MM/aaaa', counterText: ''),
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
            await validateFields();
            setState(() {});
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(firstError ?? 'Erro nos campos!')),
              );
              return;
            }
            await _submitTeacher();
          },
          child: Text('Adicionar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
