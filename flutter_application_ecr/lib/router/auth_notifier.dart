import 'package:flutter/foundation.dart';

class AuthNotifier extends ChangeNotifier {
  static final AuthNotifier instance = AuthNotifier._();
  AuthNotifier._();

  void notifySessionExpired() => notifyListeners();
}
