import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'Favorites.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return favoriteScreen();
  }

  Widget favoriteScreen(){
    final TextStyle _biggerFont = const TextStyle(fontSize: 18);
    Set<WordPair> _saved = Provider.of<Favorites>(context).saved;
    final tiles = _saved.map(
      (WordPair pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
          trailing: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: () {
                  Provider.of<Favorites>(context, listen: false).removePair(pair);
                },
              );
            },
          ),
        );
      },
    );

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return ListView(children: divided);
  }
}