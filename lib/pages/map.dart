import 'package:csci4100_major_project/widgets/feed.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<LatLng> selected = [];

Marker genMarker(LatLng point) {
  return Marker(
    anchorPos: AnchorPos.align(AnchorAlign.center),
    height: 40,
    width: 40,
    point: point,
    //builder: (context) => Icon(Icons.pin_drop_rounded, color: Colors.orange),
    builder: (context) => IconButton(
        onPressed: () {
          selected = [];
          print(point.latitude);
          print(point.longitude);
          selected.add(LatLng(point.latitude, point.longitude));
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => FilteredFeedDialog(),
              fullscreenDialog: true,
            ),
          );
        },
        icon: Icon(Icons.pin_drop_rounded, color: Colors.orange)),
  );
}

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  List<LatLng> markers = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    CollectionReference messages =
        FirebaseFirestore.instance.collection("messages");
    messages.snapshots().listen((query) {
      markers.length = query.size;
      for (var i = 0; i < markers.length; i++) {
        var message = query.docs[i];
        setState(() {
          markers[i] = LatLng(message["latitude"], message["longitude"]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(43.6532, -79.3832);
    return FlutterMap(
      options: MapOptions(
          interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
          zoom: 2.0,
          center: center,
          plugins: [
            MarkerClusterPlugin(),
          ],
          maxZoom: 17,
          minZoom: 1),
      layers: [
        TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/4100bestgroup/ckw32agol00iy15ofoxmbaiw2/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiNDEwMGJlc3Rncm91cCIsImEiOiJja3czMjVsYncwamMwMm9wODNkNGV6bnR5In0.kOnfu_1y8g1zTCchwajvzw",
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1IjoiNDEwMGJlc3Rncm91cCIsImEiOiJja3czMjVsYncwamMwMm9wODNkNGV6bnR5In0.kOnfu_1y8g1zTCchwajvzw',
              'id': 'mapbox.mapbox-streets-v8'
            }),
        MarkerClusterLayerOptions(
            zoomToBoundsOnClick: false,
            centerMarkerOnClick: false,
            maxClusterRadius: 120,
            size: Size(40, 40),
            fitBoundsOptions: FitBoundsOptions(
              padding: EdgeInsets.all(50),
            ),
            markers: markers.map((coord) => genMarker(coord)).toList(),
            polygonOptions: PolygonOptions(
              borderColor: Colors.blueAccent,
              color: Colors.black12,
              borderStrokeWidth: 3,
            ),
            builder: (context, markers) {
              return FloatingActionButton(
                child: Text(markers.length.toString()),
                onPressed: () {
                  selected = [];
                  markers.forEach((e) {
                    selected.add(LatLng(e.point.latitude, e.point.longitude));
                  });
                  print(selected.toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => FilteredFeedDialog(),
                      fullscreenDialog: true,
                    ),
                  );
                },
              );
            })
      ],
    );
  }
}

class FilteredFeedDialog extends StatelessWidget {
  const FilteredFeedDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.feed),
      ),
      body: Feed(filter: selected),
    );
  }
}
