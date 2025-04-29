import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/psychologist_model.dart';
import 'models/appointment_model.dart';
import 'services/supabase_service.dart';
import 'utils/logger.dart';

class PsychologistProfilePage extends StatefulWidget {
  const PsychologistProfilePage({super.key});

  @override
  State<PsychologistProfilePage> createState() =>
      _PsychologistProfilePageState();
}

class _PsychologistProfilePageState extends State<PsychologistProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  PsychologistModel? _psychologist;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  bool _showAppointmentForm = false;

  // Form controllers
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _reasonController = TextEditingController();

  // Form validation
  final Map<String, String> _fieldErrors = {
    'date': '',
    'time': '',
    'reason': '',
  };

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load psychologist data
      final psychologistData = await _supabaseService.getAssignedPsychologist();
      if (psychologistData != null) {
        setState(() {
          _psychologist = PsychologistModel.fromJson(psychologistData);
        });
      }

      // Load appointment history
      final appointmentsData = await _supabaseService.getAppointments();
      setState(() {
        _appointments = appointmentsData
            .map((data) => AppointmentModel.fromJson(data))
            .toList();
      });
    } catch (e) {
      Logger.error('Error loading psychologist data', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3AA772),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
        _fieldErrors['date'] = '';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3AA772),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
        _fieldErrors['time'] = '';
      });
    }
  }

  void _resetForm() {
    setState(() {
      _dateController.text = '';
      _timeController.text = '';
      _reasonController.text = '';
      _selectedDate = null;
      _selectedTime = null;
      _fieldErrors['date'] = '';
      _fieldErrors['time'] = '';
      _fieldErrors['reason'] = '';
    });
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      // Validate date
      if (_selectedDate == null) {
        _fieldErrors['date'] = 'Date is required';
        isValid = false;
      } else {
        _fieldErrors['date'] = '';
      }

      // Validate time
      if (_selectedTime == null) {
        _fieldErrors['time'] = 'Time is required';
        isValid = false;
      } else {
        _fieldErrors['time'] = '';
      }

      // Validate reason
      if (_reasonController.text.trim().isEmpty) {
        _fieldErrors['reason'] = 'Reason is required';
        isValid = false;
      } else {
        _fieldErrors['reason'] = '';
      }
    });

    return isValid;
  }

  Future<void> _submitAppointmentRequest() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time
      final appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Create appointment data
      final appointmentData = {
        'psychologist_id': _psychologist!.id,
        'appointment_date': appointmentDateTime.toIso8601String(),
        'reason': _reasonController.text.trim(),
      };

      // Submit appointment request
      await _supabaseService.requestAppointment(appointmentData);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Your appointment request has been submitted. Please wait for confirmation.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reset form and reload data
      _resetForm();
      setState(() {
        _showAppointmentForm = false;
      });
      await _loadData();
    } catch (e) {
      Logger.error('Error submitting appointment request', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Your Psychologist'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _psychologist == null
              ? _buildNoPsychologist()
              : _buildPsychologistProfile(),
    );
  }

  Widget _buildNoPsychologist() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No Psychologist Assigned',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You don\'t have an assigned psychologist yet. Please contact support for assistance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPsychologistProfile() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Psychologist header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.green[100],
                    backgroundImage: _psychologist!.imageUrl != null
                        ? NetworkImage(_psychologist!.imageUrl!)
                        : null,
                    child: _psychologist!.imageUrl == null
                        ? Text(
                            _psychologist!.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Name
                Text(
                  _psychologist!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                // Specialization
                Text(
                  _psychologist!.specialization,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                // Contact info
                _buildInfoRow(Icons.email, _psychologist!.contactEmail),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.phone, _psychologist!.contactPhone),
              ],
            ),
          ),

          // Biography
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _psychologist!.biography,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Request appointment button
          if (!_showAppointmentForm)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAppointmentForm = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3AA772),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Request Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Appointment request form
          if (_showAppointmentForm)
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildAppointmentForm(),
            ),

          // Appointment Requests
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointment Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                _buildAppointmentSection([
                  AppointmentStatus.pending,
                  AppointmentStatus.accepted,
                  AppointmentStatus.denied,
                ]),
              ],
            ),
          ),

          // Past Appointments
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Past Appointments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                _buildAppointmentSection([
                  AppointmentStatus.completed,
                  AppointmentStatus.cancelled,
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.green[700],
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request an Appointment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Date picker
          TextField(
            controller: _dateController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              labelText: 'Date',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              errorText: _fieldErrors['date']!.isNotEmpty
                  ? _fieldErrors['date']
                  : null,
            ),
          ),
          const SizedBox(height: 15),

          // Time picker
          TextField(
            controller: _timeController,
            readOnly: true,
            onTap: () => _selectTime(context),
            decoration: InputDecoration(
              labelText: 'Time',
              prefixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              errorText: _fieldErrors['time']!.isNotEmpty
                  ? _fieldErrors['time']
                  : null,
            ),
          ),
          const SizedBox(height: 15),

          // Reason
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Reason for Appointment',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              errorText: _fieldErrors['reason']!.isNotEmpty
                  ? _fieldErrors['reason']
                  : null,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && _fieldErrors['reason']!.isNotEmpty) {
                setState(() {
                  _fieldErrors['reason'] = '';
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // Submit and cancel buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAppointmentRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3AA772),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _showAppointmentForm = false;
                            _resetForm();
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSection(List<AppointmentStatus> statuses,
      {bool showOnlyWithResponses = false}) {
    // Filter appointments based on status and response message requirement
    final filteredAppointments = _appointments.where((appointment) {
      if (showOnlyWithResponses && appointment.responseMessage == null) {
        return false;
      }
      return statuses.contains(appointment.status);
    }).toList();

    // Sort appointments by date (most recent first for past, soonest first for upcoming)
    filteredAppointments.sort((a, b) {
      if (statuses.contains(AppointmentStatus.completed) ||
          statuses.contains(AppointmentStatus.cancelled)) {
        // For past appointments, show most recent first
        return b.appointmentDate.compareTo(a.appointmentDate);
      } else {
        // For upcoming appointments, show soonest first
        return a.appointmentDate.compareTo(b.appointmentDate);
      }
    });

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No appointments to display',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(
      children: filteredAppointments
          .map((appointment) => _buildAppointmentCard(appointment))
          .toList(),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    Color statusColor;
    IconData statusIcon;

    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.event_available;
        break;
      case AppointmentStatus.accepted:
        statusColor = Colors.teal;
        statusIcon = Icons.check_circle;
        break;
      case AppointmentStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case AppointmentStatus.denied:
        statusColor = Colors.deepOrange;
        statusIcon = Icons.cancel;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.event_busy;
        break;
      case AppointmentStatus.completed:
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
    }

    // Add a subtle background color based on status
    Color cardBackgroundColor = Colors.white;
    if (appointment.status == AppointmentStatus.pending) {
      cardBackgroundColor = Colors.orange[50]!;
    } else if (appointment.status == AppointmentStatus.accepted) {
      cardBackgroundColor = Colors.teal[50]!;
    } else if (appointment.status == AppointmentStatus.denied) {
      cardBackgroundColor = Colors.red[50]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: statusColor.withAlpha(50),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Appointment details
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM dd, yyyy')
                      .format(appointment.appointmentDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat('h:mm a').format(appointment.appointmentDate),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  appointment.reason,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),

                // Response message (if any)
                if (appointment.responseMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.comment,
                              size: 14,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Psychologist Response:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appointment.responseMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
