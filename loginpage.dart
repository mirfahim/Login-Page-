import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../sharePreference.dart';
import 'homepage.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isprocesscomplete = false;
  TextEditingController _userController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String BaseUrl = "http://www.accounting.emicrodev.com/api/login";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(
                  height: 30,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    height: 220,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: TextField(
                            controller: _userController,
                            decoration: InputDecoration(hintText: "username"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(hintText: "Password"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    color: Colors.lightBlue,
                    onPressed: () {
                      if (_userController.text == "" ||
                          _passwordController.text == "") {
                        final snackBar = SnackBar(
                            content: Text("Enter Username and Password"));
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      } else {
                        signIn(_userController.text, _passwordController.text);
                      }
                    },
                    child: ProgressButton(),
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(16),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  child: Text("Forgot password"),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget ProgressButton() {
    if (isprocesscomplete != false) {
      return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
    } else {
      return new Text(
        "Sign In",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15.0,
        ),
      );
    }
  }

  void signIn(String username, String password) async {
    setState(() {
      isprocesscomplete = true;
    });
    var response = await http.post(BaseUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "password": password,
        }));

    Map<String, dynamic> value = json.decode(response.body);
    // print('Respone ${response.body}');
    if (response.statusCode == 200) {
      try {
        ///You don't need it but it will be cool for show progress dialgo for 4 second then redirect even if we get reslut
        Future.delayed(Duration(seconds: 4), () {
          // 5s over make it false
          setState(() {
            isprocesscomplete = false;
          });
        });

        Map<String, dynamic> value = json.decode(response.body);
        print('Respone ${response.body}');
        SharedPrefrence().setToken(value['api_token'].toString());
        SharedPrefrence().setName(value['name']);
        SharedPrefrence().setUserId(value['id'].toString());

        ///This is used when user loged in you can set this true,
        ///next time you open you need to check loginc in main.dart or splashscreen if this is true if it is true then
        ///redirect to home page it is false then redirect to Login page
        ///When you logout the app make sure you set this as false like "SharedPrefrence().setLoggedIn(false);"
        SharedPrefrence().setLoggedIn(true);

        ///Redirect to Home page
        Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                      
                                    )),
                                ModalRoute.withName("/login"));

      } catch (e) {
        e.toString();
        final snackBar =
        SnackBar(content: Text("something wrong,Try again 😑"));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    } else {
      var message = value['error'];
      final snackBar = SnackBar( backgroundColor: Colors.redAccent[700],
          content: Text(message.toString()));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}
