import 'package:flutter/material.dart';
import '../controllers/horario_controller.dart';
import '../models/horario_model.dart';

class ConsultarHorarioPage extends StatefulWidget {
  final String courseId;
  const ConsultarHorarioPage({super.key, required this.courseId});

  @override
  State<ConsultarHorarioPage> createState() => _ConsultarHorarioPageState();
}

class _ConsultarHorarioPageState extends State<ConsultarHorarioPage> with TickerProviderStateMixin {
  final HorarioController _horarioController = HorarioController();
  Horario? horario;
  late TabController _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHorario();
  }

  Future<void> _loadHorario() async {
    setState(() { _loading = true; });
    final data = await _horarioController.buscarHorarioPorCurso(widget.courseId);
    if (mounted) {
      setState(() {
        horario = data;
        _loading = false;
      });
    }
  }

  Future<void> _eliminar() async {
    if (horario == null) return;
    await _horarioController.eliminarHorario(horario!.courseId);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/horario_list', (route) => false);
  }

  Widget _buildGridHorario(List<Map<String, dynamic>> aulas) {
    final diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
    final timeSlots = [
      '10:00 - 11:30',
      '11:30 - 13:00',
      '13:30 - 15:00',
      '15:00 - 16:30',
      '16:30 - 18:00',
      '18:00 - 19:30',
    ];
    return Table(
      border: TableBorder.all(color: Colors.white24),
      columnWidths: const {
        0: FixedColumnWidth(100),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF23272A)),
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('', style: TextStyle(color: Colors.white)),
            ),
            ...diasSemana.map((d) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            )),
          ],
        ),
        ...timeSlots.asMap().entries.map((entry) {
          final i = entry.key;
          final slot = entry.value;
          return TableRow(
            decoration: const BoxDecoration(color: Color(0xFF2C2F33)),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(slot, style: const TextStyle(color: Colors.white)),
              ),
              ...diasSemana.map((dia) {
                final aulasSlot = aulas.where((a) => a['diaSemana'] == dia && a['horaInicio'] == slot.split(' - ')[0]).toList();
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: aulasSlot.map((a) => Container(
                      color: Colors.grey[800],
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(4),
                      child: Text(a['disciplina'], style: const TextStyle(color: Colors.white)),
                    )).toList(),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList()
      ],
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey.shade800,
    appBar: AppBar(
      backgroundColor: Colors.grey.shade900,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text('Consultar Horário', style: TextStyle(color: Colors.white)),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(text: '1º Ano'),
          Tab(text: '2º Ano'),
          Tab(text: '3º Ano'),
        ],
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : horario == null
            ? const Center(child: Text('Nenhum horário encontrado.', style: TextStyle(color: Colors.white70)))
            : TabBarView(
                controller: _tabController,
                children: [1, 2, 3].map((ano) {
                  final aulas = horario!.aulasPorAno[ano.toString()] ?? [];
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(child: _buildGridHorario(aulas)),
                  );
                }).toList(),
              ),
    bottomNavigationBar: _loading || horario == null
        ? null
        : Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirmar", style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.black,
                    content: const Text("Tem certeza que deseja eliminar todos os horários deste curso?", style: TextStyle(color: Colors.white)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _eliminar();
                  // No need to pop again, navigation handled in _eliminar
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Eliminar Horário"),
            ),
          ),
  );
}

}