import 'package:flutter/material.dart';
import 'package:hello_me/MyBottomSheet.dart';
import 'package:hello_me/UserRepository.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController get email => _email;
  TextEditingController get password => _password;
  @override
  Widget build(BuildContext context) {
    final UserRepository user = Provider.of<UserRepository>(context, listen: false);
    return Wrap(
      children: [
        Container(
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Welcome to Startup Names Generator, please log in below',
                    style: TextStyle(fontSize: 16.5),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: _email,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        fontSize: 17
                      )
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                          fontSize: 17
                      )
                    ),
                  ),
                  SizedBox(height: 20.0),
                  user.status == Status.Authenticating
                  ? Consumer<UserRepository>(
                      builder: (context, UserRepository userRepo, _) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]),
                          ),
                        );
                      }
                  )
                  : Consumer<UserRepository>(
                      builder: (context, UserRepository userRepo, _) {
                        return Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.red[600],
                          child: MaterialButton(
                            minWidth: MediaQuery
                                .of(context)
                                .size
                                .width,
                            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            onPressed: () async {
                              if (await user.signIn(_email.text, _password.text) == false) {
                                final badLogin = SnackBar(
                                  content: Text(
                                      'There was an error logging into the app'),
                                );
                                Scaffold.of(context).showSnackBar(badLogin);
                              }
                              else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text("Log in",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        );
                      }
                  ),
                  SizedBox(height: 14.0),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.teal,
                    child: MaterialButton(
                      minWidth: MediaQuery
                          .of(context)
                          .size
                          .width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => MyBottomSheet(_email.text, password.text),
                      ),
                      child: Text("New user? Click to sign up",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
      ],
    );
  }

  @override
  void dispose(){
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}