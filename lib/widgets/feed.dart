import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../widgets/message.dart';
import '../widgets/showPostDialog.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/provider_helper.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  List<LatLng>? filter;
  Feed({Key? key, this.filter}) : super(key: key);

  @override
  _feedState createState() => _feedState();
}

class _feedState extends State<Feed> {
  @override
  bool isUploading = false;
  final _controller = ScrollController();

  void isUpdating(bool status) {
    _controller.animateTo(
      _controller.position.minScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
    setState(() {
      isUploading = status;
    });
  }

  Future<Position> _getLatLong() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    Geolocator.requestPermission();

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  @override
  Widget build(BuildContext context) {
    late CollectionReference<Map<String, dynamic>> messages =
        FirebaseFirestore.instance.collection("messages");

    return StreamBuilder(
      stream: messages.orderBy("timestamp", descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Image.asset(
                context.read<ProviderHelper>().bgImage,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  if (isUploading)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                      child: SpinKitFoldingCube(
                        color: Colors.white,
                        size: 25,
                        duration: const Duration(milliseconds: 1200),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: ListView.builder(
                        controller: _controller,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          var message = snapshot.data.docs[index].data();

                          LatLng coord =
                              LatLng(message["latitude"], message["longitude"]);
                          if (widget.filter != null) {
                            if (!widget.filter!.contains(coord)) {
                              return SizedBox.shrink();
                            }
                          }

                          return Message(
                              message["username"],
                              message["datetime"],
                              message["message"],
                              message["imageURL"],
                              snapshot.data.docs[index].id,
                              messages,
                              isUpdating);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.edit),
            onPressed: () {
              showAnimatedDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return showPostDialog(
                    messages: messages,
                    updateUploadState: isUpdating,
                  );
                },
                animationType: DialogTransitionType.size,
                curve: Curves.fastOutSlowIn,
                duration: Duration(seconds: 1),
              );
            },
          ),
        );
      },
    );
  }
}
