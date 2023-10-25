
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/features/read/presentation/utils.dart';
import '../../../common_widgets/action_text_button.dart';
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
  String _bibleList = 'test';
  late List<dynamic> _bibleContents;
  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState

    super.setState(fn);
  }


  @override
  void didUpdateWidget(covariant Calendar oldWidget) {
    // TODO: implement didUpdateWidget

    print('init');
    rootBundle.loadString('assets/json/bible-RNKSV.json').then((reponse){
      Map<String, dynamic> _bibleJson = json.decode(reponse);
      String bibleList = _bibleJson["m"+_focusedDay.month.toString() + "d" + _focusedDay.day.toString()]["chapter"];
      _bibleList = bibleList;
      _bibleContents = _bibleJson["m"+_focusedDay.month.toString() + "d" + _focusedDay.day.toString()]["contents"];
    });
    print(_bibleList);
    super.didUpdateWidget(oldWidget);
  }

  Future<String> getBibleList (DateTime day) async {
    print("getBibleList" + "m"+day.month.toString() + "d" + day.day.toString());
    final jsonString = await rootBundle.loadString('assets/json/bible-RNKSV.json');
    Map<String, dynamic> _bibleJson = json.decode(jsonString);
    String bibleList = _bibleJson["m"+day.month.toString() + "d" + day.day.toString()]["chapter"];
    //setState(() { _bibleList = bibleList; }) ;
    _bibleList = bibleList;
    _bibleContents = _bibleJson["m"+_focusedDay.month.toString() + "d" + _focusedDay.day.toString()]["contents"];
    print('2');
    return _bibleList;
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

    });
    getBibleList(_focusedDay);
    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }
  List<Widget> getBiblePageList(){
    final List<Widget> biblePageList= [
      Container(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey, //<-- SEE HERE
                ),  //모서리를 둥글게 하기 위해 사용
                borderRadius: BorderRadius.circular(16.0),
              ),
              child : TableCalendar<Event>(
                sixWeekMonthsEnforced : true,
                // 추가
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMM(locale).format(date),
                  formatButtonVisible: false,
                  titleTextStyle: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.cyan,
                  ),
                  headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
                  leftChevronIcon: const Icon(
                    Icons.arrow_left,
                    size: 40.0,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.arrow_right,
                    size: 40.0,
                  ),
                ),
                locale: 'ko_KR',
                rowHeight: 40,
                daysOfWeekHeight: 19,
                calendarStyle: const CalendarStyle(
                    isTodayHighlighted:false,
                    markerDecoration: BoxDecoration(color:  Colors.deepPurpleAccent, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color:  Colors.cyan, shape: BoxShape.circle)
                ),
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                eventLoader: (day) {
                  if(day.year == _focusedDay.year && day.month == _focusedDay.month && day.day == _focusedDay.day) {
                    return [const Event('Cyclic event')];
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
            ),
            SizedBox(height: 10,),
            Card(

              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 3,
                  color: Colors.deepPurple, //<-- SEE HERE
                ),
                borderRadius: BorderRadius.circular(20.0),

              ),
              margin: EdgeInsets.all(0),
              child: Container(

                padding: EdgeInsets.fromLTRB(0, 30, 0, 15),
                width:double.infinity,
                child: Column(
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일').format(_focusedDay),
                      style: const TextStyle(fontSize: 16.0, color: Colors.green),
                    ),
                    FutureBuilder(
                        future: getBibleList(_focusedDay),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if(snapshot.hasData == false){
                            return CircularProgressIndicator(); // CircularProgressIndicator : 로딩 에니메이션
                          }
                          else{
                            return Text(
                              snapshot.data.toString(),
                              style: const TextStyle(fontSize: 24.0, color: Colors.green),
                            );
                          }
                        }
                    ),
                    Container(

                      child: TextButton(
                        child:Text('읽으러가기'),
                        onPressed: (){
                          setState(() {
                            _readDays.add(_focusedDay);
                            _selectedDays.clear();
                            _readDays.forEach((element) {_selectedDays.add(element);});
                          });
                        },
                      ),
                    ),

                  ],
                ),
              ),

            ),



          ],
        ),
      ),

    ];
    List<Widget> bibleScript = _bibleContents.map((item) =>
        Container(
          child: Column(
            children: [
              Text(item["chapter_name"]),
            ],
          ),
        )
    ).toList();
    biblePageList.addAll(bibleScript);
    return biblePageList;
  }

  @override
  Widget build(BuildContext context) {

    final Color kDarkBlueColor = const Color(0xFF053149);
    print(_bibleList);

    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Card(
        child: CarouselSlider(
          options: CarouselOptions(
            height: height,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            // autoPlay: false,
          ),
          items: getBiblePageList()
        )
      ),
    );
  }
}



