import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_exception.dart';

class UserExceptionNotifier extends Notifier<UserException?> {
  @override
  UserException? build() {
    return null;
  }

  void setException(UserException exception) {
    state = exception;
  }
}

final userExceptionProvider =
    NotifierProvider<UserExceptionNotifier, UserException?>(
        UserExceptionNotifier.new);
