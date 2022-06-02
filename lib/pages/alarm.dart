import 'package:csci4100_major_project/helpers/db_helper.dart';
import 'package:csci4100_major_project/models/alarm_data.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Alarm extends StatefulWidget {
  const Alarm({Key? key}) : super(key: key);

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  List<AlarmData> alarms = [];
  @override
  void initState() {
    super.initState();
    getAlarmData();
  }

  @override
  Widget build(BuildContext context) {
    //TO DO
    return Center(
      child: alarms.length == 0
          ? Text(
              "No Alarms",
              style: TextStyle(
                fontSize: 16,
              ),
            )
          : ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 6,
                        child: Stack(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: Colors.white70,
                              shadowColor: Colors.orange,
                              elevation: 5,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          alarms[index].location,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          alarms[index].timer +
                                              AppLocalizations.of(context)!
                                                  .minutesBefore,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .sunrise,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              alarms[index]
                                                  .sunrise
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .sunset,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              alarms[index]
                                                  .sunset
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                        onTap: () async {
                                          Navigator.pop(context);
                                          DBHelper.dbHelper.deleteByLocation(
                                              alarms[index].location);
                                          setState(() {
                                            getAlarmData();
                                          });
                                        },
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .delete),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
    );
  }

  getAlarmData() async {
    List<Map<String, dynamic>> record = await DBHelper.dbHelper.getData();
    setState(() {
      alarms.clear();
      record.forEach((element) {
        AlarmData alarm1 = AlarmData(
            element['location'],
            element['timer'],
            element['sunrise'],
            element['sunset'],
            element['sunsetON'],
            element['sunriseON']);
        print(alarm1.location);
        alarms.add(alarm1);
      });
    });
  }
}
