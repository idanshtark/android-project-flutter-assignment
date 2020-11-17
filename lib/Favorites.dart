import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UserRepository.dart';

class Favorites with ChangeNotifier {

  String _userId;
  UserRepository _user;
  Set<WordPair> _saved = Set<WordPair>();
  CollectionReference _collection = FirebaseFirestore.instance.collection(
      'usersInfo');

  Set<WordPair> get saved => _saved;
  CollectionReference get favorites => _collection;


  void update (UserRepository user) async {
    _user = user;
    _userId = user.userId;

    if (_user.status == Status.Authenticated) {
      DocumentSnapshot wordsCollection = await _collection.doc(_userId).get();
      if (wordsCollection.exists == false) {
        await _collection.doc(_userId).set({'favoriteWords': []});
      }

      //get all pairs from local
      await _collection
      .doc(_userId)
      .update({'favoriteWords' : FieldValue.arrayUnion(List<dynamic>
      .from(_saved.map((wordPair) => {'prefix': wordPair.first, 'suffix': wordPair.second})))
      });

        //merge local and Firebase into _saved (local)
      _saved = await _collection
        .doc(_userId)
        .get()
        .then((collection) => collection.data())
        .then((usersFavoriteCollection) => usersFavoriteCollection == null
        ? Set<WordPair>()
        : Set<WordPair>.from(usersFavoriteCollection['favoriteWords'].map((element) => WordPair(element['prefix'], element['suffix']))));
    }

      notifyListeners();
  }

  void removePair(WordPair pair) async{
    _saved.remove(pair);
    if (_user.status == Status.Authenticated){
      await _collection.doc(_userId).update({'favoriteWords': FieldValue.arrayRemove([{'prefix': pair.first.toString(), 'suffix': pair.second.toString()}])});
    }

    notifyListeners();
  }

  void addPair(WordPair pair) async{
    _saved.add(pair);
    if (_user.status == Status.Authenticated){
       await _collection.doc(_userId).update({'favoriteWords': FieldValue.arrayUnion([{'prefix': pair.first.toString(), 'suffix': pair.second.toString()}])});
    }

    notifyListeners();
  }

  void cleanSaved(){
    _saved.clear();

    notifyListeners();
  }

}
