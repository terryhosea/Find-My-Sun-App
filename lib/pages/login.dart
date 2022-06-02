import 'package:flutter/material.dart';
import 'package:csci4100_major_project/helpers/provider_helper.dart';
import 'package:provider/provider.dart';
import 'package:csci4100_major_project/pages/loader.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Login extends StatefulWidget {
  @override
  Login();

  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _loginKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late bool isStatusLogin = false;
  String isUnauthorized = "";
  late CollectionReference<Map<String, dynamic>> credentials =
      FirebaseFirestore.instance.collection("credentials");
  late CollectionReference<Map<String, dynamic>> profilePictures =
      FirebaseFirestore.instance.collection("profile-pictures");

  @override
  void initState() {
    super.initState();
  }

  void processLogin() async {
    QuerySnapshot credentialsQuery = await credentials
        .where("username", isEqualTo: usernameController.text)
        .where("password", isEqualTo: passwordController.text)
        .get();

    process(credentialsQuery);
  }

  void process(QuerySnapshot credentialsQuery) async {
    if (credentialsQuery.docs.isNotEmpty) {
      print("process credential");
      var profilePicQuery = await profilePictures
          .where("username", isEqualTo: usernameController.text)
          .limit(1)
          .get();
      context.read<ProviderHelper>().logIn(
            usernameController.text,
            profilePicQuery.docs[0].data()["profilePicURL"],
            profilePicQuery.docs[0].id,
          );
      isStatusLogin = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: Loader(),
          ),
        ),
      );
    } else {
      setState(() {
        isUnauthorized = "Credentials do not exist";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: 100),
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _loginKey,
            child: ListView(shrinkWrap: true, children: <Widget>[
              Center(
                  child: Text(AppLocalizations.of(context)!.login,
                      style: TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold))),
              SizedBox(height: 20),
              TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.userNameCap,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      border: OutlineInputBorder())),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Text(isUnauthorized,
                          style: TextStyle(color: Colors.red))),
                ],
              ),
              SizedBox(height: 10),
              Container(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minWidth: 200,
                  textColor: Colors.white,
                  color: Colors.black,
                  child: Text(AppLocalizations.of(context)!.login),
                  onPressed: () {
                    processLogin();
                  },
                ),
              )
            ]),
          ),
        ));
  }
}
