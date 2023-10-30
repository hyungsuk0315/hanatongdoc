import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/features/read/data/read_repository.dart';

part 'read_controller.g.dart';

@riverpod
class ReadController extends _$ReadController {

  @override
  FutureOr<void> build() {

    // no op
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