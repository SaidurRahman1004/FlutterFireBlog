import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges(); //When User Status Changed call Stram  //// A Stream to get the user's login status in real-time.  use this in AuthGate

  //SingUp With Name And Pass
  Future<User?> signUpWithEP(String name,String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);                   //// After creating the user, update the name (displayName) in their profile, this is what we will use as the authorName later
      return cred.user; //cerd = Credential
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Sing in With Email And Pass
  Future<User?> signInWithEP(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //Find Current Log in  User Getter
  User? get currentUser => _auth.currentUser;
}
