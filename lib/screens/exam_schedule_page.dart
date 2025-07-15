import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/course_controller.dart';
import '../controllers/subject_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamSchedulePage extends StatefulWidget {
  const ExamSchedulePage({super.key});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  Map<String, dynamic> courseData = {};
  bool isLoading = true;
  Map<String, Map<String, dynamic>> subjectExams = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final controllerCourse = CourseController();
    final courses = await controllerCourse.getCourses();
    final result = <String, Map<int, List<Map<String, dynamic>>>>{};

    subjectExams.clear(); // Clear before loading

    for (final course in courses) {
      final courseId = course.id;
      final subjects = await SubjectController.getSubjectsByCourse(courseId);
      for (final entry in subjects.entries) {
        final year = entry.key;
        final subjectList = entry.value;

        result[courseId] ??= {};
        result[courseId]![year] ??= [];

        for (final subj in subjectList) {
          result[courseId]![year]!.add(subj);
        }
      }
    }

    // Fetch exam schedules from Firestore
    final examSnapshot = await FirebaseFirestore.instance.collection('exam_schedules').get();
    for (final doc in examSnapshot.docs) {
      final data = doc.data();
      final subjectId = data['subjectId'];
      if (subjectId != null) {
  final Map<String, dynamic> exams = {};

  for (final entry in data.entries) {
    if (entry.key.startsWith('exams.') && entry.value != null) {
      final season = entry.key.split('exams.').last;
      exams[season] = entry.value;
    }
  }

  subjectExams[subjectId] = exams;
}
    }

    setState(() {
      courseData = result;
      isLoading = false;
    });
  }

  Future<void> pickDate(String courseId, String subjectId, String season) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );

    if (picked == null) return;

    final existingExams = subjectExams[subjectId] ?? {};
    final normal = existingExams['Época Normal'] != null
        ? DateTime.parse(existingExams['Época Normal'])
        : null;
    final recurso = existingExams['Recurso'] != null
        ? DateTime.parse(existingExams['Recurso'])
        : null;

    if (season == 'Recurso') {
      if (normal == null) {
        _showError('É necessário marcar a Época Normal antes.');
        return;
      }
      if (!picked.isAfter(normal)) {
        _showError('A data de Recurso deve ser após a Época Normal.');
        return;
      }
    }

    if (season == 'Época Especial') {
      if (normal == null) {
        _showError('Marque primeiro a Época Normal.');
        return;
      }
      if (recurso == null) {
        _showError('Marque primeiro a data de Recurso.');
        return;
      }
      if (!picked.isAfter(recurso)) {
        _showError('A data de Época Especial deve ser após o Recurso.');
        return;
      }
    }

    await FirebaseFirestore.instance
        .collection('exam_schedules')
        .doc('${courseId}_$subjectId')
        .set({
      'courseId': courseId,
      'subjectId': subjectId,
      'exams.$season': picked.toIso8601String(),
    }, SetOptions(merge: true));

    // Atualiza localmente
    setState(() {
      subjectExams[subjectId] ??= {};
      subjectExams[subjectId]![season] = picked.toIso8601String();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data de $season atualizada com sucesso!')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget buildExamTile(String courseId, Map<String, dynamic> subject) {
    final subjectName = subject['name'] ?? 'Sem nome';
    final subjectId = subject['id'];
    final exams = subjectExams[subjectId] ?? {};
    //print('EXAMES >>>>>> $subjectExams');
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ExpansionTile(
        title: Text(subjectName, style: TextStyle(color: Colors.white)),
        children: ['Época Normal', 'Recurso', 'Época Especial'].map((season) {
          final iso = exams[season];
          String displayDate = iso != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(iso))
              : 'Não marcada';

          return ListTile(
            title: Text(season, style: TextStyle(color: Colors.white)),
            subtitle:
                Text(displayDate, style: TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.orange),
              onPressed: () => pickDate(courseId, subjectId, season),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        title:
            Text('Marcação de Exames', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: courseData.entries.map((courseEntry) {
                final courseId = courseEntry.key;
                final years = courseEntry.value
                    as Map<int, List<Map<String, dynamic>>>;

  final sortedYears = years.entries.toList()
  ..sort((a, b) => a.key.compareTo(b.key)); // Ordenar por ano (1, 2, 3)

                return ExpansionTile(
                  title: Text(
                    courseId.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  children: sortedYears.map((yearEntry) {
                    return ExpansionTile(
                      title: Text('${yearEntry.key}º Ano', style: TextStyle(color: Colors.white)),
                      children: yearEntry.value
                          .map((subject) => buildExamTile(courseId, subject))
                          .toList(),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}
