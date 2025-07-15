import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/horario_controller.dart';
import '../models/horario_model.dart';
import 'criar_horario_page.dart';
import '../screens/criar_horario_page.dart';
import 'consultar_horario_page.dart';

class HorarioListPageState extends StatefulWidget {
  const HorarioListPageState({super.key});

  @override
  State<HorarioListPageState> createState() => _HorarioListPageState();
}

class _HorarioListPageState extends State<HorarioListPageState> {
  final HorarioController _controller = HorarioController();
  Map<String, Horario?> horariosPublicados = {};
  bool _loading = true;
  List<Map<String, dynamic>> cursos = [];

  @override
  void initState() {
    super.initState();
    carregarHorarios();
  }

  Future<void> carregarHorarios() async {
    final cursosSnapshot =
        await FirebaseFirestore.instance.collection('courses').get();

    final results = <String, Horario?>{};
    final cursosList = <Map<String, dynamic>>[];

    for (var doc in cursosSnapshot.docs) {
      final cursoId = doc.id;
      final cursoName = doc['name'] ?? cursoId;
      cursosList.add({'id': cursoId, 'name': cursoName});
      final horario = await _controller.buscarHorarioPorCurso(cursoId);
      results[cursoId] = horario;
    }

    setState(() {
      horariosPublicados = results;
      cursos = cursosList;
      _loading = false;
    });
  }

  Widget _buildCursoCard(String courseId, String courseName) {
    final horario = horariosPublicados[courseId];

    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: horario != null ? Colors.green.shade600 : Colors.redAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            horario != null ? Icons.schedule : Icons.schedule_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          courseName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: horario != null ? Colors.green.shade600 : Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            horario != null ? "Horário Publicado" : "Sem Horário Publicado",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (horario != null) ...[
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConsultarHorarioPage(courseId: courseId),
                    ),
                  ).then((_) => carregarHorarios());
                },
                tooltip: 'Consultar horário',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CriarHorarioPage(courseId: courseId),
                    ),
                  ).then((_) => carregarHorarios());
                },
                tooltip: 'Editar horário',
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CriarHorarioPage(courseId: courseId),
                    ),
                  ).then((_) => carregarHorarios());
                },
                tooltip: 'Criar horário',
              ),
          ],
        ),
        onTap: () {
          if (horario == null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CriarHorarioPage(courseId: courseId),
              ),
            ).then((_) => carregarHorarios());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConsultarHorarioPage(courseId: courseId),
              ),
            ).then((_) => carregarHorarios());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: const Text('HORARIOS', style: TextStyle(color: Colors.white)),
        leading:
            Navigator.of(context).canPop()
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border(
                        bottom: BorderSide(color: Colors.white24, width: 1),
                      ),
                    ),
                    child: const Text(
                      "HORÁRIOS DOS CURSOS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        cursos.isEmpty
                            ? const Center(
                              child: Text(
                                'Nenhum curso encontrado.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: cursos.length,
                              itemBuilder: (context, index) {
                                final curso = cursos[index];
                                final id = curso['id'] as String;
                                final name = curso['name'] as String;
                                return _buildCursoCard(id, name);
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
