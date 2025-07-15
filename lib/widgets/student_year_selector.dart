import 'package:flutter/material.dart';

class StudentYearSelector extends StatelessWidget {
  final int? selectedYear;
  final List<int> availableYears;
  final Function(int) onYearSelected;
  final String? errorText;
  const StudentYearSelector({
    super.key,
    required this.selectedYear,
    required this.availableYears,
    required this.onYearSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          height: 240,
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
                  'Selecione o ano',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Divider(color: Colors.white24, height: 1),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children:
                      availableYears.map((year) {
                        final isSelected = selectedYear == year;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          minVerticalPadding: 0,
                          title: Text(
                            'Ano $year',
                            style: TextStyle(
                              color: isSelected ? Colors.red : Colors.white,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? Icon(
                                    Icons.check,
                                    color: Colors.red,
                                    size: 18,
                                  )
                                  : null,
                          onTap: () => onYearSelected(year),
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
