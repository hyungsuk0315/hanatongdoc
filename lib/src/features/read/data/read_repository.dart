import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../authentication/domain/app_user.dart';

part 'read_repository.g.dart';


class ReadRepository {
  ReadRepository(this.sharedPreferences, this._firestore);
  final SharedPreferences sharedPreferences;
  final FirebaseFirestore _firestore;
  static const readFontSizeKey = "readfontsize";
  static const readNumberKey = "readnumber";

  static String readPath(String uid) => 'users/$uid/read';
  static String memoPath(String uid) => 'users/$uid/memoPath';

  int getReadFontSize() => sharedPreferences.getInt(readFontSizeKey) ?? 16;
  int getReadNumber() => sharedPreferences.getInt(readNumberKey) ?? 1;
  String getUserUid(uid) => uid;

  Future<void> fontSizeUp() async {
    await sharedPreferences.setInt(readFontSizeKey, getReadFontSize() + 1);
  }
  Future<void> fontSizeDown() async {
    await sharedPreferences.setInt(readFontSizeKey, getReadFontSize() - 1);
  }
  Future<void> setReadNumber(num) async {
    await sharedPreferences.setInt(readNumberKey, num );
  }
  // create
  Future<void> addReadDate({required UserID uid,
    required String readDate}) =>
      _firestore.collection(readPath(uid)).doc('read').set({
        'read': readDate,
      });
  // get dates
  Future<String> getReadDate({required UserID uid}) =>
      _firestore.collection(readPath(uid)).doc('read').get().then(
            (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data["read"];
          // ...
        },
        onError: (e) => print("Error getting document: $e"),
      );


}

@Riverpod(keepAlive: true)
ReadRepository readRepository(ReadRepositoryRef ref) {
  throw UnimplementedError();
}