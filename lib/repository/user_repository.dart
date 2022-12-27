import 'package:firebase_auth/firebase_auth.dart';

abstract class IUserRepository {
  User? fetchCurrentUser();
}

class UserRepository implements IUserRepository {
  @override
  User fetchCurrentUser() {
    return FirebaseAuth.instance.currentUser!;
  }
}
