import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../helpers/provider_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class showPostDialog extends StatefulWidget {
  CollectionReference<Map<String, dynamic>> messages;
  Function updateUploadState;
  showPostDialog(
      {Key? key, required this.messages, required this.updateUploadState})
      : super(key: key);

  @override
  State<showPostDialog> createState() => _showPostDialogState();
}

class _showPostDialogState extends State<showPostDialog> {
  dynamic imageFile;
  TextEditingController descriptionController = new TextEditingController();
  double dialogHeight = 0;

  void _openPicker(BuildContext context, bool gallery) async {
    final pickedFile = await ImagePicker().pickImage(
      source: gallery ? ImageSource.gallery : ImageSource.camera,
    );
    setState(() {
      imageFile = File(pickedFile!.path);
    });
    Navigator.pop(context);
  }

  Future<Position> _getLatLong() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    Geolocator.requestPermission();

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Future<String> uploadFile(File _image) async {
    Reference storageRef =
        FirebaseStorage.instance.ref().child("post/${basename(_image.path)}");

    UploadTask uploadTask = storageRef.putFile(_image);
    String returnURL = await (await uploadTask).ref.getDownloadURL();
    return returnURL.toString();
  }

  @override
  Widget build(BuildContext context) {
    dialogHeight = MediaQuery.of(context).size.height - 525;

    Widget composePostContent = ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: 10),
        TextFormField(
          controller: descriptionController,
          maxLength: 250,
          keyboardType: TextInputType.multiline,
          maxLines: 8,
          cursorColor: Theme.of(context).colorScheme.primary,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.whatsHappening,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            isDense: true,
            labelText: AppLocalizations.of(context)!.description,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        (imageFile == null)
            ? Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text(AppLocalizations.of(context)!.chooseImage),
                  onPressed: () {
                    showModalBottomSheet<void>(
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
                    );
                  },
                ),
              )
            : Stack(
                children: [
                  Card(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.file(
                        File(imageFile.path),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          imageFile = null;
                        });
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 14.0,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addPost),
      contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      actionsPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      buttonPadding: EdgeInsets.fromLTRB(0, 0, 10, 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      content: Builder(
        builder: (context) {
          var width = MediaQuery.of(context).size.width;

          return Container(
            height: dialogHeight,
            width: width,
            child: composePostContent,
          );
        },
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10),
              child: TextButton(
                onPressed: () async {
                  return Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: TextButton(
                onPressed: () async {
                  widget.updateUploadState(true);
                  if (descriptionController.text.isNotEmpty &&
                      imageFile != null) {
                    DateTime now = DateTime.now();
                    String formattedDate =
                        DateFormat('dd/MM/yyyy HH:mm').format(now);
                    var coordinates = await _getLatLong();
                    Navigator.pop(context);
                    await widget.messages.add({
                      "message": descriptionController.text,
                      "username": context.read<ProviderHelper>().userName,
                      "latitude": coordinates.latitude,
                      "longitude": coordinates.longitude,
                      "datetime": formattedDate,
                      "timestamp": Timestamp.now(),
                      "imageURL": await uploadFile(imageFile),
                    });
                  }
                  widget.updateUploadState(false);
                },
                child: Text(AppLocalizations.of(context)!.post),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
