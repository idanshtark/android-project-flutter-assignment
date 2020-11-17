import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Status { Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  String _userId;
  String _userEmail;
  String _userPic;
  Status _status = Status.Unauthenticated;
  CollectionReference _collection =
      FirebaseFirestore.instance.collection('usersInfo');

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  String get userId => _userId;
  Status get status => _status;
  User get user => _user;
  String get userEmail => _userEmail;
  String get userPic => _userPic;
  FirebaseAuth get auth => _auth;

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
      _userId = firebaseUser.uid;
      _userEmail = firebaseUser.email;
      _userPic = await getUserPic();
    }
    notifyListeners();
  }

  void setPicture(String picPath) async {
    _userPic = picPath;
    await _collection.doc(_userId).set({'picture': picPath});
    notifyListeners();
  }

  Future<String> getUserPic() async {
    return _collection
        .doc(_userId)
        .get()
        .then((userId) => userId.data())
        .then((userInfo) => userInfo != null
        ? userInfo['picture'].toString()
        : "https://www.cs.technion.ac.il/~colloq/newbuilding.jpg" );
  }
}
