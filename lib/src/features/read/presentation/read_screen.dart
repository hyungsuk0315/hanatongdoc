
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/features/read/presentation/read_controller.dart';
import 'package:starter_architecture_flutter_firebase/src/features/read/presentation/utils.dart';
import '../../../common_widgets/action_text_button.dart';
import '../../../constants/strings.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/read_repository.dart';

final today = DateUtils.dateOnly(DateTime.now());
final isSelected = <bool>[false, false, false];
class ReadScreen extends ConsumerWidget{
    const ReadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref)  {
    // TODO: implement build

    final state = ref.watch(readControllerProvider);
    final readRepository = ref.watch(readRepositoryProvider);
    int _userFontSize = readRepository.getReadFontSize();

    // final userInfo = {
    //   "ReadFontSize" : readRepository.getReadFontSize()
    // };


    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.read),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async{
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // return object of type Dialog
                  return AlertDialog(
                    backgroundColor: Colors.deepPurple,
                    title:  Container(

                        alignment: Alignment.center,
                        child: Text(
                          "설정",
                          style:TextStyle(
                          fontSize: 32,
                          color: Colors.cyan,
                          ),
                        )
                    ),
                    content: Container(

                        child: Row(
                          children: [
                            Text(
                                "통독 플랜",
                                style:TextStyle(
                                  fontSize: 20,
                                  color: Colors.cyan,
                                ),
                            ),
                            TextButton(
                                onPressed: ()async{
                                  await ref.read(readControllerProvider.notifier).setReadNumber(1);
                                },
                                child: Text('1독')
                            ),
                            TextButton(
                                onPressed: ()async{
                                  await ref.read(readControllerProvider.notifier).setReadNumber(1);
                                },
                                child: Text('2독')
                            ),
                            TextButton(
                                onPressed: ()async{
                                  await ref.read(readControllerProvider.notifier).setReadNumber(1);
                                },
                                child: Text('3독')
                            ),
                            ToggleButtons(
                              color: Colors.black.withOpacity(0.60),
                              selectedColor: Color(0xFF6200EE),
                              selectedBorderColor: Color(0xFF6200EE),
                              fillColor: Color(0xFF6200EE).withOpacity(0.08),
                              splashColor: Color(0xFF6200EE).withOpacity(0.12),
                              hoverColor: Color(0xFF6200EE).withOpacity(0.04),
                              borderRadius: BorderRadius.circular(4.0),
                              constraints: BoxConstraints(minHeight: 36.0),
                              isSelected: isSelected,
                              onPressed: (index) async{
                                                                      
                                },
                              children: [
                                Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('BUTTON 1'), ),
                                Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('BUTTON 2'), ),
                                Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('BUTTON 3'),
                                ),
                              ],
                            )
                          ],
                        )
                        
                    ),
                    actions: <Widget>[
                      // usually buttons at the bottom of the dialog
                      new TextButton(
                        child: new Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async{
              await ref.read(readControllerProvider.notifier).clickFontPlus();
            },
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () async{
              await ref.read(readControllerProvider.notifier).clickFontMinus();
            },
          )
        ],
      ),
      body: Calendar(_userFontSize),
    );
  }
}

// class ReadScreen extends StatefulWidget {
//   const ReadScreen({super.key});
//
//   @override
//   State<ReadScreen> createState() => _ReadScreenState();
// }
//
// class _ReadScreenState extends State<ReadScreen> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text(Strings.read),
//         ),
//       body: Calendar(),
//     );
//   }
// }

class Calendar extends StatefulWidget {

