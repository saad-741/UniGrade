import 'package:flutter/material.dart';

import '../models/academic_models.dart';
import 'gpa_result_screen.dart';

class GpaCalculatorScreen extends StatefulWidget {

  final bool returnResultToCaller;

  const GpaCalculatorScreen({
    super.key,
    this.returnResultToCaller = false,
  });

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 1;
  int _subjectCount = 3;

  final List<TextEditingController> _marksControllers = [];
  final List<double> _selectedCredits = [];

  void _generateFields() {
    for (final controller in _marksControllers) {
      controller.dispose();
    }

    _marksControllers.clear();
    _selectedCredits.clear();

    for (int i = 0; i < _subjectCount; i++) {
      _marksControllers.add(TextEditingController());

      _selectedCredits.add(3.0);
    }

    setState(() {
      _currentStep = 2;
    });
  }

  // Calculate GPA

  void _onCalculatePressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final List<Subject> subjects = [];

    for (int i = 0; i < _subjectCount; i++) {
      final marks = double.parse(_marksControllers[i].text.trim());

      final credits = _selectedCredits[i];

      subjects.add(
        Subject(
          name: 'Subject ${i + 1}',
          marks: marks,
          creditHours: credits,
        ),
      );
    }

    final result = SemesterResult(
      subjects: subjects,
    );
 

    if (widget.returnResultToCaller) {
      Navigator.pop(context, result);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GpaResultScreen(
          result: result,
        ),
      ),
    );
  }
 

  @override
  void dispose() {
    for (final controller in _marksControllers) {
      controller.dispose();
    }

    super.dispose();
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator'),
      ),
      body: _currentStep == 1
          ? _buildStepOne()
          : _buildStepTwo(),
    );
  }
 

  Widget _buildStepOne() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Number of Subjects',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          const Text(
            'Choose how many subjects you have.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _subjectCount > 1
                    ? () {
                        setState(() {
                          _subjectCount--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Text(
                  '$_subjectCount',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton.filledTonal(
                onPressed: _subjectCount < 10
                    ? () {
                        setState(() {
                          _subjectCount++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 35),

          ElevatedButton(
            onPressed: _generateFields,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 14,
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
 

  Widget _buildStepTwo() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Enter Subject Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Marks are out of 100.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subjectCount,
            itemBuilder: (context, index) {
              return _buildSubjectCard(index);
            },
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: _onCalculatePressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
            ),
            child: const Text(
              'Calculate GPA',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
 

  Widget _buildSubjectCard(int index) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 

                Expanded(
                  child: TextFormField(
                    controller: _marksControllers[index],
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Marks',
                      hintText: '0 - 100',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter marks';
                      }

                      final marks =
                          double.tryParse(value.trim());

                      if (marks == null) {
                        return 'Invalid marks';
                      }

                      if (marks < 0 || marks > 100) {
                        return 'Must be 0-100';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),
 

                Expanded(
                  child: DropdownButtonFormField<double>(
                    initialValue:
                        _selectedCredits[index],
                    decoration: const InputDecoration(
                      labelText: 'Credit Hours',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      0.5,
                      1.0,
                      2.0,
                      3.0,
                    ].map(
                      (value) {
                        return DropdownMenuItem<double>(
                          value: value,
                          child: Text(
                            value % 1 == 0
                                ? '${value.toInt()} CH'
                                : '$value CH',
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedCredits[index] =
                            value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
 