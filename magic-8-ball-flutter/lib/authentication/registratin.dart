import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController emailCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  TextEditingController nameCont = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isObsecure = true;
  File _image;
  bool isloading = false;
  bool userValid = false;

  String _email;
  String _password;
  String _name;

  _showsnack(String val) {
    final snackbar = SnackBar(
      content: Text(
        val,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  newUser() async {
    setState(() {
      isloading = true;
      userValid = false;
    });

    if (_formKey.currentState.validate()) {
      try {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
            email: emailCont.text, password: passCont.text);
        User user = result.user;
        if (user != null) {
          setState(() {
            userValid = true;
          });
        } else {
          setState(() {
            userValid = false;
          });
        }

        print(user.email);
        _showsnack(user.email);
      } catch (e) {
        if (e is PlatformException) {
          if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
            return _showsnack('User with Email Already exists');
          }
        }
      }
      setState(() {
        isloading = false;
      });
      userValid
          ? Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserLanding(),
              ),
            )
          : null;
    }

    //Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.getWhiteColor(),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(18.0),
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  regScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  regScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 70.0, top: 23.0),
            alignment: Alignment.bottomLeft,
            child: Text(
              'Register your account ',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 34.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 14.0),
            child: GestureDetector(
              onTap: () {
                final action = CupertinoActionSheet(
                  title: Text('Photo'),
                  message: Text('Choose a Profile Photo'),
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      onPressed: () => print('cam'),
                      child: Text('Camera'),
                    ),
                    CupertinoActionSheetAction(
                      onPressed: () => print('gal'),
                      child: Text('Gallery'),
                    ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
                showCupertinoModalPopup(
                    context: context, builder: (context) => action);
              },
              child: CircleAvatar(
                radius: 34.0,
                backgroundColor: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 23.0),
            child: TextFormField(
              onSaved: (_input) {
                setState(() {
                  _name = _input;
                });
              },
              validator: (_input) {
                return _input.length != 0 ? null : 'Please Enter a Name';
              },
              controller: nameCont,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  prefixIcon: Icon(Icons.near_me),
                  hintText: 'Name',
                  labelText: 'Name'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 23.0),
            child: TextFormField(
              validator: (_input) {
                return _input.contains('@') && _input.length > 8
                    ? null
                    : 'Enter a Valid Email';
              },
              onSaved: (_input) {
                setState(() {
                  _email = _input;
                });
              },
              controller: emailCont,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Email',
                  labelText: 'Email'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 23.0),
            child: TextFormField(
              validator: (_input) {
                return _input.length == 6 && _input.length < 7
                    ? 'Use at least 7 Characters'
                    : null;
              },
              onSaved: (_input) {
                setState(() {
                  _password = _input;
                });
              },
              obscureText: isObsecure,
              controller: passCont,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: GestureDetector(
                    child: Icon(
                        isObsecure ? Icons.visibility : Icons.visibility_off),
                    onTap: () {
                      setState(() {
                        isObsecure = !isObsecure;
                      });
                    },
                  ),
                  hintText: 'Password',
                  labelText: 'Password'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: MaterialButton(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              onPressed: newUser,
              child:
                  isloading ? CupertinoActivityIndicator() : Text('Register'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13.0),
            child: FlatButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              ),
              child: Text('Already a User? Login'),
            ),
          ),
        ],
      ),
    );
  }
}
