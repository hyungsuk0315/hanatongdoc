
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
import 'package:starter_architecture_flutter_firebase/src/utils/async_value_ui.dart';
import '../../../common_widgets/action_text_button.dart';
import '../../../constants/strings.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../data/read_repository.dart';

final today = DateUtils.dateOnly(DateTime.now());
 List<bool> isSelected = <bool>[false, false, false];





class ReadScreen extends ConsumerStatefulWidget {


  const ReadScreen({Key? key}) : super(key: key);

  @override
  ReadScreenConsumerState createState() => ReadScreenConsumerState();
}

class ReadScreenConsumerState extends ConsumerState<ReadScreen>{

  @override
  void initState() {

    print(1);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final state = ref.watch(readControllerProvider);
    final readRepository = ref.watch(readRepositoryProvider);
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    int _userFontSize = readRepository.getReadFontSize();
    int _userReadNumber = readRepository.getReadNumber();
    String _userUid = readRepository.getUserUid(currentUser!.uid);
    Future<String> _userReadDate = readRepository.getReadDate(uid: _userUid);
    List<bool> isSelected = [ true, false, false];
    // final userInfo = {
    //   "ReadFontSize" : readRepository.getReadFontSize()
    // };
    List<bool> _getSelectedNumber(num)  {
      List<bool> tmp = [false,false,false];
      tmp[num] = true;
      return tmp;
    }
    Future<List<bool>> setSelectNumber(num) async{
      await ref.read(readControllerProvider.notifier).setReadNumber(num);
      return _getSelectedNumber(num);
    }
    print("read number : ${_userReadNumber}");
    return StatefulBuilder(
        builder: (__, StateSetter setState) {

          return Scaffold(
                  appBar: AppBar(
                    title: const Text(Strings.read),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: ()   {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              print("alertdialog rendering - ${isSelected}");
                              isSelected = _getSelectedNumber(readRepository.getReadNumber() - 1);
                              return PopScope(
                                  onPopInvoked: (b){
                                    print("pop {$b}");
                                    setState(() {
                                      _userReadNumber = readRepository.getReadNumber();
                                    });

                                    },
                                  child: AlertDialog(

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
                                content: StatefulBuilder(
                                    builder: (__, StateSetter setState) {
                                      return Container(
                                          child: Row(
                                            children: [
                                              Text(
                                                "통독 플랜",
                                                style:TextStyle(
                                                  fontSize: 16,
                                                  color:Colors.cyan,
                                                ),
                                              ),
                                              ToggleButtons(
                                                borderColor: Colors.transparent,
                                                color: Colors.black.withOpacity(0.60),
                                                selectedColor: Colors.cyan,
                                                selectedBorderColor: Colors.transparent,
                                                fillColor: Colors.transparent,
                                                splashColor: Colors.cyan.withOpacity(0.12),
                                                hoverColor: Colors.cyan.withOpacity(0.04),
                                                //borderRadius: BorderRadius.circular(4.0),
                                                constraints: BoxConstraints(minHeight: 36.0),
                                                isSelected: isSelected,
                                                onPressed: (int index)   {
                                                  ref.read(readControllerProvider.notifier).setReadNumber(index + 1);
                                                  setState(()  {
                                                    for(int i = 0 ; i < isSelected.length ; i++){
                                                      isSelected[i] = i == index;
                                                    }
                                                    _userReadNumber = readRepository.getReadNumber();

                                                  });
                                                },
                                                children: [
                                                  Container(
                                                    child: Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
                                                      child: Text('1독'), ),

                                                  ),
                                                  Container(
                                                    child: Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
                                                      child: Text('2독'), ),

                                                  ),
                                                  Container(
                                                    child: Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
                                                      child: Text('3독'),
                                                    ),

                                                  ),
                                                ],
                                              )
                                            ],
                                          )

                                      );
                                    }
                                ),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new TextButton(
                                    child: new Text("Close"),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        _userReadNumber = readRepository.getReadNumber();
                                      });
                                    },
                                  ),
                                ],
                              ) );
                                ;
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
                  body: Calendar(_userFontSize, _userReadNumber, _userReadDate),
                );


        });


  }
}
class Calendar extends StatefulWidget {

  final int userFontSize;
  final int userReadNumber;
  final Future<String> _userReadDate;