  final int userFontSize;
  const Calendar(
       this.userFontSize,
      {super.key}
      );


  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>  {

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  void initState () {
    print("init");
    super.initState ();
    //getBibleContentsList(_focusedDay);
    int _userFontSize = widget.userFontSize ;

    print(widget.userFontSize);
  }

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
  List<Widget> _bibleContents = [];
  final int _userFontSize = 16;
  int initIndex =0 ;
  //caledar 기본
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
    getBibleContentsList(_focusedDay);
    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }
  //caledar 기본
  Future<String> getBibleList (DateTime day) async {
    //read json
    final jsonString = await rootBundle.loadString('assets/json/bible-RNKSV.json');
    Map<String, dynamic> _bibleJson = json.decode(jsonString);
    String bibleList = _bibleJson["m"+day.month.toString() + "d" + day.day.toString()]["chapter"];
    //setState(() { _bibleList = bibleList; }) ;
    _bibleList = bibleList;
    print('2');
    return _bibleList;
  }
  Future<List<Widget>> getBibleContentsList (DateTime day) async {

    //read json
    final jsonString = await rootBundle.loadString('assets/json/bible-RNKSV.json');
    Map<String, dynamic> _bibleJson = json.decode(jsonString);
    List<dynamic> bibleContentsJson = _bibleJson["m"+_focusedDay.month.toString() + "d" + _focusedDay.day.toString()]["contents"];


    print("userFontSize : ${widget.userFontSize}");
    //calendar page
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
                  titleTextStyle:  const TextStyle(
                    fontSize: 16,
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
            InkWell(
                child:Card(

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
                            style:  TextStyle(
                                fontSize:16,
                                color: Colors.green
                            ),
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
                                    style: TextStyle(
                                        fontSize:20,
                                        color: Colors.green
                                    ),
                                  );
                                }
                              }
                          ),
                          Container(

                            child: TextButton(
                              child:Text(
                                '읽으러가기',
                                style: TextStyle(
                                    fontSize:widget.userFontSize.toDouble() * 0.8,
                                ),
                              ),
                              onPressed: (){
                                _controller.nextPage();
                              },
                            ),
                          ),

                        ],
                      ),
                    ),

                  ),

                onTap: (){
                  _controller.nextPage();
                  },
            ),

          ],
        ),
      ),
    ];

    //bible script page
    for(int i = 0 ; i < bibleContentsJson.length ; i++){
      List<Widget> tmp = [];
        for(int j = 0 ; j < bibleContentsJson[i]["paragraphs"].length ; j++){
          tmp.add(
              Text(
                  bibleContentsJson[i]["paragraphs"][j]["title"],
                  style: TextStyle(
                      height: 2,
                      fontSize: widget.userFontSize.toDouble() * 1.5,
                      fontWeight: FontWeight.bold
                  ),
            )
          );
          tmp.add(SizedBox(height: 10,));
          for(int k = 0 ; k < bibleContentsJson[i]["paragraphs"][j]["verses"].length ; k++){
            tmp.add(
                Text(
                    bibleContentsJson[i]["paragraphs"][j]["verses"][k]["index"] + ". " + bibleContentsJson[i]["paragraphs"][j]["verses"][k]["content"],
                    style: TextStyle(
                        height: 1.5,
                        fontSize: widget.userFontSize.toDouble(),
                    ),

                )
            );
            tmp.add(SizedBox(height: 10,));
          }
        }
      biblePageList.add(Padding(
        padding: const EdgeInsets.fromLTRB(15,10,15,10),
        child: ListView(
          children: tmp,
        
        ),
      ));
    }
    List<Widget> bibleScript = bibleContentsJson.map((item) =>
        Container(
          child: ListView(
            children: [
              Text(
                  item["chapter_name"]

              ),
              for( int i = 0 ; i < item["paragraphs"].length ; i++)
                Text(
                    item["paragraphs"][i]["title"]

                ),
              for( int i = 0 ; i < item["paragraphs"].length ; i++)
                for( int j = 0 ; j < item["paragraphs"][i]["verses"].length ; j++)
                  Text(
                      item["paragraphs"][i]["verses"][j]["index"] + ". " + item["paragraphs"][i]["verses"][j]["content"]

                  ),
            ],
          ),
        )
    ).toList();

    //biblePageList.addAll(tmp);
    _bibleContents = biblePageList;

    return biblePageList;
  }
  final CarouselController _controller = CarouselController();
  _onPageViewChange(int page) {
    print("Current Page: " + page.toString());
    int previousPage = page;
    if(page != 0) previousPage--;
    else previousPage = 2;
    print("Previous page: $previousPage");
  }
  @override
  Widget build(BuildContext context) {

    final double height = MediaQuery.of(context).size.height;
    final int f = widget.userFontSize;
    return
      FutureBuilder(
          future: getBibleContentsList(_focusedDay),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.hasData == false){
              return CircularProgressIndicator(); // CircularProgressIndicator : 로딩 에니메이션
            }
            else{
              return
                Container(
                  color: Colors.transparent,
                  key:UniqueKey(),
                  child: Scaffold(
                    body: Card(
                      child: CarouselSlider(

                          carouselController:_controller,
                          options: CarouselOptions(
                            initialPage: initIndex,
                            onPageChanged:(index, reason){
                              setState(() {
                                initIndex = index;
                              });
                            },
                            enableInfiniteScroll:false,
                            height: height,
                            viewportFraction: 1.0,
                            enlargeCenterPage: false,
                          // autoPlay: false,
                        ),
                          items: _bibleContents
                          
                      )
                  ),
                ),
              );
            }
          }
      );


  }
}



