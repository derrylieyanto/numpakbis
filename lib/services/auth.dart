import 'package:firebase_auth/firebase_auth.dart';
import 'package:numpakbis/models/user.dart';
import 'package:numpakbis/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on FireBaseUser
  User _userFromFireBaseUser(FirebaseUser user){
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
        .map(_userFromFireBaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFireBaseUser(user);
    }catch(e) {
      print(e.toString());
      return null;
    }
  }


  //sign in email with pass
  Future signInEmailPass(String email, String password) async{
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFireBaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //register with email and pass
  Future registerEmailPass(String email, String password, String name, String noHP) async{
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      //create a new doc for the user with the uid
      await DatabaseService(uid: user.uid).updateUserData(name, email, noHP, 'member');

      return _userFromFireBaseUser(user);

    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async{
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

}