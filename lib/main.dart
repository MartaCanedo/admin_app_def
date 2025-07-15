import 'package:admin_app/data/seeding_service.dart';
import 'package:admin_app/screens/exam_schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/add_student_page.dart';
import 'screens/add_teacher_page.dart';
import 'screens/create_announcement_page.dart';
import 'screens/admin_home_page.dart';
import 'screens/admin_login_page.dart';
import 'screens/teacher_detail_page.dart';
import 'screens/horario_list_page.dart';
import 'screens/subject_list_page.dart';
import 'screens/courses_list_page.dart';

import 'dart:io';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDq9RHvJCE0Fv0KGl2M3v9nP39ri_YiTLk",
      authDomain: "campus-link-def.firebaseapp.com",
      projectId: "campus-link-def",
      storageBucket: "campus-link-def.firebasestorage.app",
      messagingSenderId: "821984532953",
      appId: "1:821984532953:web:166c5b12a2a85e019421c8",
      measurementId: "G-0W8N9BZWJD",
    ),
  );

  // Rodar o seeding apenas uma vez
  await runSeedingIfNeeded();

  setWindowMinSize(const Size(1200, 800));
  runApp(const AdminApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true; // ACEITA TODOS os certificados SSL (DEV ONLY)
      };
  }
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AdminLoginPage(),
        '/home': (context) => const AdminHomePage(),
        '/create_announcement': (context) => const CreateAnnouncementPage(),
        '/add_student': (context) => const AddStudentPage(),
        '/add_teacher': (context) => const AddTeacherPage(),
        '/horario_list': (context) =>  HorarioListPageState(),
        '/disciplinas': (context) =>  DisciplinasPage(),
        '/cursos': (context) =>  CoursesListPage(),
        '/exam_schedule': (context) => const ExamSchedulePage(),
        '/teacher_detail': (context) {
          final teacherId =
              ModalRoute.of(context)!.settings.arguments as String;
          return TeacherDetailPage(
            teacherId: teacherId,
            onEdit: () {},
            onDelete: () {},
          );
        },
      },
    );
  }
  
}
