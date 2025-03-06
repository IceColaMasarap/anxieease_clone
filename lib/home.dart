import 'package:flutter/material.dart';
import 'watch.dart';
import 'profile.dart';
import 'search.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'breathing_screen.dart';
import 'calendar_screen.dart';
import 'metrics.dart';
import 'settings.dart';

class Task {
  final String id;
  final String title;
  final DateTime dateTime;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      isCompleted: json['isCompleted'],
    );
  }

  bool get isExpired => DateTime.now().isAfter(dateTime) && !isCompleted;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class StressLabel extends StatelessWidget {
  final String label;
  final String range;

  const StressLabel({super.key, required this.label, required this.range});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          range,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  static const String TASKS_KEY = 'tasks';
  late double screenWidth;
  late double screenHeight;
  int _selectedIndex = 0;
  final List<String> moods = [
    'Happy',
    'Fearful',
    'Excited',
    'Angry',
    'Calm',
    'Pain',
    'Boredom',
    'Sad',
    'Awe',
    'Confused',
    'Anxious',
    'Relief',
    'Satisfied'
  ];
  final Set<String> selectedMoods = {};
  double stressLevel = 3;
  final Map<String, bool> symptoms = {
    'Rapid heartbeat': false,
    'Shortness of breath': false,
    'Dizziness': false,
    'Headache': false,
    'Fatigue': false,
    'Sweating': false,
    'Muscle tension': false,
    'Nausea': false,
    'Shaking or trembling': false,
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FE),
      body: HomeContent(),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, {String? date}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icon,
                  color: Colors.grey[800],
                  size: 24,
                ),
              ),
              if (date != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildFeelingCard(
      String title, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: iconColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for today',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new task',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(task.dateTime),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color:
                      task.isCompleted ? Colors.green[700] : Colors.grey[400],
                ),
                onPressed: () => _toggleTaskCompletion(task),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red[300],
                ),
                onPressed: () => _removeTask(task),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(TASKS_KEY);

    if (tasksJson != null) {
      setState(() {
        final List<dynamic> decodedTasks = jsonDecode(tasksJson);
        tasks = decodedTasks.map((task) => Task.fromJson(task)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson =
        jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(TASKS_KEY, tasksJson);
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      _saveTasks();
    });
  }

  void _removeTask(Task task) {
    setState(() {
      tasks.removeWhere((t) => t.id == task.id);
      _saveTasks();
    });
  }

  void _showDateTimePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      if (selectedDate != null) {
        // Show time picker after date is selected
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          if (selectedTime != null) {
            _showAddTaskDialog(selectedDate, selectedTime);
          }
        });
      }
    });
  }

  void _showAddTaskDialog(DateTime date, TimeOfDay time) {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                hintText: 'Enter your task here',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Date: ${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Time: ${time.format(context)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                final DateTime taskDateTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );

                _addTask(Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: taskController.text,
                  dateTime: taskDateTime,
                  isCompleted: false,
                ));

                Navigator.pop(context);
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  void _showBreathingExercises() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BreathingScreen()),
    );
  }

  void _showMoodTracker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A90E2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.mood,
                                color: Color(0xFF4A90E2),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'How are you feeling?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: moods.length,
                      itemBuilder: (context, index) {
                        final mood = moods[index];
                        final isSelected = selectedMoods.contains(mood);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedMoods.remove(mood);
                              } else {
                                selectedMoods.add(mood);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4A90E2).withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4A90E2)
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getMoodIcon(mood),
                                  color: isSelected
                                      ? const Color(0xFF4A90E2)
                                      : Colors.grey[600],
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mood,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF4A90E2)
                                        : Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Save selected moods
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Mood',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'fearful':
        return Icons.sentiment_very_dissatisfied;
      case 'excited':
        return Icons.mood;
      case 'angry':
        return Icons.mood_bad;
      case 'calm':
        return Icons.sentiment_satisfied;
      case 'pain':
        return Icons.healing;
      case 'boredom':
        return Icons.sentiment_neutral;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'awe':
        return Icons.star;
      case 'confused':
        return Icons.psychology;
      case 'anxious':
        return Icons.warning;
      case 'relief':
        return Icons.spa;
      case 'satisfied':
        return Icons.thumb_up;
      default:
        return Icons.mood;
    }
  }

  void _showStressTracker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Color getStressColor(double value) {
              return Colors.teal[700]!;
            }

            String getStressLabel(double value) {
              if (value <= 3) return 'Low Stress';
              if (value <= 6) return 'Moderate Stress';
              return 'High Stress';
            }

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Stress Level',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getStressColor(stressLevel).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getStressLabel(stressLevel),
                          style: TextStyle(
                            color: getStressColor(stressLevel),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'How stressed are you feeling right now?',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StressLabel(label: 'Not at all', range: '0-3'),
                      StressLabel(label: 'Moderate', range: '4-6'),
                      StressLabel(label: 'Extreme', range: '7-10'),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: getStressColor(stressLevel),
                      inactiveTrackColor:
                          getStressColor(stressLevel).withOpacity(0.2),
                      thumbColor: getStressColor(stressLevel),
                      overlayColor:
                          getStressColor(stressLevel).withOpacity(0.2),
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,
                      ),
                    ),
                    child: Slider(
                      value: stressLevel,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      onChanged: (double value) {
                        setState(() {
                          stressLevel = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      stressLevel.toInt().toString(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: getStressColor(stressLevel),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save stress level
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Stress Level',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPhysicalSymptomsTracker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF50E3C2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.healing,
                                color: Color(0xFF50E3C2),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Physical Symptoms',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: symptoms.length,
                      itemBuilder: (context, index) {
                        final symptom = symptoms.keys.elementAt(index);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: symptoms[symptom]!
                                ? const Color(0xFF50E3C2).withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: symptoms[symptom]!
                                  ? const Color(0xFF50E3C2)
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                symptoms[symptom] = !symptoms[symptom]!;
                              });
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: symptoms[symptom]!
                                    ? const Color(0xFF50E3C2).withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getSymptomIcon(symptom),
                                color: symptoms[symptom]!
                                    ? const Color(0xFF50E3C2)
                                    : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              symptom,
                              style: TextStyle(
                                color: symptoms[symptom]!
                                    ? const Color(0xFF2C3E50)
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: symptoms[symptom]!
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF50E3C2),
                                  )
                                : Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey[400],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Save symptoms
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Symptoms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getSymptomIcon(String symptom) {
    switch (symptom.toLowerCase()) {
      case 'rapid heartbeat':
        return Icons.favorite;
      case 'shortness of breath':
        return Icons.air;
      case 'dizziness':
        return Icons.motion_photos_on;
      case 'headache':
        return Icons.sick;
      case 'fatigue':
        return Icons.battery_alert;
      case 'sweating':
        return Icons.water_drop;
      case 'muscle tension':
        return Icons.fitness_center;
      case 'nausea':
        return Icons.sick_outlined;
      case 'shaking or trembling':
        return Icons.vibration;
      default:
        return Icons.healing;
    }
  }

  void _showActivitiesTracker() {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Exercise',
        'icon': Icons.directions_run,
        'color': const Color(0xFF9013FE),
        'duration': '30 min',
        'completed': false,
      },
      {
        'title': 'Meditation',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF9013FE),
        'duration': '15 min',
        'completed': false,
      },
      {
        'title': 'Reading',
        'icon': Icons.book,
        'color': const Color(0xFF9013FE),
        'duration': '20 min',
        'completed': false,
      },
      {
        'title': 'Journaling',
        'icon': Icons.edit,
        'color': const Color(0xFF9013FE),
        'duration': '10 min',
        'completed': false,
      },
      {
        'title': 'Walking',
        'icon': Icons.directions_walk,
        'color': const Color(0xFF9013FE),
        'duration': '45 min',
        'completed': false,
      },
      {
        'title': 'Medication',
        'icon': Icons.medication,
        'color': const Color(0xFF9013FE),
        'duration': '5 min',
        'completed': false,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9013FE).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.directions_run,
                                color: Color(0xFF9013FE),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Daily Activities',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: activity['completed']
                                ? const Color(0xFF9013FE).withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: activity['completed']
                                  ? const Color(0xFF9013FE)
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                activity['completed'] = !activity['completed'];
                              });
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: activity['completed']
                                    ? const Color(0xFF9013FE).withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                activity['icon'] as IconData,
                                color: activity['completed']
                                    ? const Color(0xFF9013FE)
                                    : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              activity['title'] as String,
                              style: TextStyle(
                                color: activity['completed']
                                    ? const Color(0xFF2C3E50)
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              activity['duration'] as String,
                              style: TextStyle(
                                color: activity['completed']
                                    ? const Color(0xFF9013FE)
                                    : Colors.grey[500],
                              ),
                            ),
                            trailing: activity['completed']
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF9013FE),
                                  )
                                : Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey[400],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Save activities
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Activities',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${TimeOfDay.fromDateTime(dateTime).format(context)}';
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      _saveTasks();
    });
  }

  // New Notifications Section
  Widget _buildNotificationsSection() {
    // Sample notifications - replace with actual notifications from wearable
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'High Heart Rate Detected',
        'message': 'Your heart rate was above normal at 120 BPM',
        'time': '2 min ago',
        'type': 'warning',
        'icon': Icons.favorite,
      },
      {
        'title': 'Stress Level Alert',
        'message': 'Elevated stress levels detected. Consider taking a break.',
        'time': '15 min ago',
        'type': 'alert',
        'icon': Icons.warning_amber,
      },
      {
        'title': 'Movement Pattern Change',
        'message': 'Unusual movement patterns detected. Are you feeling okay?',
        'time': '1 hour ago',
        'type': 'info',
        'icon': Icons.directions_walk,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.teal[700],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E2432),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(
              title: notification['title'],
              message: notification['message'],
              time: notification['time'],
              type: notification['type'],
              icon: notification['icon'],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required String time,
    required String type,
    required IconData icon,
  }) {
    Color getTypeColor() {
      switch (type) {
        case 'warning':
          return Colors.orange;
        case 'alert':
          return Colors.red;
        case 'info':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: getTypeColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E2432),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingCard() {
    return GestureDetector(
      onTap: _showBreathingExercises,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green[400]!,
              Colors.green[300]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                    child: Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Breathing Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Reduce anxiety with guided breathing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.air,
                color: Colors.white,
                size: screenWidth * 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.person_outline,
        'title': 'Profile',
        'color': const Color(0xFF00634A),
        'screen': const ProfilePage(),
      },
      {
        'icon': Icons.watch_outlined,
        'title': 'Watch',
        'color': const Color(0xFF3EAD7A),
        'screen': const WatchScreen(),
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Calendar',
        'color': const Color(0xFF3EAD7A),
        'screen': const CalendarScreen(),
      },
      {
        'icon': Icons.navigation,
        'title': 'Clinics',
        'color': const Color(0xFF3EAD7A),
        'screen': const SearchScreen(),
      },
    ];

    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.from(actions.map((action) => 
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildActionCard(
                icon: action['icon'],
                title: action['title'],
                color: action['color'],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => action['screen'],
                  ),
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isCalendar = title == 'Calendar';
    final now = DateTime.now();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              isCalendar
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getMonthAbbreviation(now.month).toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${now.day}',
                          style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 22,
                      ),
                    ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1E2432),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();

    return SafeArea(
      child: Column(
        children: [
          // App Bar with Profile
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.03,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello Mejia',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E2432),
                      ),
                    ),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: const Color(0xFF7C8495),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: screenWidth * 0.055,
                    backgroundColor: Colors.teal[50],
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.teal[700],
                      size: screenWidth * 0.055,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: homeState?._buildBreathingCard(),
                  ),
                ),

                // Quick Actions Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.teal[700],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E2432),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        homeState?._buildQuickActionsGrid() ?? Container(),
                      ],
                    ),
                  ),
                ),

                // Tasks Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.teal[700],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Today\'s Tasks',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E2432),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => homeState?._showDateTimePicker(),
                          icon: Icon(Icons.add, size: 20, color: Colors.teal[700]),
                          label: Text(
                            'Add Task',
                            style: TextStyle(color: Colors.teal[700]),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.teal[50],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tasks List
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  sliver: homeState?.tasks.isEmpty ?? true
                      ? SliverToBoxAdapter(
                          child: homeState?._buildEmptyTasksPlaceholder())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: homeState?._buildTaskItem(
                                  homeState.tasks[index]),
                            ),
                            childCount: homeState?.tasks.length ?? 0,
                          ),
                        ),
                ),

                // New Notifications Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: homeState?._buildNotificationsSection(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
