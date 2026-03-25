import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScheduler extends StatefulWidget {
  final Function(DateTime?, Duration?, int?) onScheduleChanged;

  const NotificationScheduler({
    Key? key,
    required this.onScheduleChanged,
  }) : super(key: key);

  @override
  _NotificationSchedulerState createState() => _NotificationSchedulerState();
}

class _NotificationSchedulerState extends State<NotificationScheduler> {
  DateTime? _selectedDateTime;
  Duration? _intervalDuration;
  int? _notificationCount;
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  @override
  void dispose() {
    _intervalController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _updateSchedule() {
    widget.onScheduleChanged(
      _selectedDateTime,
      _intervalDuration,
      _notificationCount,
    );
  }

  Future<void> _pickDateTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[800]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          DateTime.now().year,
          DateTime.now().day,
          DateTime.now().month,
          pickedTime.hour,
          pickedTime.minute,
        );
        _updateSchedule();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCountAndIntervalRow(),
          const SizedBox(height: 20),
          _buildScheduleCard(),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _buildCard(
      child: InkWell(
        onTap: _pickDateTime,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start Time',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDateTime == null
                        ? 'Select time and date'
                        : DateFormat('MMM dd, yyyy – HH:mm')
                            .format(_selectedDateTime!),
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDateTime == null
                          ? Colors.grey[600]
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: Colors.blue[800],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountAndIntervalRow() {
    return Row(
      children: [
        Expanded(child: _buildCountCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildIntervalCard()),
      ],
    );
  }

  Widget _buildCountCard() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Count',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: '[1-64]',
                hintStyle: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                int? count = int.tryParse(value);
                if (count != null && count > 0 && count <= 64) {
                  setState(() {
                    _notificationCount = count;
                    _intervalDuration =
                        _intervalDuration ?? const Duration(seconds: 0);
                    _updateSchedule();
                  });
                } else {
                  setState(() {
                    _notificationCount = null;
                    _intervalDuration = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalCard() {
    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interval',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _intervalController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 16,
                color: _notificationCount == null
                    ? Colors.grey[400]
                    : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              enabled: _notificationCount != null,
              decoration: const InputDecoration(
                hintText: '[0-60] seconds',
                hintStyle: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                int? seconds = int.tryParse(value);
                if (_notificationCount != null &&
                    seconds != null &&
                    seconds >= 0 &&
                    seconds <= 60) {
                  setState(() {
                    _intervalDuration = Duration(milliseconds: seconds * 1000);
                    _updateSchedule();
                  });
                } else {
                  setState(() {
                    _intervalDuration = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
