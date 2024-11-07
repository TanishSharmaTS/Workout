import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'history_page.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Future<void> _loadUserDataFuture;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> completedWorkoutDates = {};
  double _bmi = 0.0;
  int _height = 0; // Editable height
  double _weight = 0.0;
  int _workouts = 34;
  int _calories = 7218;
  int _minutes = 348;

  @override
  void initState() {
    super.initState();
    _loadUserDataFuture = _loadUserData();

    // Load exact completed workout dates without setting state
    _loadCompletedWorkoutDates().then((dates) {
      completedWorkoutDates = dates;
    });
  }

// Helper function to normalize dates
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<Set<DateTime>> _loadCompletedWorkoutDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> workoutCompletionStrings = prefs.getStringList('workoutCompletions') ?? [];

    // Parse each date string, normalize, and add it to a set
    return workoutCompletionStrings.map((item) {
      var completion = jsonDecode(item);
      return _normalizeDate(DateTime.parse(completion['completionDate']));
    }).toSet();
  }

  // This function handles editing BMI and height
  void _editBMI() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double? tempWeight = _weight;
        int? tempHeight = _height;

        return AlertDialog(
          title: Text('Edit Height and Weight'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    tempHeight = int.tryParse(value);
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Weight (kgs)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    tempWeight = double.tryParse(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  if (tempWeight != null) _weight = tempWeight!;
                  if (tempHeight != null) _height = tempHeight!;
                  _calculateBMI(_height, _weight);
                });
                _saveUserData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _height = prefs.getInt('height') ?? 0;
      _weight = prefs.getDouble('weight') ?? 0.0;
      _calculateBMI(_height, _weight);
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('height', _height);
    await prefs.setDouble('weight', _weight);
  }

  void _calculateBMI(int height, double weight) {
    if (height > 0 && weight > 0) {
      setState(() {
        _bmi = double.parse((weight / ((height / 100) * (height / 100))).toStringAsFixed(1));
      });
    } else {
      setState(() {
        _bmi = 0.0;
      });
    }
  }

  String _getBMIStatus() {
    if (_bmi < 18.5) {
      return 'Underweight';
    } else if (_bmi < 25) {
      return 'Healthy weight';
    } else if (_bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obesity';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REPORT'),
      ),
      body: FutureBuilder<void>(
        future: _loadUserDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Once data is loaded, display the main content
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportOverview(),
                  SizedBox(height: 25),
                  _buildHistorySection(),
                  SizedBox(height: 25),
                  _buildBMISection(),
                ],
              ),
            );
          }
        },
      ),
    );
  }




  Widget _buildReportOverview() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(Icons.fitness_center, _workouts, 'Workouts'),
          _buildStatItem(Icons.local_fire_department, _calories, 'Kcal'),
          _buildStatItem(Icons.timer, _minutes, 'Minutes'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int value, String label) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.black54),
        SizedBox(height: 10),
        Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(label),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage()),
                  );
                },
                child: Text('All records'),
              ),
            ],
          ),
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerVisible: false,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (completedWorkoutDates.contains(_normalizeDate(day))) {
                  print(day);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green, // Custom color for completed dates
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return null; // Use the default styling for other dates
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBMISection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BMI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '$_bmi',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text(
                _getBMIStatus(),
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildBMIScale(),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Height: $_height cm', style: TextStyle(fontSize: 16)),
              Text('Weight: $_weight kg', style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey),
                onPressed: _editBMI,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMIScale() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
          stops: [0.25, 0.5, 0.75, 1.0],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            left: _getBMIPointerPosition(context),
            child: Icon(Icons.arrow_drop_down, color: Colors.black),
          ),
        ],
      ),
    );
  }

  double _getBMIPointerPosition(BuildContext context) {
    double scaleWidth = MediaQuery.of(context).size.width - 64; // Padding
    double minBMI = 15.0;
    double maxBMI = 40.0;
    return ((scaleWidth * (_bmi - minBMI)) / (maxBMI - minBMI)).clamp(0.0, scaleWidth - 20.0);
  }
}
