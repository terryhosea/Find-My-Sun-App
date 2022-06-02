import 'package:csci4100_major_project/models/weather_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import '../widgets/app_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Loader extends StatefulWidget {
  Loader({Key? key}) : super(key: key);
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  String location = "";
  late WeatherData currentLocationWeather;
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                  ),
                  CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(AppLocalizations.of(context)!.loading),
                  )
                ],
              ),
            );
          }
          return AppScaffold(
              data: snapshot, currentLocationWeather: currentLocationWeather);
        });
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

  Future<WeatherData> getData() async {
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

    var data = await jsonDecode(response.body);
    WeatherData moreData = WeatherData(
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

    currentLocationWeather = moreData;
    return moreData;
  }
}
