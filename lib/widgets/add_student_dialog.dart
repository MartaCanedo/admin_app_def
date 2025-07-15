import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';
import '../services/send_email_service.dart';
import '../models/student_model.dart';
import 'student_course_selector.dart';
import 'student_year_selector.dart';

class AddStudentDialog extends StatefulWidget {
  final List<String> allCourses;
  final Function(Student) onStudentAdded;
  final StudentController studentController;
  const AddStudentDialog({
    super.key,
    required this.allCourses,
    required this.onStudentAdded,
    required this.studentController,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selectedCourse;
  int? selectedYear;
  final List<int> availableYears = [1, 2, 3];
  final TextEditingController nacionalidadeController = TextEditingController();
  final TextEditingController distritoController = TextEditingController();
  final TextEditingController moradaController = TextEditingController();
  final TextEditingController codigoPostalController = TextEditingController();
  final TextEditingController dataNascimentoController =
      TextEditingController();
  final TextEditingController profissaoController = TextEditingController();
  final TextEditingController nifController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();
  Map<String, String?> _fieldErrors = {};

  Future<bool> _emailExists(String email) async {
    return await widget.studentController.emailExists(email);
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

  String _generateRandomPassword({int length = 8}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%&*';
    final rnd = (DateTime.now().millisecondsSinceEpoch % 1000000);
    return List.generate(
      length,
      (i) => chars[(rnd + i * 37) % chars.length],
    ).join();
  }

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
      title: Text('Adicionar Aluno', style: TextStyle(color: Colors.white)),
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
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openCourseSelection,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 120, minHeight: 36),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      margin: EdgeInsets.only(bottom: 8, right: 6),
                      decoration: BoxDecoration(
                        color:
                            _fieldErrors['curso'] != null
                                ? Colors.red.shade200.withOpacity(0.2)
                                : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            _fieldErrors['curso'] != null
                                ? Border.all(color: Colors.redAccent)
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          selectedCourse != null
                              ? selectedCourse! +
                                  (_fieldErrors['curso'] != null ? ' *' : '')
                              : 'Curso' +
                                  (_fieldErrors['curso'] != null ? ' *' : ''),
                          style: TextStyle(
                            color:
                                _fieldErrors['curso'] != null
                                    ? Colors.redAccent
                                    : Colors.white70,
                            fontSize: 14,
                            fontWeight:
                                _fieldErrors['curso'] != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
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
                      constraints: BoxConstraints(maxWidth: 120, minHeight: 36),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      margin: EdgeInsets.only(bottom: 8, left: 6),
                      decoration: BoxDecoration(
                        color:
                            _fieldErrors['ano'] != null
                                ? Colors.red.shade200.withOpacity(0.2)
                                : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            _fieldErrors['ano'] != null
                                ? Border.all(color: Colors.redAccent)
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          selectedYear != null
                              ? 'Ano $selectedYear' +
                                  (_fieldErrors['ano'] != null ? ' *' : '')
                              : 'Ano' +
                                  (_fieldErrors['ano'] != null ? ' *' : ''),
                          style: TextStyle(
                            color:
                                _fieldErrors['ano'] != null
                                    ? Colors.redAccent
                                    : Colors.white70,
                            fontSize: 14,
                            fontWeight:
                                _fieldErrors['ano'] != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_fieldErrors['curso'] != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                  child: Text(
                    _fieldErrors['curso']!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
              ),
            if (_fieldErrors['ano'] != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                  child: Text(
                    _fieldErrors['ano']!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
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
            final email = emailController.text.trim();
            final curso = selectedCourse ?? '';
            final ano = selectedYear;
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
            if (email.isEmpty) {
              errors['email'] = 'O email é obrigatório';
            } else if (!RegExp(
              r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}",
            ).hasMatch(email)) {
              errors['email'] = 'Email inválido';
            } else {
              bool emailExists = await _emailExists(email);
              if (emailExists) {
                errors['email'] = 'Já existe um aluno com este email';
              }
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
            final password = _generateRandomPassword();
            final student = Student(
              id: UniqueKey().toString(),
              userId: email,
              nome: nome,
              courseId: curso,
              year: ano!,
              nacionalidade: nacionalidade,
              distrito: distrito,
              morada: morada,
              codigoPostal: codigoPostal,
              dataNascimento: dataNascimento,
              profissao: profissao,
              nif: nif,
              iban: iban,
              password: password,
            );
            await widget.studentController.addStudent(student);
            Navigator.pop(context);
            await _sendStudentEmail(
              nome: nome,
              email: email,
              password: password,
            );
            widget.onStudentAdded(student);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Aluno "$nome" adicionado com sucesso! Senha: $password',
                ),
              ),
            );
            nomeController.clear();
            emailController.clear();
            nacionalidadeController.clear();
            distritoController.clear();
            moradaController.clear();
            codigoPostalController.clear();
            dataNascimentoController.clear();
            profissaoController.clear();
            nifController.clear();
            ibanController.clear();
            selectedCourse = null;
            selectedYear = null;
          },
          child: Text('Adicionar'),
        ),
      ],
    );
  }
}
