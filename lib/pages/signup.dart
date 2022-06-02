import 'package:csci4100_major_project/pages/login.dart';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Signup extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<Signup> {
  final GlobalKey<FormState> _signupKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  String errorMessage = "";

  late CollectionReference<Map<String, dynamic>> profilePictures =
      FirebaseFirestore.instance.collection("profile-pictures");

  late CollectionReference<Map<String, dynamic>> credentials =
      FirebaseFirestore.instance.collection("credentials");

  void verifyFields(QuerySnapshot credentialsQuery) async {
    if (!credentialsQuery.docs.isNotEmpty &&
        passwordController.text == confirmController.text &&
        passwordController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        confirmController.text.isNotEmpty) {
      await credentials.add({
        "username": usernameController.text,
        "password": passwordController.text
      });

      await profilePictures.add({
        //default profile pic
        "profilePicURL":
            "https://spaceplace.nasa.gov/templates/featured/sun/all-about-the-sun300.jpg",
        "username": usernameController.text
      });

      var profilePicQuery = await profilePictures
          .where("username", isEqualTo: usernameController.text)
          .limit(1)
          .get();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: Login(),
          ),
        ),
      );
    } else if (passwordController.text != confirmController.text) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.passwordsDoNotMatch;
      });
    } else if (passwordController.text.isEmpty ||
        usernameController.text.isEmpty ||
        confirmController.text.isEmpty) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.fieldsAreEmpty;
      });
    } else {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.usernameAlreadyTaken;
      });
    }
  }

  void processSignup() async {
    QuerySnapshot credentialsQuery = await credentials
        .where("username", isEqualTo: usernameController.text)
        .get();

    verifyFields(credentialsQuery);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: credentials.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              resizeToAvoidBottomInset: false,
              body: Container(
                padding: EdgeInsets.all(20.0),
                child: Form(
                  key: _signupKey,
                  child: ListView(children: <Widget>[
                    Center(
                      child: Text(AppLocalizations.of(context)!.signup,
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.userNameDot),
                    SizedBox(width: 13),
                    TextFormField(
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username cannot be empty';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder())),
                    SizedBox(height: 10),
                    Text(AppLocalizations.of(context)!.passworddoted),
                    SizedBox(width: 15),
                    TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .passwordCannotBeEmpty;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder())),
                    SizedBox(height: 10),
                    Text(AppLocalizations.of(context)!.confirm), //confirm
                    SizedBox(width: 26),
                    TextFormField(
                        controller: confirmController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            border: OutlineInputBorder())),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Text(errorMessage,
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        minWidth: 500,
                        textColor: Colors.white,
                        color: Colors.black,
                        child: Text(AppLocalizations.of(context)!.signup),
                        onPressed: () {
                          processSignup();
                        },
                      ),
                    )
                  ]),
                ),
              ));
        });
  }
}
