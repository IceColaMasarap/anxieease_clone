import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DailyLog {
  final List<String> feelings;
  final double stressLevel;
  final List<String> symptoms;
  final DateTime timestamp;

  DailyLog({
    required this.feelings,
    required this.stressLevel,
    required this.symptoms,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'feelings': feelings,
        'stressLevel': stressLevel,
        'symptoms': symptoms,
        'timestamp': timestamp.toIso8601String(),
      };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
        feelings: List<String>.from(json['feelings']),
        stressLevel: json['stressLevel'].toDouble(),
        symptoms: List<String>.from(json['symptoms']),
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<DailyLog>> _dailyLogs = {};
  static const String LOGS_KEY = 'daily_logs';

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
    _loadLogs();
    _selectedDay = DateTime.now();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString(LOGS_KEY);

    if (logsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(logsJson);
      setState(() {
        _dailyLogs = decoded.map((key, value) {
          DateTime date = DateTime.parse(key);
          List<dynamic> logsList = value as List<dynamic>;
          return MapEntry(
            _normalizeDate(date),
            logsList.map((log) => DailyLog.fromJson(log)).toList(),
          );
        });
      });
    }
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = _dailyLogs.map((key, value) {
      return MapEntry(
        _normalizeDate(key).toIso8601String(),
        value.map((log) => log.toJson()).toList(),
      );
    });
    await prefs.setString(LOGS_KEY, jsonEncode(encoded));
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  List<String> _getEventsForDay(DateTime day) {
    final logs = _dailyLogs[_normalizeDate(day)];
    return logs != null ? [''] : [];
  }

  void _deleteLog(DateTime date, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to delete this log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final key = _normalizeDate(date);
                _dailyLogs[key]?.removeAt(index);
                if (_dailyLogs[key]?.isEmpty ?? false) {
                  _dailyLogs.remove(key);
                }
              });
              _saveLogs();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDailyLog(DateTime selectedDate, List<String> selectedMoods, double stressLevel, List<String> selectedSymptoms, [DailyLog? existingLog]) async {
    final normalizedDate = _normalizeDate(selectedDate);
    
    setState(() {
      if (!_dailyLogs.containsKey(normalizedDate)) {
        _dailyLogs[normalizedDate] = [];
      }
      
      if (existingLog != null) {
        // Find and update existing log
        final index = _dailyLogs[normalizedDate]!.indexWhere(
          (log) => log.timestamp == existingLog.timestamp
        );
        if (index != -1) {
          _dailyLogs[normalizedDate]![index] = DailyLog(
            feelings: selectedMoods,
            stressLevel: stressLevel,
            symptoms: selectedSymptoms,
            timestamp: existingLog.timestamp, // Keep original timestamp
          );
        }
      } else {
        // Add new log
        _dailyLogs[normalizedDate]!.add(DailyLog(
          feelings: selectedMoods,
          stressLevel: stressLevel,
          symptoms: selectedSymptoms,
          timestamp: DateTime.now(),
        ));
      }
    });

    await _saveLogs();
  }

  void _showFeelingsDialog([DailyLog? existingLog]) {
    if (_selectedDay == null) return;

    final List<String> moods = [
      'Happy', 'Fearful', 'Excited', 'Angry', 'Calm',
      'Pain', 'Boredom', 'Sad', 'Awe', 'Confused',
      'Anxious', 'Relief', 'Satisfied'
    ];
    
    Set<String> selectedMoods = Set<String>.from(existingLog?.feelings ?? []);
    Map<String, bool> selectedSymptoms = Map<String, bool>.from(symptoms);
    
    if (existingLog != null) {
      for (final symptom in existingLog.symptoms) {
        selectedSymptoms[symptom] = true;
      }
    }
    double stressLevel = existingLog?.stressLevel ?? 3.0;

    void saveLog() {
      if (_selectedDay != null) {
        final selectedSymptomsList = selectedSymptoms.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
        
        // Only save if there are selected moods
        if (selectedMoods.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one mood')),
          );
          return;
        }
        
        _saveDailyLog(
          _selectedDay!,
          selectedMoods.toList(),
          stressLevel,
          selectedSymptomsList,
          existingLog, // Pass the existing log if we're updating
        ).then((_) => Navigator.pop(context));
      } else {
        Navigator.pop(context);
      }
    }

    void showSymptomsSelector() {
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
                    _buildModalHeader('Select Your Symptoms'),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: selectedSymptoms.entries.map((entry) {
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: entry.value ? Colors.teal[700]! : Colors.grey[300]!,
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                entry.key,
                                style: TextStyle(
                                  color: entry.value ? Colors.teal[700] : Colors.grey[800],
                                  fontWeight: entry.value ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              value: entry.value,
                              activeColor: Colors.teal[700],
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedSymptoms[entry.key] = value ?? false;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    _buildModalFooter(
                      onNext: saveLog,
                      buttonText: existingLog != null ? 'Update Log' : 'Save Log',
                      showDelete: existingLog != null,
                      onDelete: existingLog != null
                          ? () => _deleteLog(_selectedDay!, 0)
                          : null,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    void showStressLevelSelector() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    _buildModalHeader('Rate Your Stress Level'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stressLevel.round().toString(),
                              style: TextStyle(
                                color: Colors.teal[700],
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text('Low'),
                                Expanded(
                                  child: Slider(
                                    value: stressLevel,
                                    min: 0,
                                    max: 10,
                                    divisions: 10,
                                    activeColor: Colors.teal[700],
                                    inactiveColor: Colors.teal[100],
                                    label: stressLevel.round().toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        stressLevel = value;
                                      });
                                    },
                                  ),
                                ),
                                const Text('High'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildModalFooter(
                      onNext: () {
                        Navigator.pop(context);
                        showSymptomsSelector();
                      },
                      buttonText: 'Next: Symptoms',
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    void showMoodSelector() {
      bool showWarning = false;
      
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
                    _buildModalHeader('Select Your Moods'),
                    if (showWarning)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[100]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Please select at least one mood',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: moods.length,
                        itemBuilder: (context, index) {
                          final mood = moods[index];
                          final isSelected = selectedMoods.contains(mood);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedMoods.remove(mood);
                                } else {
                                  selectedMoods.add(mood);
                                }
                                // Clear warning when a mood is selected
                                if (selectedMoods.isNotEmpty) {
                                  showWarning = false;
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF3AA772) : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF3AA772) : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getMoodIcon(mood),
                                    color: isSelected ? Colors.white : Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    mood,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildModalFooter(
                      onNext: () {
                        if (selectedMoods.isEmpty) {
                          setState(() {
                            showWarning = true;
                          });
                          return;
                        }
                        Navigator.pop(context);
                        showStressLevelSelector();
                      },
                      buttonText: 'Next: Stress Level',
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    // Start with the mood selector
    showMoodSelector();
  }

  Widget _buildModalHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalFooter({
    required VoidCallback onNext,
    required String buttonText,
    bool showDelete = false,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showDelete && onDelete != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS background color
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        title: const Text(
          'Journal',
          style: TextStyle(
            color: Color(0xFF000000),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _calendarFormat == CalendarFormat.month 
                ? Icons.view_week_rounded
                : Icons.calendar_view_month_rounded,
              color: const Color(0xFF007AFF),
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Color(0xFFFF3B30)),
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.5,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                  letterSpacing: -0.5,
                ),
                leftChevronIcon: Icon(Icons.chevron_left_rounded, color: Color(0xFF007AFF), size: 28),
                rightChevronIcon: Icon(Icons.chevron_right_rounded, color: Color(0xFF007AFF), size: 28),
                headerPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Text(
                    '${_selectedDay!.day} ${_getMonthName(_selectedDay!.month)} ${_selectedDay!.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildLogDetails(_selectedDay!),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay == null) {
            setState(() {
              _selectedDay = DateTime.now();
              _focusedDay = DateTime.now();
            });
          }
          _showFeelingsDialog();
        },
        backgroundColor: const Color(0xFF007AFF),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildLogDetails(DateTime date) {
    final logs = _dailyLogs[_normalizeDate(date)] ?? [];

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_rounded,
              size: 32,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              'No entries yet',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[400],
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: logs.length,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemBuilder: (context, index) {
        final log = logs[index];
        final timeStr = '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';
        
        Color getStressColor(double level) {
          if (level <= 3) {
            return const Color(0xFF34C759); // Low stress
          } else if (level <= 7) {
            return const Color(0xFFFF9500); // Medium stress
          } else {
            return const Color(0xFFFF3B30); // High stress
          }
        }

        final stressColor = getStressColor(log.stressLevel);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stress Level',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: stressColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                log.stressLevel <= 3 
                                    ? Icons.sentiment_satisfied_rounded
                                    : log.stressLevel <= 7
                                        ? Icons.sentiment_neutral_rounded
                                        : Icons.sentiment_dissatisfied_rounded,
                                size: 14,
                                color: stressColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${log.stressLevel.toInt()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: stressColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Actions Row
                    Row(
                      children: [
                        // Edit Button
                        GestureDetector(
                          onTap: () => _showFeelingsDialog(log),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button
                        GestureDetector(
                          onTap: () => _deleteLog(date, index),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (log.feelings.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feelings',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: log.feelings.map((feeling) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              feeling,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF007AFF),
                                letterSpacing: -0.3,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              if (log.symptoms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Symptoms',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: log.symptoms.map((symptom) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              symptom,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFFF3B30),
                                letterSpacing: -0.3,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
} 