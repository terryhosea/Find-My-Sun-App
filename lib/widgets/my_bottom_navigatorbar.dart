import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyBottomNavigationBar extends StatefulWidget {
  var scaffoldKey;
  final selectedIndex;
  ValueChanged<int> onClicked;

  MyBottomNavigationBar(
      {Key? key, this.scaffoldKey, this.selectedIndex, required this.onClicked})
      : super(key: key);

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: AppLocalizations.of(context)!.home),
        BottomNavigationBarItem(
            icon: Icon(Icons.wb_cloudy),
            label: AppLocalizations.of(context)!.weather),
        BottomNavigationBarItem(
            icon: Icon(Icons.map), label: AppLocalizations.of(context)!.map),
        BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: AppLocalizations.of(context)!.alarm),
      ],
      currentIndex: widget.selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: widget.onClicked,
      fixedColor: Colors.black,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
