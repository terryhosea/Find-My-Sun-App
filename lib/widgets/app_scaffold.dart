import 'package:csci4100_major_project/models/weather_data.dart';
import 'package:csci4100_major_project/pages/weather.dart';
import 'package:flutter/material.dart';
import 'package:csci4100_major_project/pages/home.dart';
import 'package:csci4100_major_project/pages/map.dart';
import 'package:csci4100_major_project/pages/alarm.dart';
import 'my_bottom_navigatorbar.dart';
import 'mydrawer.dart';
import '../helpers/provider_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppScaffold extends StatefulWidget {
  final AsyncSnapshot? data;
  final WeatherData? currentLocationWeather;
  AppScaffold({Key? key, this.data, this.currentLocationWeather});
  @override
  _AppScaffoldState createState() =>
      _AppScaffoldState(data, currentLocationWeather);
}

class _AppScaffoldState extends State<AppScaffold> {
  final AsyncSnapshot? data;
  final WeatherData? currentLocationWeather;
  _AppScaffoldState(this.data, this.currentLocationWeather);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  List screens = [Home(), Weather(), Map(), Alarm()];
  List<String> pageTitles = [];

  void onClicked(int index) async {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    pageTitles = [
      AppLocalizations.of(context)!.home,
      AppLocalizations.of(context)!.weather,
      AppLocalizations.of(context)!.map,
      AppLocalizations.of(context)!.alarm
    ];
    final DateTime time1 = DateTime.fromMillisecondsSinceEpoch(
        currentLocationWeather!.sunSetTime * 1000);
    final DateTime time2 = DateTime.fromMillisecondsSinceEpoch(
        currentLocationWeather!.sunRiseTime * 1000);
    final String currentSunsetTime = convertToTime(time1);
    final String currentSunriseTime = convertToTime(time2);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(pageTitles[selectedIndex]),
        actions: [
          Container(
              padding: EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wb_twighlight,
                    size: 25,
                  ),
                  Text(
                    currentSunriseTime,
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mode_night,
                    size: 25,
                  ),
                  Text(
                    currentSunsetTime,
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              )),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            context.read<ProviderHelper>().bgImage,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Center(
            child: screens.elementAt(selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
          scaffoldKey: _scaffoldKey,
          selectedIndex: selectedIndex,
          onClicked: onClicked),
      drawer: MyDrawer(),
    );
  }

  String convertToTime(DateTime date) {
    String converted = date.toString();
    List x = converted.split(" ");
    List y = x[1].split(":");

    if (int.parse(y[0]) < 12) {
      converted = y[0] + ":" + y[1] + "am";
    } else {
      int temp = int.parse(y[0]);
      temp -= 12;
      converted = temp.toString() + ":" + y[1] + "pm";
    }
    return converted;
  }
}
