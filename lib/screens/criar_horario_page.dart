import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/horario_model.dart';
import '../controllers/horario_controller.dart';

class CriarHorarioPage extends StatefulWidget {
  final String courseId;

  const CriarHorarioPage({super.key, required this.courseId});

  @override
  State<CriarHorarioPage> createState() => _CriarHorarioPageState();
}

class _CriarHorarioPageState extends State<CriarHorarioPage>
    with TickerProviderStateMixin {
  final List<String> diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
  ];
  final List<String> timeSlots = [
    '10:00 - 11:30',
    '11:30 - 13:00',
    '13:30 - 15:00',
    '15:00 - 16:30',
    '16:30 - 18:00',
    '18:00 - 19:30',
  ];

  Map<int, List<Map<String, dynamic>>> aulasPorAno = {1: [], 2: [], 3: []};

  late TabController _tabController;
  Map<int, List<String>> disciplinasPorAno = {1: [], 2: [], 3: []};
  String? selectedDia;
  String? selectedTimeSlot;

  Map<int, String?> selectedDisciplinaPorAno = {1: null, 2: null, 3: null};

  final HorarioController _controller = HorarioController();
  bool loadingDisciplinas = true;

  String get pageTitle {
    return aulasPorAno.values.any((aulas) => aulas.isNotEmpty)
        ? "Editar Horário"
        : "Criar Horário";
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Force rebuild to update dropdown on tab change
    });
    _carregarDisciplinas();
    _carregarHorarioExistente();
  }

  Future<void> _carregarHorarioExistente() async {
    try {
      final horarioExistente = await _controller.buscarHorarioPorCurso(
        widget.courseId,
      );
      if (horarioExistente != null) {
        setState(() {
          aulasPorAno = horarioExistente.aulasPorAno.map(
            (key, value) => MapEntry(int.parse(key), value),
          );
        });
      }
    } catch (e) {
      print('Erro ao carregar horário existente: $e');
    }
  }

  Future<void> _carregarDisciplinas() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.courseId)
              .collection('subjects')
              .get();

      Map<int, List<String>> porAno = {1: [], 2: [], 3: []};
      for (var doc in snapshot.docs) {
        final year = (doc['courseYear'] ?? 1) as int;
        if (porAno.containsKey(year)) {
          porAno[year]!.add(doc['name'].toString());
        }
      }

      setState(() {
        disciplinasPorAno = porAno;
        // Always reset selectedDisciplinaPorAno to null for all years
        selectedDisciplinaPorAno = {1: null, 2: null, 3: null};
        loadingDisciplinas = false;
      });
    } catch (e) {
      print('Erro ao carregar disciplinas: $e');
    }
  }

  void _adicionarAula(int ano) {
    final selectedDisciplina = selectedDisciplinaPorAno[ano];
    if (selectedDisciplina != null &&
        selectedDisciplina != '__select__' &&
        selectedDia != null &&
        selectedTimeSlot != null) {
      // Validation: prevent duplicate aula in the same day/time for this year
      final partes = selectedTimeSlot!.split(' - ');
      final horaInicio = partes[0];
      final exists = aulasPorAno[ano]!.any(
        (a) => a['diaSemana'] == selectedDia && a['horaInicio'] == horaInicio,
      );
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Já existe uma aula neste dia e horário para este ano.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      final horaFim = partes[1];
      aulasPorAno[ano]!.add({
        'disciplina': selectedDisciplina,
        'diaSemana': selectedDia!,
        'horaInicio': horaInicio,
        'horaFim': horaFim,
      });

      setState(() {
        selectedDia = null;
        selectedTimeSlot = null;
      });
    }
  }

  void _salvarHorario() async {
    final horario = Horario(
      id: '',
      courseId: widget.courseId,
      aulasPorAno: aulasPorAno.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
    await _controller.criarOuAtualizarHorario(horario);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildHorarioTable(List<Map<String, dynamic>> aulas, int ano) {
    return Table(
      border: TableBorder.all(color: Colors.white24),
      columnWidths: const {0: FixedColumnWidth(100)},
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF23272A)),
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Horário', style: TextStyle(color: Colors.white)),
            ),
            ...diasSemana
                .map(
                  (d) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
        ...timeSlots.map((slot) {
          final inicioSlot = slot.split(' - ')[0];
          return TableRow(
            decoration: const BoxDecoration(color: Color(0xFF2C2F33)),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(slot, style: const TextStyle(color: Colors.white)),
              ),
              ...diasSemana.map((dia) {
                final aula = aulas.firstWhere((a) {
                  final inicioAula = a['horaInicio'];
                  final fimAula = a['horaFim'];
                  return a['diaSemana'] == dia &&
                      _isSlotInRange(slot, inicioAula, fimAula);
                }, orElse: () => {});

                if (aula.isNotEmpty && aula['horaInicio'] == inicioSlot) {
                  return GestureDetector(
                    onTap: () => _removerAula(ano, aula),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              aula['disciplina'],
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.close,
                              color: Colors.red.withOpacity(0.7),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (aula.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(4),
                    color: Colors.grey[900],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }

  void _removerAula(int ano, Map<String, dynamic> aula) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Text(
              'Remover Aula',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Deseja remover a aula de ${aula['disciplina']} na ${aula['diaSemana']} às ${aula['horaInicio']}?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    aulasPorAno[ano]!.removeWhere(
                      (a) =>
                          a['diaSemana'] == aula['diaSemana'] &&
                          a['horaInicio'] == aula['horaInicio'] &&
                          a['disciplina'] == aula['disciplina'],
                    );
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Remover',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  bool _isSlotInRange(String slot, String inicio, String fim) {
    final startSlot = slot.split(' - ')[0];
    return _timeToMinutes(startSlot) >= _timeToMinutes(inicio) &&
        _timeToMinutes(startSlot) < _timeToMinutes(fim);
  }

  int _timeToMinutes(String t) {
    final parts = t.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text(pageTitle, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "1º Ano"),
            Tab(text: "2º Ano"),
            Tab(text: "3º Ano"),
          ],
        ),
      ),
      body:
          loadingDisciplinas
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children:
                    [1, 2, 3].map((ano) {
                      final disciplinas = disciplinasPorAno[ano]!;
                      final selectedDisciplina = selectedDisciplinaPorAno[ano];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                DropdownButton<String>(
                                  dropdownColor: const Color(0xFF23272A),
                                  value:
                                      selectedDisciplina != null &&
                                              disciplinas.contains(
                                                selectedDisciplina,
                                              )
                                          ? selectedDisciplina
                                          : '__select__',
                                  hint: const Text(
                                    "Disciplina",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: '__select__',
                                      enabled: false,
                                      child: Text(
                                        'Selecione uma disciplina',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                    ...disciplinas
                                        .map(
                                          (disc) => DropdownMenuItem(
                                            value: disc,
                                            child: Text(
                                              disc,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                  onChanged: (val) {
                                    if (val != null && val != '__select__') {
                                      setState(
                                        () =>
                                            selectedDisciplinaPorAno[ano] = val,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  dropdownColor: const Color(0xFF23272A),
                                  hint: const Text(
                                    "Dia",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  value: selectedDia,
                                  items:
                                      diasSemana
                                          .map(
                                            (dia) => DropdownMenuItem(
                                              value: dia,
                                              child: Text(
                                                dia,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) =>
                                          setState(() => selectedDia = val),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  dropdownColor: const Color(0xFF23272A),
                                  hint: const Text(
                                    "Horário",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  value: selectedTimeSlot,
                                  items:
                                      timeSlots
                                          .map(
                                            (slot) => DropdownMenuItem(
                                              value: slot,
                                              child: Text(
                                                slot,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) => setState(
                                        () => selectedTimeSlot = val,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed:
                                      (selectedDisciplina == null ||
                                              selectedDisciplina ==
                                                  '__select__' ||
                                              selectedDia == null ||
                                              selectedTimeSlot == null)
                                          ? null
                                          : () => _adicionarAula(ano),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Adicionar"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (aulasPorAno[ano]!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Clique numa aula para removê-la',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _buildHorarioTable(
                                  aulasPorAno[ano]!,
                                  ano,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed:
              aulasPorAno.values.every((a) => a.isNotEmpty)
                  ? _salvarHorario
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey,
          ),
          child: Text(
            aulasPorAno.values.any((aulas) => aulas.isNotEmpty)
                ? "Atualizar Horário"
                : "Salvar Horário",
          ),
        ),
      ),
    );
  }
}
