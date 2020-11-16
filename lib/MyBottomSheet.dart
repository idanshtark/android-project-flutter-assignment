import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserRepository.dart';

class MyBottomSheet extends StatefulWidget {
  final String email;
  final String password;
  MyBottomSheet(String email, String password):
        email = email,
        password = password;
  @override
  _MyBottomSheetState createState() => _MyBottomSheetState(email, password);
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  TextEditingController _validation = TextEditingController();
  bool _samePassword = true;
  final String email;
  final String password;
  _MyBottomSheetState(String email, String password) :
    email = email,
    password = password;
  @override
  Widget build(BuildContext context) {
    final UserRepository user = Provider.of<UserRepository>(context, listen: false);
    return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Wrap(
          children: [
            Column(
              children: [
                SizedBox(
                    height: 8
                ),
                Container(
                    height: 33,
                    padding: EdgeInsets.all(8.0),
                    child: Text('Please confirm your password below:', style: TextStyle(fontSize: 15))
                ),
                Divider(
                  indent: 9,
                  endIndent: 9,
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4,left: 9, right: 9),
                    child: TextField(
                      controller: _validation,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                              fontSize: 17
                          ),
                          errorText: _samePassword == false ? "Passwords must match": null
                      ),
                    ),
                  ),
                ),
                Divider(
                  indent: 9,
                  endIndent: 9,
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  child: FlatButton(
                      height: 40,
                      color: Colors.teal,
                      child: Text("Confirm",
                        style: TextStyle(color: Colors.white, fontSize: 16.5),
                      ),
                      onPressed: () async {
                        if (_validation.text == password) {
                          setState(() {
                            _samePassword = true;
                          });
                          await user.auth.createUserWithEmailAndPassword(email: email, password: password);
                          user.setPicture("https://www.cs.technion.ac.il/~colloq/newbuilding.jpg");
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            _samePassword = false;
                          });
                        }
                      }
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ],
        ),
    );
  }

  @override
  void dispose(){
    _validation.dispose();
    super.dispose();
  }

}