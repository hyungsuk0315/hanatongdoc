import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'read_repository.g.dart';


class ReadRepository {
  ReadRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;
  static const readFontSizeKey = "readfontsize";
  static const readNumberKey = "readnumber";

  int getReadFontSize() => sharedPreferences.getInt(readFontSizeKey) ?? 16;
  int getReadNumberSize() => sharedPreferences.getInt(readNumberKey) ?? 1;
  Future<void> fontSizeUp() async {
    await sharedPreferences.setInt(readFontSizeKey, getReadFontSize() + 1);
  }
  Future<void> fontSizeDown() async {
    await sharedPreferences.setInt(readFontSizeKey, getReadFontSize() - 1);
  }
  Future<void> setReadNumber(num) async {
    await sharedPreferences.setInt(readNumberKey, num);
  }

}

@Riverpod(keepAlive: true)
ReadRepository readRepository(ReadRepositoryRef ref) {
  throw UnimplementedError();
}