import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

part 'auth_providers.g.dart';
const GOOGLE_CLIENT_ID = "hyungsuk0315@gmail.com";
@Riverpod(keepAlive: true)
List<AuthProvider<AuthListener, AuthCredential>> authProviders(
    AuthProvidersRef ref) {
  return [
    EmailAuthProvider(),
    GoogleProvider(clientId: GOOGLE_CLIENT_ID),
  ];
}
