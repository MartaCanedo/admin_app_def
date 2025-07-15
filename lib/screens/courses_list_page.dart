import 'package:flutter/material.dart';
import 'package:admin_app/models/course_model.dart';
import 'package:admin_app/models/subject_model.dart';
import 'package:admin_app/models/all_subject_model.dart';
import 'package:admin_app/controllers/course_controller.dart';
import 'package:admin_app/controllers/all_subject_controller.dart';

class CoursesListPage extends StatefulWidget {
  const CoursesListPage({super.key});

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  final CourseController _courseController = CourseController();
  final AllSubjectController _subjectController = AllSubjectController();

  List<Course> _courses = [];
  List<AllSubjectModel> _allSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final courses = await _courseController.getCourses();
    final subjectsRaw = await _subjectController.getAllSubjects();
    setState(() {
      _courses = courses;
      _allSubjects = subjectsRaw;
    });
  }

  void _showEditCourseDialog(Course course) async {
    // Busca as disciplinas existentes do curso
    final currentSubjects = await _courseController.getCourseSubjects(
      course.id,
    );

    final TextEditingController nameController = TextEditingController(
      text: course.name,
    );
    final Map<int, Set<String>> selectedSubjectsPerYear = {
      1: Set<String>.from(currentSubjects[1] ?? []),
      2: Set<String>.from(currentSubjects[2] ?? []),
      3: Set<String>.from(currentSubjects[3] ?? []),
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: const Text(
                'Editar curso',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do curso',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white70,
                            indicatorColor: Colors.white,
                            tabs: [
                              Tab(text: '1º Ano'),
                              Tab(text: '2º Ano'),
                              Tab(text: '3º Ano'),
                            ],
                          ),
                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              children:
                                  [1, 2, 3].map((year) {
                                    return ListView(
                                      children:
                                          _allSubjects.map((subject) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                unselectedWidgetColor:
                                                    Colors.white70,
                                                checkboxTheme: CheckboxThemeData(
                                                  fillColor:
                                                      MaterialStateProperty.all(
                                                        const Color.fromARGB(
                                                          255,
                                                          59,
                                                          59,
                                                          59,
                                                        ),
                                                      ),
                                                  checkColor:
                                                      MaterialStateProperty.all(
                                                        Colors.white,
                                                      ),
                                                ),
                                              ),
                                              child: CheckboxListTile(
                                                title: Text(
                                                  subject.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                value:
                                                    selectedSubjectsPerYear[year]!
                                                        .contains(subject.name),
                                                onChanged: (selected) {
                                                  setStateDialog(() {
                                                    if (selected == true) {
                                                      selectedSubjectsPerYear[year]!
                                                          .add(subject.name);
                                                    } else {
                                                      selectedSubjectsPerYear[year]!
                                                          .remove(subject.name);
                                                    }
                                                  });
                                                },
                                                activeColor: Colors.blue,
                                                checkColor: Colors.white,
                                              ),
                                            );
                                          }).toList(),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Atualizar'),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final id = course.id; // Manter o mesmo ID
                    await _courseController.updateCourse(
                      id,
                      name,
                      selectedSubjectsPerYear,
                    );
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateCourseDialog() {
    final TextEditingController nameController = TextEditingController();
    final Map<int, Set<String>> selectedSubjectsPerYear = {1: {}, 2: {}, 3: {}};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: const Text(
                'Criar novo curso',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do curso',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white70,
                            indicatorColor: Colors.white,
                            tabs: [
                              Tab(text: '1º Ano'),
                              Tab(text: '2º Ano'),
                              Tab(text: '3º Ano'),
                            ],
                          ),
                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              children:
                                  [1, 2, 3].map((year) {
                                    return ListView(
                                      children:
                                          _allSubjects.map((subject) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                unselectedWidgetColor:
                                                    Colors.white70,
                                                checkboxTheme: CheckboxThemeData(
                                                  fillColor:
                                                      MaterialStateProperty.all(
                                                        const Color.fromARGB(
                                                          255,
                                                          59,
                                                          59,
                                                          59,
                                                        ),
                                                      ),
                                                  checkColor:
                                                      MaterialStateProperty.all(
                                                        Colors.white,
                                                      ),
                                                ),
                                              ),
                                              child: CheckboxListTile(
                                                title: Text(
                                                  subject.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                value:
                                                    selectedSubjectsPerYear[year]!
                                                        .contains(subject.name),
                                                onChanged: (selected) {
                                                  setStateDialog(() {
                                                    if (selected == true) {
                                                      selectedSubjectsPerYear[year]!
                                                          .add(subject.name);
                                                    } else {
                                                      selectedSubjectsPerYear[year]!
                                                          .remove(subject.name);
                                                    }
                                                  });
                                                },
                                                activeColor: Colors.blue,
                                                checkColor: Colors.white,
                                              ),
                                            );
                                          }).toList(),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salvar'),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final id = name.toLowerCase().replaceAll(' ', '_');
                    await _courseController.createCourse(
                      id,
                      name,
                      selectedSubjectsPerYear,
                    );
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Cursos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return Card(
            color: Colors.grey.shade900,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                course.name,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditCourseDialog(course),
                    tooltip: 'Editar curso',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await _courseController.deleteCourse(
                        course.name.toLowerCase().replaceAll(' ', '_'),
                      );
                      _loadData();
                    },
                    tooltip: 'Apagar curso',
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: _showCreateCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
