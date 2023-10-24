
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_architecture_flutter_firebase/src/features/read/presentation/utils.dart';
import '../../../constants/strings.dart';
import 'package:table_calendar/table_calendar.dart';

final today = DateUtils.dateOnly(DateTime.now());
class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(Strings.read),
        ),
      body: Calendar(),
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  final Set<DateTime> _readDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  String _bibleList = "test";

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }
  @override
  Calendar(){

  }

  Future<String> getBibleList (DateTime day) async {
    print('something');
    final jsonString = await rootBundle.loadString('assets/json/bible-RNKSV.json');
    Map<String, dynamic> _bibleJson = json.decode(jsonString);
    String bibleList = _bibleJson["m"+day.month.toString() + "d" + day.day.toString()]["chapter"];
    print(bibleList);
    _bibleList = bibleList;
    return bibleList;
  }
  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }
  List<Event> _getEventsForDays(Set<DateTime> days) {
    // Implementation example
    // Note that days are in selection order (same applies to events)
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _selectedDays.clear();
      _readDays.forEach((element) {_selectedDays.add(element);});
      getBibleList(focusedDay);

      print(_readDays);
      //_selectedDays = _readDays;
      // Update values in a Set
      // if (_selectedDays.contains(selectedDay)) {
      //   _selectedDays.remove(selectedDay);
      // } else {
      //   _selectedDays.add(selectedDay);
      // }
    });
    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Column(
            children: [
              TextButton(
                child:Text('read'),
                onPressed: (){
                    setState(() {
                      _readDays.add(_focusedDay);
                      _selectedDays.clear();
                      _readDays.forEach((element) {_selectedDays.add(element);});
                      print(_readDays);
                    });
                  },
              ),
              TableCalendar<Event>(
                calendarStyle: CalendarStyle(
                  isTodayHighlighted:false,
                  markerDecoration: const BoxDecoration(color:  Colors.deepPurpleAccent, shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(color:  Colors.cyan, shape: BoxShape.circle)
                ),
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                eventLoader: (day) {
                  if(day.year == _focusedDay.year && day.month == _focusedDay.month && day.day == _focusedDay.day) {
                    return [Event('Cyclic event')];
                  }
                  return [];
                },
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  // Use values from Set to mark multiple days as selected
                  return _selectedDays.contains(day);
                },
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              Text(_bibleList)
            ],
          ),
    );
  }
}


