import 'package:flutter/material.dart';
import 'package:groupchat/pushnot/local_notifications.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

class MyCalendarApp extends StatefulWidget {
  @override
  _MyCalendarAppState createState() => _MyCalendarAppState();
}

class _MyCalendarAppState extends State<MyCalendarApp>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late CalendarController _calendarController;
  late TextEditingController _eventController;
  List<Appointment> _appointments = [];
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calendarController = CalendarController();
    _eventController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Syncfusion Calendar Event App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
          ],
          onTap: _handleTabChange,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddEventBottomSheet,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(CalendarView.day),
          _buildCalendarView(CalendarView.week),
          _buildCalendarView(CalendarView.month),
        ],
      ),
    );
  }

  Widget _buildCalendarView(CalendarView view) {
    return SfCalendar(
      controller: _calendarController,
      view: view,
      onTap: _handleCalendarTap,
      dataSource: _getCalendarDataSource(),
      timeSlotViewSettings: view == CalendarView.day
          ? const TimeSlotViewSettings(
              startHour: 0,
              endHour: 24,
              timeInterval: Duration(minutes: 60),
            )
          : const TimeSlotViewSettings(),
      initialDisplayDate: view == CalendarView.day
          ? DateTime(_selectedDateTime.year, _selectedDateTime.month,
              _selectedDateTime.day)
          : null,
    );
  }

  _getCalendarDataSource() {
    return AppointmentDataSource(_appointments);
  }

  _handleTabChange(int index) {
    if (index == 1) {
      _changeCalendarView(CalendarView.week);
    } else if (index == 2) {
      _changeCalendarView(CalendarView.month);
    } else {
      _changeCalendarView(CalendarView.day);
    }
  }

  _changeCalendarView(CalendarView view) {
    setState(() {
      _calendarController.view = view;
    });
  }

  _showAddEventBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Event for $_selectedDateTime',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _eventController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  LocalNotifications.showSimpleNotification(
                      title: _eventController.text,
                      body: 'sHEDULE NOTIFICATION',
                      payload:
                          "$_selectedDateTime to ${_selectedDateTime.add(const Duration(hours: 2))}");
                  Navigator.of(context).pop();
                  _addEventToDataSource();
                },
                child: Text('Add Event'),
              ),
            ],
          ),
        );
      },
    );
  }

  _addEventToDataSource() {
    final newEvent = Appointment(
      startTime: _selectedDateTime,
      endTime: _selectedDateTime.add(const Duration(hours: 2)),
      subject: _eventController.text,
    );

    setState(() {
      _appointments.add(newEvent);
    });
    _eventController.clear();
  }

  _handleCalendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      if (_calendarController.view == CalendarView.month) {
        _showEventsForSelectedDateInMonthView(details.date);
      } else {
        setState(() {
          _selectedDateTime = details.date!;
        });
        _showAddEventBottomSheet();
      }
    }
  }

  _showEventsForSelectedDateInMonthView(DateTime? selectedDate) {
    if (selectedDate != null) {
      final eventsOnSelectedDate = _appointments
          .where((event) =>
              event.startTime.year == selectedDate.year &&
              event.startTime.month == selectedDate.month &&
              event.startTime.day == selectedDate.day)
          .toList();

      if (eventsOnSelectedDate.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: eventsOnSelectedDate.map((event) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${event.startTime.hour}:${event.startTime.minute} - ${event.endTime.hour}:${event.endTime.minute}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text(
                          event.subject,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }
    }
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
