import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double _bmi = 0.0;
  int _height = 0; // Editable height
  double _weight = 0.0;
  int _workouts = 34;
  int _calories = 7218;
  int _minutes = 348;

  // This function handles editing BMI and height
  void _editBMI() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double? tempWeight = _weight;
        int? tempHeight = _height;

        return AlertDialog(
          title: Text('Edit Height and Weight'),
          content: SingleChildScrollView( // This allows content to be scrollable if overflow occurs
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevents the column from taking unnecessary space
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  // This function returns the BMI status based on the BMI value
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Overview
            _buildReportOverview(),

            SizedBox(height: 25),

            // History Section
            _buildHistorySection(),

            SizedBox(height: 25),

            // BMI Section
            _buildBMISection(),
          ],
        ),
      ),
    );
  }

  // Report Overview Widget
  Widget _buildReportOverview() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem(Icons.fitness_center, _workouts, 'Workouts'),
            _buildStatItem(Icons.local_fire_department, _calories, 'Kcal'),
            _buildStatItem(Icons.timer, _minutes, 'Minutes'),
          ],
        ),
      ),

    );
  }



  // Single Stat Item
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

  // History Section
// History Section
  Widget _buildHistorySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 2), // Optional for shadow direction
          ),
        ],
      ),
      padding: EdgeInsets.all(16), // Optional padding inside the container
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to detailed history page
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
          ),
        ],
      ),
    );
  }


  // BMI Section
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
                _getBMIStatus(), // Display BMI status next to BMI number
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

  // BMI Scale
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
            left: _getBMIPointerPosition(),
            child: Icon(Icons.arrow_drop_down, color: Colors.black),
          ),
        ],
      ),
    );
  }

  double _getBMIPointerPosition() {
    // Assuming scale from 15 to 40
    double minBMI = 15.0;
    double maxBMI = 40.0;
    double range = maxBMI - minBMI;
    double scaleWidth = 300.0; // Assuming a fixed width for the scale

    return ((_bmi - minBMI) / range) * scaleWidth;
  }
}
