import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import '../controllers/student_controller.dart';
import '../Controllers/teacher_controller.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Map<int, int> studentsByYear = {};
  Map<String, int> studentsByCourse = {};
  Map<String, int> professorsByCourse = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final studentController = StudentController();
    final professorService = ProfessorService();

    final yearData = await studentController.countAllStudentsByYear();
    final courseData = await studentController.countStudentsByCourse();
    final profData = await professorService.countProfessoresByCurso();

    setState(() {
      studentsByYear = yearData;
      studentsByCourse = courseData;
      professorsByCourse = profData;
      isLoading = false;
    });
  }

  Color _getColorForCourse(String course) {
    switch (course.toLowerCase()) {
      case 'engenharia':
      case 'engenharia_informatica':
        return Colors.orange;
      case 'gestao':
        return Colors.green;
      case 'informatica':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            color: Colors.grey.shade700,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Admin Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ListTile(
                      leading: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Lista Alunos',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () => Navigator.pushNamed(context, '/add_student'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.school, color: Colors.white),
                      title: const Text(
                        'Lista Professores',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () => Navigator.pushNamed(context, '/add_teacher'),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.library_books,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Cursos',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () => Navigator.pushNamed(context, '/cursos'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.book, color: Colors.white),
                      title: const Text(
                        'Disciplinas',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () => Navigator.pushNamed(context, '/disciplinas'),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.announcement,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Anúncios',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/create_announcement',
                          ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Marcação de Exames',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap:
                          () => Navigator.pushNamed(context, '/exam_schedule'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.schedule, color: Colors.white),
                      title: const Text(
                        'Horarios',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap:
                          () => Navigator.pushNamed(context, '/horario_list'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estatísticas Gerais',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      color: Colors.grey.shade700,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Alunos por Ano',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              child: BarChart(
                                                BarChartData(
                                                  barGroups:
                                                      studentsByYear.entries.map((
                                                        entry,
                                                      ) {
                                                        return BarChartGroupData(
                                                          x: entry.key,
                                                          barRods: [
                                                            BarChartRodData(
                                                              toY:
                                                                  entry.value
                                                                      .toDouble(),
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ],
                                                        );
                                                      }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Card(
                                      color: Colors.grey.shade700,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Alunos por Curso',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              child: PieChart(
                                                PieChartData(
                                                  sections:
                                                      studentsByCourse.entries.map((
                                                        entry,
                                                      ) {
                                                        return PieChartSectionData(
                                                          value:
                                                              entry.value
                                                                  .toDouble(),
                                                          title: entry.key,
                                                          color:
                                                              _getColorForCourse(
                                                                entry.key,
                                                              ),
                                                        );
                                                      }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Card(
                                color: Colors.grey.shade700,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Professores por Curso',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: BarChart(
                                          BarChartData(
                                            barGroups:
                                                professorsByCourse.entries
                                                    .toList()
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                      return BarChartGroupData(
                                                        x: entry.key,
                                                        barRods: [
                                                          BarChartRodData(
                                                            toY:
                                                                entry
                                                                    .value
                                                                    .value
                                                                    .toDouble(), // CORRETO AGORA
                                                            color: Colors.teal,
                                                          ),
                                                        ],
                                                      );
                                                    })
                                                    .toList(),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (
                                                    value,
                                                    meta,
                                                  ) {
                                                    final index = value.toInt();
                                                    if (index >= 0 &&
                                                        index <
                                                            professorsByCourse
                                                                .length) {
                                                      final courseName =
                                                          professorsByCourse
                                                              .keys
                                                              .elementAt(index);
                                                      return Text(
                                                        courseName,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                        ),
                                                      );
                                                    }
                                                    return const Text('');
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
