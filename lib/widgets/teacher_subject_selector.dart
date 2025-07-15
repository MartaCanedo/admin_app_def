import 'package:flutter/material.dart';

class TeacherSubjectSelector extends StatelessWidget {
  final List<String> allSubjects;
  final List<String> selectedSubjects;
  final Function(String) onSubjectSelected;
  const TeacherSubjectSelector({
    super.key,
    required this.allSubjects,
    required this.selectedSubjects,
    required this.onSubjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: 350, maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Selecione as disciplinas',
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
                      allSubjects.map((subject) {
                        final alreadySelected = selectedSubjects.contains(
                          subject,
                        );
                        return ListTile(
                          title: Text(
                            subject,
                            style: TextStyle(
                              color:
                                  alreadySelected ? Colors.red : Colors.white,
                              fontWeight:
                                  alreadySelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          trailing:
                              alreadySelected
                                  ? Icon(Icons.check, color: Colors.red)
                                  : null,
                          onTap: () => onSubjectSelected(subject),
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
