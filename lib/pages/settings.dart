import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import '../helpers/provider_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  dynamic imageFile;
  bool savingSettings = false;

  late CollectionReference<Map<String, dynamic>> profilePictures =
      FirebaseFirestore.instance.collection("profile-pictures");

  void _openPicker(BuildContext context, bool gallery) async {
    final pickedFile = await ImagePicker().pickImage(
      source: gallery ? ImageSource.gallery : ImageSource.camera,
    );

    Navigator.pop(context);

    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  Future<String> uploadFile() async {
    Reference storageRef = FirebaseStorage.instance.ref().child(
        "profile-pictures/${path.basename(context.read<ProviderHelper>().userName)}");

    UploadTask uploadTask = storageRef.putFile(imageFile);

    String returnURL = await (await uploadTask).ref.getDownloadURL();
    return returnURL.toString();
  }

  @override
  Widget build(BuildContext context) {
    String avatarURL = context.watch<ProviderHelper>().avatarURL;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        actions: [
          savingSettings
              ? Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: SpinKitCircle(
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.check,
                  ),
                  onPressed: () async {
                    setState(() {
                      savingSettings = true;
                    });
                    if (imageFile != null) {
                      String newURL = await uploadFile(); //todo
                      await profilePictures
                          .doc(context.read<ProviderHelper>().profilePicID)
                          .update({'profilePicURL': newURL})
                          .then((value) {})
                          .catchError(
                              (error) => print("Failed to update: $error"));

                      context.read<ProviderHelper>().updateAvatarURL(newURL);
                    }
                    setState(() {
                      savingSettings = false;
                    });
                  },
                )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          CircleAvatar(
            backgroundImage: imageFile == null
                ? NetworkImage(avatarURL)
                : Image.file(imageFile).image,
            radius: 50,
          ),
          Center(
            child: TextButton(
              child: Text(AppLocalizations.of(context)!.changeProfilePhoto),
              onPressed: () => savingSettings
                  ? null
                  : showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 175,
                          child: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15.0, 10.0, 10.0, 10.0),
                                  child: Text(
                                    AppLocalizations.of(context)!.chooseSource,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    _openPicker(context, true);
                                  },
                                  title: Text(
                                      AppLocalizations.of(context)!.gallery),
                                  leading: Icon(
                                    Icons.account_box,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: Colors.blue,
                                ),
                                ListTile(
                                  onTap: () {
                                    _openPicker(context, false);
                                  },
                                  title: Text(
                                      AppLocalizations.of(context)!.camera),
                                  leading: Icon(
                                    Icons.camera_alt,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Divider(
            height: 10,
            thickness: 1,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(width: 20),
              Text(
               AppLocalizations.of(context)!.userName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 50,
              ),
              Text(
                context.read<ProviderHelper>().userName,
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
