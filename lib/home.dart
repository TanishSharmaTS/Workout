import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'workout_details.dart';
import 'workout_category.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<WorkoutCategory> workoutCategories = [
    WorkoutCategory(
      categoryName: 'Upper Body',
      workoutType: 'upper_body_workout',
      numberOfExercises: 10,
      estimatedTime: '30 mins',
      imagePath: 'assets/upper_body.png'
    ),
    WorkoutCategory(
      categoryName: 'Lower Body',
      workoutType: 'lower_body_workout',
      numberOfExercises: 12,
      estimatedTime: '35 mins',
        imagePath: 'assets/lower_body.png'

    ),
    WorkoutCategory(
      categoryName: 'Full Body',
      workoutType: 'full_body_workout',
      numberOfExercises: 15,
      estimatedTime: '45 mins',
        imagePath: 'assets/full_body.png'

    ),
    WorkoutCategory(
        categoryName: 'Arms',
        workoutType: 'full_body_workout',
        numberOfExercises: 15,
        estimatedTime: '45 mins',
        imagePath: 'assets/arms.png'

    ),
    WorkoutCategory(
        categoryName: 'Back',
        workoutType: 'full_body_workout',
        numberOfExercises: 15,
        estimatedTime: '45 mins',
        imagePath: 'assets/back.png'

    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Out'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add search action here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar

            SizedBox(height: 20),
            // Calendar widget (showing current week)
            Text(
              'This Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              headerVisible: false, // Hides month and year at the top
            ),
            SizedBox(height: 20),
            // Exercise categories
            Text(
              'Exercise Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true, // Ensures the ListView takes only as much height as needed
                itemCount: workoutCategories.length,
                itemBuilder: (context, index) {
                  return _buildWorkoutCard(context, workoutCategories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Workout card widget
  Widget _buildWorkoutCard(BuildContext context, WorkoutCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailPage(workoutType: category.workoutType),
          ),
        );      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10), // Reduced horizontal margin for full width
        width: double.infinity, // Full width
        height: 150, // Increased height for a better layout
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(category.imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.categoryName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '${category.numberOfExercises} exercises • ${category.estimatedTime}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





