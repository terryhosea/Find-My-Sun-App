import 'dart:ui';

import 'package:csci4100_major_project/pages/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:csci4100_major_project/helpers/provider_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/provider_helper.dart';
import '../pages/settings.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key}) : super(key: key);
  processLogout(BuildContext context) {
    //Validation
    context.read<ProviderHelper>().logOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: InitialPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userName = context.read<ProviderHelper>().userName;
    String avatarURL = context.watch<ProviderHelper>().avatarURL;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarURL),
                  radius: 50,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(userName),
              ],
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settings),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.logout),
            leading: Icon(Icons.logout),
            onTap: () {
              showDialog(
                  context: context,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: AppLocalizations.of(context)!
                                        .areYouSureYouWantToLogout),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    child: Text(
                                        AppLocalizations.of(context)!.cancel),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text(
                                        AppLocalizations.of(context)!.logout),
                                    onPressed: () {
                                      processLogout(context);
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
