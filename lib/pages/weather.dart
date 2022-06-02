// ignore_for_file: missing_required_param

import 'dart:convert';
import 'package:csci4100_major_project/helpers/db_helper.dart';
import 'package:csci4100_major_project/models/weather_data.dart';
import 'package:csci4100_major_project/models/alarm_data.dart';
import 'package:csci4100_major_project/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_widget/WeatherWidget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/provider_helper.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  late WeatherData moreData;
  Geolocator geolocator = Geolocator();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String location = "";
  var _controller = TextEditingController(text: "");
  Color textColor = Colors.black;

  List<AlarmData> alarms = [];
  @override
  void initState() {
    super.initState();
    getAlarmData();
  }

  List<Widget> backgroundWeather(String weatherCondition, int timezone) {
    List<Color> bgColor = [];
    List<Widget> bgStack = [];
    Color cloudColor = Colors.white54;
    Widget rain = RainWidget(
      // rainColor: Colors.blue,
      rainLength: 20,
    );
    Widget wind = WindWidget(
      windColor: Colors.white24,
      pauseMillEnd: 6000,
      pauseMillStart: 3000,
      windSlideMill: 2000,
      windGap: 50,
    );

    Widget snow = SnowWidget(
      // snowFallSecMin: 500,
      // snowFallSecMax: 1500,
      // snowWaveRangeMin: 50,
      // snowWaveRangeMax: 500,
      snowWaveSecMin: 500,
      snowWaveSecMax: 1500,
      snowAreaYEnd: 500,
    );

    Widget thunder = ThunderWidget();

    var hour = DateTime.now()
        .add(Duration(
            seconds: timezone - DateTime.now().timeZoneOffset.inSeconds))
        .hour;

    //DateTime.now().hour;

    //set background color based on hours
    if (hour >= 6 && hour < 14) {
      bgColor = [Colors.lightBlue, Colors.lightBlueAccent];
      cloudColor = Colors.white70;
    } else if (hour >= 14 && hour < 18) {
      bgColor = [Colors.amber, Colors.pinkAccent];
      cloudColor = Colors.white54;
    } else {
      bgColor = [Colors.deepPurple, Colors.indigo];
      cloudColor = Colors.black26;
      textColor = Colors.white;
    }

    //set background color and weather widgets based on conditions
    if (weatherCondition.contains("overcast") ||
        weatherCondition.contains("storm") ||
        weatherCondition.contains("haze")) {
      bgColor = [Colors.grey, Colors.black45];
      cloudColor = Colors.black26;
      textColor = Colors.white;
    }

    bgStack.add(
      BackgroundWidget(
        colors: bgColor,
        size: Size.infinite,
      ),
    );

    if (weatherCondition.contains("cloud")) {
      bgStack.add(CloudWidget(color: cloudColor));
    }
    if (weatherCondition.contains("rain") ||
        weatherCondition.contains("shower")) {
      bgStack.add(CloudWidget(color: cloudColor));
      bgStack.add(rain);
      bgStack.add(rain);
      bgStack.add(wind);
    }

    if (weatherCondition.contains("wind")) {
      bgStack.add(wind);
    }

    if (weatherCondition.contains("thunder") ||
        weatherCondition.contains("lighting")) {
      bgStack.add(thunder);

      if (weatherCondition.contains("storm")) {
        bgStack.add(rain);
        bgStack.add(rain);
        bgStack.add(wind);
        bgStack.add(wind);
      }
    }

    if (weatherCondition.contains("snow")) {
      print("Here");
      bgStack.add(CloudWidget(color: cloudColor));
      bgStack.addAll([snow, snow, snow, snow, snow, snow, snow, snow]);
    }

    return bgStack;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Colors.orange,
          tabs: [
            Tab(
              child: Text(
                "Sun",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                AppLocalizations.of(context)!.weather,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
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
            TabBarView(
              children: [
                sun(),
                additionalWeather(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget additionalWeather() {
    return
        // BackgroundWidget(
        //   colors: [Colors.orangeAccent, Colors.purple],
        //   size: Size.infinite,
        // ),
        // // Expanded(
        // //   child: WeatherWidget(
        // //     size: Size.infinite,
        // //     weather: 'Snowy',
        // //     snowConfig: SnowConfig(
        // //       snowNum: 0,
        // //     ),
        // //   ),
        // // ),
        // WindWidget(
        //   windSlideMill: 3000,
        //   windPositionY: 100,
        // ),
        // WindWidget(
        //   windSlideMill: 3000,
        //   windPositionY: 100,
        // ),

        Center(
      child: FutureBuilder(
        future: getData2(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: SpinKitThreeBounce(
                size: 25,
                color: Colors.white,
              ),
            );
          }

          // weatherCondition = snapshot.data[8];
          print("snapshotData: " + snapshot.data.toString());
          return Stack(
            children: [
              ...backgroundWeather(
                  snapshot.data.length > 1 ? snapshot.data[8] : "N/A",
                  snapshot.data.length > 1 ? int.parse(snapshot.data[11]) : -1),
              Center(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Text(
                        snapshot.data.length > 1 ? snapshot.data[0] : "N/A",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        snapshot.data.length > 1 ? snapshot.data[1] : "N/A",
                        style: TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        snapshot.data.length > 1 ? snapshot.data[8] : "N/A",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "H:" +
                            (snapshot.data.length > 1
                                ? snapshot.data[4]
                                : "N/A") +
                            "  L:" +
                            (snapshot.data.length > 1
                                ? snapshot.data[3]
                                : "N/A"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GridView.count(
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 35, left: 20, right: 20),
                      crossAxisCount: 2,
                      children: [
                        Card(
                          elevation: 1,
                          color: Colors.transparent,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.device_thermostat_sharp),
                                  Text(
                                    AppLocalizations.of(context)!.feelsLike,
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                snapshot.data.length > 1
                                    ? snapshot.data[2].toString()
                                    : "N/A",
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          elevation: 1,
                          color: Colors.transparent,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.humidity,
                                style: TextStyle(color: textColor),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                snapshot.data.length > 1
                                    ? snapshot.data[6].toString()
                                    : "N/A",
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          elevation: 1,
                          color: Colors.transparent,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.pressure,
                                style: TextStyle(color: textColor),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 120,
                                child: SfRadialGauge(
                                  axes: [
                                    RadialAxis(
                                      showLabels: false,
                                      showTicks: false,
                                      minimum: 950,
                                      maximum: 1050,
                                      axisLineStyle:
                                          AxisLineStyle(dashArray: [2.0, 2.0]),
                                      pointers: [
                                        MarkerPointer(
                                          color: Colors.orange,
                                          value: snapshot.data.length > 1
                                              ? double.parse(snapshot.data[5])
                                              : -1.0,
                                        )
                                      ],
                                      annotations: [
                                        GaugeAnnotation(
                                          widget: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                snapshot.data.length > 1
                                                    ? snapshot.data[5]
                                                        .toString()
                                                    : "N/A",
                                                style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                "hPa",
                                                style: TextStyle(
                                                  color: textColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          angle: 90,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          elevation: 1,
                          color: Colors.transparent,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.wind,
                                style: TextStyle(color: textColor),
                              ),
                              Container(
                                height: 120,
                                child: SfRadialGauge(axes: [
                                  RadialAxis(
                                    showLabels: false,
                                    // showTicks: false,
                                    startAngle: 270,
                                    endAngle: 270,
                                    minimum: 0,
                                    maximum: 360,
                                    interval: 180,
                                    axisLineStyle:
                                        AxisLineStyle(dashArray: [1.0, 1.0]),
                                    pointers: [
                                      NeedlePointer(
                                        needleLength: 0.8,
                                        needleEndWidth: 3.0,
                                        needleColor: Colors.orange,
                                        value: snapshot.data.length > 1
                                            ? double.parse(snapshot.data[12]) <=
                                                    180
                                                ? double.parse(
                                                        snapshot.data[12]) +
                                                    180
                                                : double.parse(
                                                        snapshot.data[12]) -
                                                    180
                                            : -1.0,
                                        knobStyle:
                                            KnobStyle(color: Colors.black),
                                      )
                                    ],
                                    annotations: [
                                      GaugeAnnotation(
                                        widget: Text(
                                          "N",
                                          style: TextStyle(
                                            color: textColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        axisValue: 0,
                                        positionFactor: 0.7,
                                      )
                                    ],
                                  ),
                                ]),
                              ),
                              Text(
                                snapshot.data.length > 1
                                    ? snapshot.data[7].toString()
                                    : "N/A",
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget sun() {
    return Center(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.location,
                            hintText: AppLocalizations.of(context)!.enterCity,
                          ),
                          onTap: () {
                            _controller.clear();
                          },
                          validator: (value) {
                            // if (value == null || value.isEmpty) {
                            //   return 'This field cant be null';
                            // }
                            return null;
                          },
                          onSaved: (value) {
                            location = value.toString();
                          },
                        ),
                      ),
                      SizedBox(height: 5),
                      IconButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _formKey.currentState!.save();
                            });
                          }
                          FocusScope.of(context).unfocus();
                        },
                        icon: Icon(Icons.update),
                        // label: Text(AppLocalizations.of(context)!.update)
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          FutureBuilder(
              future: getData2(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SpinKitThreeBounce(
                      size: 25,
                      color: Colors.white,
                    ),
                  );
                } else if (alarms.any((element) =>
                    element.location == snapshot.data[0].toString())) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        snapshot.data[1] != null ? snapshot.data[0] : "error",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(
                        height: 45,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 15.0,
                                  bottom: 10.0,
                                ),
                                child: SvgPicture.asset(
                                  "assets/images/sunrise.svg",
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.sunrise,
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data.length > 1
                                    ? snapshot.data[10].toUpperCase()
                                    : "N/A",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 40),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 15.0,
                                  bottom: 10.0,
                                ),
                                child: SvgPicture.asset(
                                  "assets/images/sunset.svg",
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.sunset,
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data.length > 1
                                    ? snapshot.data[9].toUpperCase()
                                    : "N/A",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        AppLocalizations.of(context)!.alarmIsTurnedOn,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      )
                    ],
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      snapshot.data[0] != null ? snapshot.data[0] : "error",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(
                      height: 45,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 15.0,
                                bottom: 10.0,
                              ),
                              child: SvgPicture.asset(
                                "assets/images/sunrise.svg",
                                width: 100,
                                height: 100,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.sunrise,
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              snapshot.data.length > 1
                                  ? snapshot.data[10].toUpperCase()
                                  : "N/A",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 40),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 15.0,
                                bottom: 10.0,
                              ),
                              child: SvgPicture.asset(
                                "assets/images/sunset.svg",
                                width: 100,
                                height: 100,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.sunset,
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              snapshot.data.length > 1
                                  ? snapshot.data[9].toUpperCase()
                                  : "N/A",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    snapshot.data.length > 1 && snapshot.data[0] != "N/A"
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              await _showDialog(context);
                              // DBHelper.dbHelper.insertData({
                              //   "location": snapshot.data[0].toString(),
                              //   "timer": "10",
                              //   "sunrise": snapshot.data[10].toString(),
                              //   "sunset": snapshot.data[9].toString(),
                              //   "sunsetON": 1,
                              //   "sunriseON": 1
                              // });
                              setState(() {
                                getAlarmData();
                              });
                            },
                            icon: Icon(Icons.access_alarm),
                            label:
                                Text(AppLocalizations.of(context)!.turnAlarmOn),
                          )
                        : Text("")
                  ],
                );
              }),
        ],
      ),
    );
  }

  Future<Position> _getLatLong() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    Geolocator.requestPermission();

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Future<String> getAddress(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

    return (placemarks[0].locality).toString();
  }

  Future<List<String>> getData2() async {
    var K = 273.15;
    if (location.isEmpty) {
      var x = await _getLatLong();

      location = await getAddress(x.latitude, x.longitude);
    }

    var url = Uri.https("api.openweathermap.org", "/data/2.5/weather", {
      "q": location,
      "appid": "512104c1202808c8febf4da53ac2e13f",
      "mode": "json"
    });
    var response = await get(url);

    var data = jsonDecode(response.body);

    if (data["main"] == null) {
      return ["N/A"];
    }

    moreData = WeatherData(
        data["main"]["temp"] - K,
        data["main"]["feels_like"] - K,
        data["main"]["temp_min"] - K,
        data["main"]["temp_max"] - K,
        data["main"]["pressure"].toString(),
        data["main"]["humidity"].toString(),
        (double.parse((data["wind"]["speed"]).toString()) * 3.6)
            .round()
            .toString(),
        data["weather"][0]["description"].toString(),
        data["sys"]["sunrise"],
        data["sys"]["sunset"],
        data["wind"]["deg"]);

    final DateTime time1 =
        DateTime.fromMillisecondsSinceEpoch(moreData.sunSetTime * 1000);
    final DateTime time2 =
        DateTime.fromMillisecondsSinceEpoch(moreData.sunRiseTime * 1000);
    final String currentSunsetTime = convertToTime(time1);
    final String currentSunriseTime = convertToTime(time2);

    return ([
      location,
      moreData.temperature.toStringAsFixed(0) + "°",
      moreData.feelLike.toStringAsFixed(0) + "°",
      moreData.minTemp.toStringAsFixed(0) + "°",
      moreData.maxTemp.toStringAsFixed(0) + "°",
      moreData.pressure,
      moreData.humidity + "%",
      moreData.windSpeed + " km/h",
      moreData.description,
      currentSunsetTime,
      currentSunriseTime,
      data["timezone"].toString(),
      moreData.windDeg.toString()
    ]);
  }

  String convertToTime(DateTime date) {
    String converted = date.toString();
    List x = converted.split(" ");
    List y = x[1].split(":");

    if (int.parse(y[0]) < 12) {
      converted = y[0] + ":" + y[1] + " am";
    } else {
      int temp = int.parse(y[0]);
      temp -= 12;
      converted = "0" + temp.toString() + ":" + y[1] + " pm";
    }
    return converted;
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
        print(alarm1.location +
            " " +
            alarm1.sunriseOn.toString() +
            " " +
            alarm1.sunsetOn.toString());
        alarms.add(alarm1);
      });
    });
  }

  _showDialog(BuildContext context) {
    int dropdownvalue = 5;
    var items = [5, 10, 15, 20];
    final DateTime time1 =
        DateTime.fromMillisecondsSinceEpoch(moreData.sunSetTime * 1000);
    final DateTime time2 =
        DateTime.fromMillisecondsSinceEpoch(moreData.sunRiseTime * 1000);
    final String currentSunsetTime = convertToTime(time1);
    final String currentSunriseTime = convertToTime(time2);
    List<bool> sunRiseToggle = [true, false];
    List<bool> sunSetToggle = [true, false];
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
              title: Center(
                  child: Text(
                AppLocalizations.of(context)!.newAlarm + " for " + location,
              )),
              children: [
                Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        AppLocalizations.of(context)!.timeBefore,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: DropdownButton(
                          style: TextStyle(color: Colors.orange),
                          value: dropdownvalue,
                          items: items.map((element) {
                            return DropdownMenuItem(
                                value: element, child: Text("$element mins"));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              dropdownvalue = int.parse(newValue.toString());
                            });
                          },
                        )),
                    Spacer(),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.sunrise,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            currentSunriseTime,
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(AppLocalizations.of(context)!.sunset,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            currentSunsetTime,
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ToggleButtons(
                      constraints: BoxConstraints(
                          minHeight: 35,
                          minWidth: 45,
                          maxHeight: 35,
                          maxWidth: 45),
                      borderColor: Colors.black,
                      fillColor: Colors.orange,
                      selectedBorderColor: Colors.black,
                      selectedColor: Colors.white,
                      borderRadius: BorderRadius.circular(45),
                      children: [
                        Text(
                          AppLocalizations.of(context)!.on,
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          AppLocalizations.of(context)!.off,
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                      isSelected: sunRiseToggle,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < sunRiseToggle.length; i++) {
                            sunRiseToggle[i] = i == index;
                          }
                        });
                      },
                    ),
                    ToggleButtons(
                      constraints: BoxConstraints(
                          minHeight: 35,
                          minWidth: 45,
                          maxHeight: 35,
                          maxWidth: 45),
                      borderColor: Colors.black,
                      fillColor: Colors.orange,
                      selectedBorderColor: Colors.black,
                      selectedColor: Colors.white,
                      borderRadius: BorderRadius.circular(45),
                      children: [
                        Text(
                          AppLocalizations.of(context)!.on,
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          AppLocalizations.of(context)!.off,
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                      isSelected: sunSetToggle,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < sunSetToggle.length; i++) {
                            sunSetToggle[i] = i == index;
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.cancel,
                              style: TextStyle(color: Colors.blue))),
                      SimpleDialogOption(
                          onPressed: () async {
                            int riseOn = 0;
                            int setOn = 0;
                            if (sunSetToggle[0] == true) {
                              setOn = 1;
                            }
                            if (sunRiseToggle[0] == true) {
                              riseOn = 1;
                            }

                            await DBHelper.dbHelper.insertData({
                              "location": location.toString(),
                              "timer": dropdownvalue.toString(),
                              "sunrise": currentSunriseTime.toString(),
                              "sunset": currentSunsetTime.toString(),
                              "sunsetON": setOn,
                              "sunriseON": riseOn
                            });
                            print(riseOn);
                            if (riseOn == 1) {
                              if (!time2.isBefore(DateTime.now()))
                                try {
                                  print("$riseOn riseOnvalue");
                                  NotificationsService
                                      .showScheduledNotification(
                                          title: AppLocalizations.of(context)!
                                              .sunRise,
                                          body: AppLocalizations.of(context)!
                                              .heyItsAlmostSunRiseTime,
                                          payload: "sarah.abs",
                                          scheduledDate:
                                              time2.subtract(Duration(
                                                  minutes: dropdownvalue)));
                                } catch (e) {
                                  print(riseOn);
                                }
                            }
                            if (setOn == 1) {
                              if (!time1.isBefore(DateTime.now()))
                                NotificationsService.showScheduledNotification(
                                    title: AppLocalizations.of(context)!.sunset,
                                    body: AppLocalizations.of(context)!
                                        .heyItsAlmostSunSetTime,
                                    payload: "sarah.abs",
                                    scheduledDate: time1.subtract(
                                        Duration(minutes: dropdownvalue)));
                            }
                            final snackBar = SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .scheduledTheAlarm),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.add,
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                )
              ],
            );
          });
        });
  }
}