  const Calendar(
       this.userFontSize,
        this.userReadNumber, this._userReadDate,
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
    super.initState ();

    //getBibleContentsList(_focusedDay);
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
  bool isLeapYear(DateTime day){
    int year = day.year;
    if(((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)){
      return true;
    }
    return false;
  }
  //caledar 기본
  Future<String> getBibleList (DateTime day) async {
    //read json
    final jsonString = await rootBundle.loadString('assets/json/bible-RNKSV.json');
    Map<String, dynamic> _bibleJson = json.decode(jsonString);
    String bibleList = "";
    int curDayNum = day.difference(DateTime(2022,12,31)).inDays;
    if(widget.userReadNumber > 1)
        curDayNum = widget.userReadNumber==2?curDayNum*2 -1 : curDayNum*3 -2;
    print("curdaynum before - ${curDayNum}");
    curDayNum = isLeapYear(day)?curDayNum%366:curDayNum%365;
    print("curdaynum ${curDayNum}");
    DateTime calDate = DateTime(day.year-1, 12,31).add(Duration(days:curDayNum));

    print("calDate ${"m"+calDate.month.toString() + "d" + calDate.day.toString()}");
    print("widget.userReadNumber ${widget.userReadNumber}");
    for(int i = 0 ; i < widget.userReadNumber ; i++){
      bibleList = bibleList + _bibleJson["m"+calDate.month.toString() + "d" + calDate.day.toString()]["chapter"] + '/';
      calDate = calDate.add(Duration(days:1));
    }
    bibleList = bibleList.substring(0, bibleList.length-1);
    print("bibleList ${bibleList}");
    //setState(() { _bibleList = bibleList; }) ;
    _bibleList = bibleList;
    return _bibleList;
  }
  //caledar 기본
  // Future<String> getBibleList (DateTime day) async {
  //   //read json
  //   final jsonString = await rootBundle.loadString('assets/json/bible-RNKSV.json');
  //   Map<String, dynamic> _bibleJson = json.decode(jsonString);
  //   String bibleList = "";
  //   int curDayNum = DateTime(2022,12,31).difference(day).inDays;
  //   curDayNum = isLeapYear(day)?curDayNum%366:curDayNum%365;
  //   DateTime calDate = DateTime(day.year, 1,1).add(Duration(days:curDayNum));
  //
  //   for(int i = 0 ; i < widget.userReadNumber ; i++){
  //     bibleList= i!=0? bibleList +'/' : bibleList;
  //     bibleList = _bibleJson["m"+day.month.toString() + "d" + day.day.toString()]["chapter"];
  //   }
  //   //setState(() { _bibleList = bibleList; }) ;
  //   _bibleList = bibleList;
  //   print('2');
  //   return _bibleList;
  // }
  Future<String> getUserReadDates() {
    return widget._userReadDate;
  }
  Future<List<Widget>> getBibleContentsList (DateTime day) async {

    //read json
    final jsonString = await rootBundle.loadString('assets/json/bible-RNKSV.json');
    Map<String, dynamic> _bibleJson = json.decode(jsonString);
    int curDayNum = day.difference(DateTime(2022,12,31)).inDays;
    if(widget.userReadNumber > 1)
      curDayNum = widget.userReadNumber==2?curDayNum*2 -1 : curDayNum*3 -2;
    print("curdaynum before - ${curDayNum}");
    curDayNum = isLeapYear(day)?curDayNum%366:curDayNum%365;
    print("curdaynum ${curDayNum}");
    DateTime calDate = DateTime(day.year-1, 12,31).add(Duration(days:curDayNum));

    print("calDate ${"m"+calDate.month.toString() + "d" + calDate.day.toString()}");
    print("widget.userReadNumber ${widget.userReadNumber}");
    List<dynamic> bibleContentsJson = [];
    for(int i = 0 ; i < widget.userReadNumber ; i++){
      bibleContentsJson.addAll(_bibleJson["m"+calDate.month.toString() + "d" + calDate.day.toString()]["contents"]);
      calDate = calDate.add(Duration(days:1));
    }


    Future<String> cvtFutureString(String str) async{
      return await str;
    }
    print("userFontSize : ${widget.userFontSize}");
    //calendar page
    final List<Widget> biblePageList= [
      Container(
        child: Column(
                  children: [
                    Consumer(
                          builder: (context, ref, child) {
                            ref.listen<AsyncValue>(
                              readControllerProvider,
                                  (_, state) =>
                                  state.showAlertDialogOnError(context),
                            );
                            return FutureBuilder(
                                future: ref.read(readControllerProvider.notifier).getRead(),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if(snapshot.hasData != false){
                                  _selectedDays.clear();
                                  _readDays.clear();
                                  snapshot.data.forEach((element) {
                                    _readDays.add(element);
                                  });
                                  print(" _readDays : $_readDays");
                                  _readDays.forEach((element) {
                                    _selectedDays.add(element);
                                  }); // CircularProgressIndicator : 로딩 에니메이션
                                }

                                return Card(
                                    margin: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Colors.grey, //<-- SEE HERE
                                      ), //모서리를 둥글게 하기 위해 사용
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: TableCalendar<Event>(
                                      sixWeekMonthsEnforced: true,
                                      // 추가
                                      headerStyle: HeaderStyle(
                                        titleCentered: true,
                                        titleTextFormatter: (date, locale) =>
                                            DateFormat.yMMMM(locale).format(date),
                                        formatButtonVisible: false,
                                        titleTextStyle: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.cyan,
                                        ),
                                        headerPadding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
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
                                          isTodayHighlighted: false,
                                          markerDecoration: BoxDecoration(
                                              color: Colors.deepPurpleAccent,
                                              shape: BoxShape.circle),
                                          selectedDecoration: BoxDecoration(
                                              color: Colors.cyan,
                                              shape: BoxShape.circle)
                                      ),
                                      firstDay: kFirstDay,
                                      lastDay: kLastDay,
                                      focusedDay: _focusedDay,
                                      eventLoader: (day) {
                                        if (day.year == _focusedDay.year &&
                                            day.month == _focusedDay.month &&
                                            day.day == _focusedDay.day) {
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
                                      onDaySelected: (DateTime selectedDay,
                                          DateTime focusedDay) async {
                                        List<DateTime> dateTimeList = await ref
                                            .read(readControllerProvider.notifier)
                                            .getRead();
                                        setState(() {
                                          _focusedDay = focusedDay;
                                          _selectedDays.clear();
                                          dateTimeList.forEach((element) {
                                            _readDays.add(element);
                                          });
                                          _readDays.forEach((element) {
                                            _selectedDays.add(element);
                                          });
                                        });
                                        getBibleList(_focusedDay);
                                        getBibleContentsList(_focusedDay);
                                        _selectedEvents.value =
                                            _getEventsForDays(_selectedDays);
                                      },
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
                                    )
                                );
                            });


                          }),

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
                                        color: Colors.grey
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
                )

      ),

    ];

    //bible script page
    for(int i = 0 ; i < bibleContentsJson.length ; i++){
      List<Widget> tmp = [];
      tmp.add(
          Text(
            bibleContentsJson[i]["chapter_name"],
            style: TextStyle(
                height: 2,
                fontSize: widget.userFontSize.toDouble() * 1.8,
                fontWeight: FontWeight.bold
            ),
          )
      );
        for(int j = 0 ; j < bibleContentsJson[i]["paragraphs"].length ; j++){
          if(bibleContentsJson[i]["paragraphs"][j]["title"].length > 0){
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

          }
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
    final Widget lastPage = Container(
      child: Consumer(
        builder: (context, ref, child){
          ref.listen<AsyncValue>(
            readControllerProvider,
                (_, state) => state.showAlertDialogOnError(context),
          );
          print(_selectedDays);
          return Container(
            child: Column(
              children: [

                IconButton(onPressed: () async{
                  String userDate = await widget._userReadDate;
                  print("userDate $userDate");
                  List<DateTime> dateTimeList = [];
                  if(userDate.length > 1){
                    List<String> userDateList = userDate.split(',');
                    for(var i = 0 ; i < userDateList.length ; i ++)
                    {
                      List<String> tmp = userDateList[i].split('/');
                      int yy = int.parse(tmp[0]);
                      int MM = int.parse(tmp[1]);
                      int dd = int.parse(tmp[2]);
                      dateTimeList.add(DateTime(yy,MM,dd));
                    }

                  }
                  print("datetimelist $dateTimeList");
                  print("_focusedDay $_focusedDay");
                  bool redundant = false;
                  for(var i = 0 ; i < dateTimeList.length ; i++){
                    if(DateFormat('yyyy/MM/dd,').format(dateTimeList[i]) == DateFormat('yyyy/MM/dd,').format(_focusedDay))
                      redundant = true;
                  }
                  if(redundant){
                    print("delete read Date");
                    String userReadDates = "";
                    DateTime foDate = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
                    setState(() {
                      _selectedDays.remove(foDate);
                      dateTimeList.remove(foDate);

                    });
                    dateTimeList.forEach((element) {userReadDates += DateFormat('yyyy/MM/dd,').format(element); });
                    if(userReadDates.length > 1)
                      userReadDates = userReadDates.substring(0, userReadDates.length - 1);
                    print("_selectedDays : {$_selectedDays}");
                    print("add read dates to firestore : {$userReadDates}");


                    ref.read(readControllerProvider.notifier).addRead(userReadDates);
                  }
                  else{
                    String userReadDates = "";
                    setState(() {
                      _selectedDays.add(_focusedDay);
                      dateTimeList.add(_focusedDay);

                    });
                    dateTimeList.forEach((element) {userReadDates += DateFormat('yyyy/MM/dd,').format(element); });
                    userReadDates = userReadDates.substring(0, userReadDates.length - 1);

                    print("add read dates to firestore : {$userReadDates}");
                    ref.read(readControllerProvider.notifier).addRead(userReadDates);

                  }

                  },
                    icon: _selectedDays.contains(_focusedDay)?
                    Icon(Icons.check_box_rounded,
                    size: 100,):
                    Icon(Icons.check_box_outline_blank_rounded,
                    size:100)
                    )
              ],
            ),
          );
        },
      ),
    );

    biblePageList.add(lastPage);

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



// class ReadScreen extends ConsumerWidget{
//   const ReadScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref)  {
//     // TODO: implement build
//
//     final state = ref.watch(readControllerProvider);
//     final readRepository = ref.watch(readRepositoryProvider);
//     int _userFontSize = readRepository.getReadFontSize();
//     int _userReadNumber = readRepository.getReadNumber();
//
//     // final userInfo = {
//     //   "ReadFontSize" : readRepository.getReadFontSize()
//     // };
//     Future<List<bool>> _getSelectedNumber(num) async {
//       List<bool> tmp = [false,false,false];
//       tmp[num] = true;
//       return tmp;
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(Strings.read),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.settings),
//             onPressed: () async{
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   // return object of type Dialog
//                   return AlertDialog(
//                     backgroundColor: Colors.deepPurple,
//                     title:  Container(
//
//                         alignment: Alignment.center,
//                         child: Text(
//                           "설정",
//                           style:TextStyle(
//                             fontSize: 32,
//                             color: Colors.cyan,
//                           ),
//                         )
//                     ),
//                     content: Container(
//
//                         child: Row(
//                           children: [
//                             Text(
//                               "통독 플랜",
//                               style:TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.cyan,
//                               ),
//                             ),
//                             // TextButton(
//                             //     onPressed: ()async{
//                             //       await ref.read(readControllerProvider.notifier).setReadNumber(1);
//                             //     },
//                             //     child: Text('1독')
//                             // ),
//                             // TextButton(
//                             //     onPressed: ()async{
//                             //       await ref.read(readControllerProvider.notifier).setReadNumber(1);
//                             //     },
//                             //     child: Text('2독')
//                             // ),
//                             // TextButton(
//                             //     onPressed: ()async{
//                             //       await ref.read(readControllerProvider.notifier).setReadNumber(1);
//                             //     },
//                             //     child: Text('3독')
//                             // ),
//                             ToggleButtons(
//                               color: Colors.black.withOpacity(0.60),
//                               selectedColor: Color(0xFF6200EE),
//                               selectedBorderColor: Color(0xFF6200EE),
//                               fillColor: Color(0xFF6200EE).withOpacity(0.08),
//                               splashColor: Color(0xFF6200EE).withOpacity(0.12),
//                               hoverColor: Color(0xFF6200EE).withOpacity(0.04),
//                               borderRadius: BorderRadius.circular(4.0),
//                               constraints: BoxConstraints(minHeight: 36.0),
//                               isSelected: isSelected,
//                               onPressed: (index)async{
//                                 await ref.read(readControllerProvider.notifier).setReadNumber(index);
//                                 isSelected = <bool>[false, false, false];
//                                 isSelected[index] = true;
//                               },
//                               children: [
//                                 Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
//                                   child: Text('1독'), ),
//                                 Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
//                                   child: Text('2독'), ),
//                                 Padding( padding: EdgeInsets.symmetric(horizontal: 16.0),
//                                   child: Text('3독'),
//                                 ),
//                               ],
//                             )
//                           ],
//                         )
//
//                     ),
//                     actions: <Widget>[
//                       // usually buttons at the bottom of the dialog
//                       new TextButton(
//                         child: new Text("Close"),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () async{
//               await ref.read(readControllerProvider.notifier).clickFontPlus();
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.remove),
//             onPressed: () async{
//               await ref.read(readControllerProvider.notifier).clickFontMinus();
//             },
//           )
//         ],
//       ),
//       body: Calendar(_userFontSize),
//     );
//   }
// }


