import 'package:flutter/material.dart';

import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:google_fonts/google_fonts.dart';
import '../helpers/provider_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Message extends StatelessWidget {
  late String userLongName;
  late String timeString;
  late String description;
  late String imageURL;
  late String messageId;
  CollectionReference messages;
  Function updateDeleteState;

  Message(this.userLongName, this.timeString, this.description, this.imageURL,
      this.messageId, this.messages, this.updateDeleteState);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10, 10, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.white.withOpacity(0.6),
        child: Stack(
          children: [
            if (userLongName == context.watch<ProviderHelper>().userName)
              Positioned(
                top: 10,
                right: 2,
                child: PopupMenuButton(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: ListTile(
                          dense: true,
                          onTap: () {
                            Navigator.pop(context);
                            showAnimatedDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ), //this right here
                                  child: Container(
                                    height: 150,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          TextField(
                                            textAlign: TextAlign.center,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: 2,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: AppLocalizations.of(
                                                        context)!
                                                    .areYouSureYouWantToDeleteThisPost),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              ElevatedButton(
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .cancel),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ElevatedButton(
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .confirm), //confirm
                                                onPressed: () async {
                                                  updateDeleteState(true);
                                                  Navigator.pop(context);
                                                  await messages
                                                      .doc(messageId)
                                                      .delete();
                                                  updateDeleteState(false);
                                                },
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              animationType: DialogTransitionType.fadeScale,
                              curve: Curves.fastOutSlowIn,
                              duration: Duration(seconds: 1),
                            );
                          },
                          title: Text(AppLocalizations.of(context)!.delete),
                          leading: Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Padding(
                      padding: EdgeInsets.all(5.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 70,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(children: [
                                Text(
                                  this.userLongName,
                                  style: GoogleFonts.notoSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  this.timeString,
                                  style: GoogleFonts.notoSans(
                                    color: Colors.black,
                                    fontSize: 14,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                              ]),
                              SizedBox(height: 10),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        this.description,
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 10,
                                        softWrap: false,
                                        style: GoogleFonts.ubuntu(fontSize: 16),
                                      ),
                                    ),
                                  ]),
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        showAnimatedDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (BuildContext context) {
                                            return GestureDetector(
                                              child: Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Container(
                                                  child: Image.network(
                                                    this.imageURL != ""
                                                        ? this.imageURL
                                                        : "https://static.bhphotovideo.com/explora/sites/default/files/ts-space-sun-and-solar-viewing-facts-versus-fiction.jpg",
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          animationType:
                                              DialogTransitionType.fadeScale,
                                          curve: Curves.fastOutSlowIn,
                                          duration: Duration(seconds: 1),
                                        );
                                      },
                                      child: Image.network(
                                        this.imageURL != ""
                                            ? this.imageURL
                                            : "https://static.bhphotovideo.com/explora/sites/default/files/ts-space-sun-and-solar-viewing-facts-versus-fiction.jpg",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
