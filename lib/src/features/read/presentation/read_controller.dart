import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/features/read/data/read_repository.dart';

import '../../authentication/data/firebase_auth_repository.dart';

part 'read_controller.g.dart';

@riverpod
class ReadController extends _$ReadController {

  @override
  FutureOr<void> build() {

    // no op
  }
  Future<void> addRead(String readDates) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }
    final repository = ref.read(readRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
            () => repository.addReadDate(uid: currentUser.uid, readDate: readDates));
  }

  Future<List<DateTime>> getRead() async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }
    final repository = ref.read(readRepositoryProvider);
    String dates = await repository.getReadDate(uid: currentUser.uid);
    List<String> dateList = dates.split(',');
    List<DateTime> DateTimeList = [];
    for(var i = 0 ; i < dateList.length ; i++)
    {
        List<String> dateSplit = dateList[i].split('/');
        String yy = dateSplit[0];
        String MM = dateSplit[1];
        String dd = dateSplit[2];
        DateTimeList.add(DateTime(int.parse(yy),int.parse(MM),int.parse(dd)));
    }
    return DateTimeList;
  }
  Future<void> clickFontPlus() async {
    final readRepository = ref.watch(readRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(readRepository.fontSizeUp);
  }
  Future<void> clickFontMinus() async {
    final readRepository = ref.watch(readRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(readRepository.fontSizeDown);
  }
  Future<int> loadFontsize() async {
    final readRepository = ref.watch(readRepositoryProvider);
    return readRepository.getReadFontSize();
  }
  Future<void> setReadNumber(num) async {
    final readRepository = ref.watch(readRepositoryProvider);
    readRepository.setReadNumber(num);
  }
  Future<int> getReadNumber() async {
    final readRepository = ref.watch(readRepositoryProvider);
    return readRepository.getReadNumber();
  }
}