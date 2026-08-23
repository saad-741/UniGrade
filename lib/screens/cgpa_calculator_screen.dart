import 'package:flutter/material.dart';

import '../models/academic_models.dart';
import 'gpa_calculator_screen.dart';

class CgpaCalculatorScreen extends StatefulWidget {
  const CgpaCalculatorScreen({super.key});

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
 
  int _currentStep = 1;

  int _semesterCount = 4;

  List<SemesterData> _semesters = [];
 
  int? _editingSemesterIndex;

  final TextEditingController _gpaController = TextEditingController();

  final TextEditingController _creditController = TextEditingController();

  final GlobalKey<FormState> _manualGpaFormKey = GlobalKey<FormState>();


  void _generateSemesters() {
    _closeManualEditor();

    setState(() {
      _semesters = List.generate(
        _semesterCount,
        (index) => SemesterData(name: 'Semester ${index + 1}'),
      );

      _currentStep = 2;
    });
  } 

  void _openEnterGpaEditor(int index) {
    final semester = _semesters[index];

    _gpaController.text = semester.gpa?.toString() ?? '';

    _creditController.text = semester.creditHours?.toString() ?? '';

    setState(() {
      _editingSemesterIndex = index;
    });
  }


  void _closeManualEditor() {
    _editingSemesterIndex = null;

    _gpaController.clear();
    _creditController.clear();
  }

  void _saveManualGpa() {
    if (_editingSemesterIndex == null) {
      return;
    }

    if (!_manualGpaFormKey.currentState!.validate()) {
      return;
    }

    final index = _editingSemesterIndex!;

    final gpa = double.parse(_gpaController.text.trim());

    final credits = double.parse(_creditController.text.trim());

    setState(() {
      _semesters[index].gpa = gpa;
      _semesters[index].creditHours = credits;

      _editingSemesterIndex = null;

      _gpaController.clear();
      _creditController.clear();
    });
  }


  void _cancelManualGpa() {
    setState(() {
      _editingSemesterIndex = null;

      _gpaController.clear();
      _creditController.clear();
    });
  }


  Future<void> _navigateToGpaCalculator(int index) async {
    if (_editingSemesterIndex != null) {
      _cancelManualGpa();
    }

    final result = await Navigator.push<SemesterResult>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const GpaCalculatorScreen(returnResultToCaller: true),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _semesters[index].gpa = result.gpa;
      _semesters[index].creditHours = result.totalCredits;
    });
  }
 

  bool get _allSemestersReady {
    return _semesters.isNotEmpty &&
        _semesters.every((semester) => semester.hasData);
  } 

  @override
  void dispose() {
    _gpaController.dispose();
    _creditController.dispose();

    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CGPA Calculator')),

      body: _currentStep == 1 ? _buildStepOne() : _buildStepTwo(),
    );
  }

  Widget _buildStepOne() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Number of Semesters',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          const Text(
            'Choose how many semesters you want to calculate.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _semesterCount > 1
                    ? () {
                        setState(() {
                          _semesterCount--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  '$_semesterCount',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton.filledTonal(
                onPressed: _semesterCount < 12
                    ? () {
                        setState(() {
                          _semesterCount++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 35),

          ElevatedButton(
            onPressed: _generateSemesters,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStepTwo() {
    final cgpaResult = CgpaResult(semesters: _semesters);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Enter information for each semester',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        const Text(
          'Enter the GPA directly or calculate it from subjects.',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _semesters.length,
          itemBuilder: (context, index) {
            return _buildSemesterCard(index);
          },
        ),

        const SizedBox(height: 8),

        if (_allSemestersReady)
          _buildCgpaResultCard(cgpaResult)
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Complete all semesters to calculate your CGPA.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  // SEMESTER CARD

  Widget _buildSemesterCard(int index) {
    final semester = _semesters[index];

    final isEditing = _editingSemesterIndex == index;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  semester.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (semester.hasData)
                  Chip(label: Text('GPA ${semester.gpa!.toStringAsFixed(2)}'))
                else
                  const Text(
                    'Not completed',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
              ],
            ),

            const SizedBox(height: 10),
 
            if (isEditing)
              _buildManualGpaEditor(index)
            else
              _buildSemesterButtons(index),
 
            if (semester.hasData && !isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Credit Hours: '
                  '${_formatCredits(semester.creditHours!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // SEMESTER BUTTONS

  Widget _buildSemesterButtons(int index) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _openEnterGpaEditor(index);
            },
            child: Text(_semesters[index].hasData ? 'Edit GPA' : 'Enter GPA'),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _navigateToGpaCalculator(index);
            },
            child: const Text('Calculate GPA'),
          ),
        ),
      ],
    );
  }

  // MANUAL GPA EDITOR

  Widget _buildManualGpaEditor(int index) {
    return Form(
      key: _manualGpaFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter Semester GPA',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 12),
 
          TextFormField(
            controller: _gpaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'GPA',
              hintText: '0.00 - 4.00',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter GPA';
              }

              final gpa = double.tryParse(value.trim());

              if (gpa == null) {
                return 'Invalid GPA';
              }

              if (gpa < 0 || gpa > 4) {
                return 'GPA must be 0.00 - 4.00';
              }

              return null;
            },
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _creditController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Total Credit Hours',
              hintText: 'e.g. 15, 16, 18',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter credit hours';
              }

              final credits = double.tryParse(value.trim());

              if (credits == null || credits <= 0) {
                return 'Enter valid credit hours';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelManualGpa,
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: _saveManualGpa,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CGPA RESULT CARD

  Widget _buildCgpaResultCard(CgpaResult result) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Your CGPA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 8),

            // CGPA
            Text(
              result.cgpa.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 4),

            // Grade
            Text(
              'Grade: ${result.letterGrade}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const Divider(height: 30),

            // Total Credits
            Text(
              'Total Credit Hours: '
              '${_formatCredits(result.totalCredits)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

 
  String _formatCredits(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}

 