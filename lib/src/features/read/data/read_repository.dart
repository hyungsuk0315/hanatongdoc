import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'read_repository.g.dart';


class ReadRepository {
  ReadRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;
  static const readFontSizeKey = "readfontsize";

  int getReadFontSize() => sharedPreferences.getInt(readFontSizeKey) ?? 16;
  Future<void> fontSizeUp() async {
    await sharedPreferences.setInt(readFontSizeKey, getReadFontSize() + 1);
  }
  Future<void> fontSizeDown() async {
    await sharedPreferences.setInt(readFontSizeKey, getReadFontSize() - 1);
  }

}

@Riverpod(keepAlive: true)
ReadRepository readRepository(ReadRepositoryRef ref) {
  throw UnimplementedError();
}