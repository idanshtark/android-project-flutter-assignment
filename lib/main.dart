import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/MySnappingSheet.dart';
import 'package:provider/provider.dart';
import 'Favorites.dart';
import 'FavoritesScreen.dart';
import 'LoginScreen.dart';
import 'UserRepository.dart';
import 'MySnappingSheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserRepository>.value(value: UserRepository.instance()),
        ChangeNotifierProxyProvider<UserRepository, Favorites>(
            create: (_) => Favorites(),
            update: (_, UserRepository user, Favorites fav) => fav..update(user)
        )
      ],
      child: MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Colors.red[600],
        ),
        home: RandomWords(),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    final UserRepository user = Provider.of<UserRepository>(context);
    return Scaffold (
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
          user.status != Status.Authenticated
          ? IconButton(
              icon: Icon(Icons.login, color: Colors.white),
              onPressed: _loginScreen
            )
          : Consumer<UserRepository>(
              builder: (context, UserRepository userRepo, _){
                return IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.white),
                  onPressed: () {
                    Provider.of<Favorites>(context, listen: false).cleanSaved();
                    user.signOut();
                  },
                );
              }
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    final UserRepository user = Provider.of<UserRepository>(context);
    return Stack(
      children: [
        ListView.builder(
            padding: const EdgeInsets.all(16),
            itemBuilder: (BuildContext _context, int i) {
              if (i.isOdd) {
                return Divider();
              }

              final int index = i ~/ 2;
              if (index >= _suggestions.length) {
                _suggestions.addAll(generateWordPairs().take(10));
              }
              return _buildRow(_suggestions[index]);
            }
        ),
        user.status == Status.Authenticated
        ? MySnappingSheet()
        : Container(),
      ],
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = Provider.of<Favorites>(context).saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            Provider.of<Favorites>(context, listen: false).removePair(pair);
          } else {
            Provider.of<Favorites>(context, listen: false).addPair(pair);
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: FavoritesScreen(),
          );
        },
      ),
    );
  }

  void _loginScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Text(
                    'Login'
                )
            ),
            body: LoginScreen(),
          );
        },
      ),
    );
  }
}
