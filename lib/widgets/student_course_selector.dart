import 'package:flutter/material.dart';

class StudentCourseSelector extends StatelessWidget {
  final List<String> allCourses;
  final String? selectedCourse;
  final Function(String) onCourseSelected;
  final String? errorText;
  const StudentCourseSelector({
    super.key,
    required this.allCourses,
    required this.selectedCourse,
    required this.onCourseSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Selecione o curso',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Divider(color: Colors.white24, height: 1),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children:
                      allCourses.map((course) {
                        final isSelected = selectedCourse == course;
                        return ListTile(
                          title: Text(
                            course,
                            style: TextStyle(
                              color: isSelected ? Colors.red : Colors.white,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? Icon(Icons.check, color: Colors.red)
                                  : null,
                          onTap: () => onCourseSelected(course),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
