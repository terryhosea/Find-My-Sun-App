import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:csci4100_major_project/pages/loader.dart';
import 'package:csci4100_major_project/pages/login.dart';
import 'package:csci4100_major_project/pages/signup.dart';
import 'package:csci4100_major_project/helpers/provider_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

class InitialPage extends StatefulWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  final Size buttonSize = Size(150, 20);

  late AnimationController animationController;
  late Animation<double> rotate;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(seconds: 80), vsync: this);
    rotate = new Tween<double>(begin: 0, end: 1).animate(animationController);

    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget initialOptions = Container(
        color: Colors.orange,
        child: Stack(children: [
          Positioned(
              top: 100,
              right: 50,
              child: RotationTransition(
                turns: rotate,
                child: Container(
                  width: 75,
                  height: 75,
                  child: CustomPaint(
                      painter: SunEffectPainter(
                          screenWidth: MediaQuery.of(context).size.width),
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                            color: Colors.yellow, shape: BoxShape.circle),
                      )),
                ),
              )),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.findMySuN,
                  style: GoogleFonts.satisfy(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                      fontWeight: FontWeight.bold,
                      fontSize: 70,
                      decoration: TextDecoration.none,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login())),
                  child: Text(AppLocalizations.of(context)!.login),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      fixedSize: buttonSize,
                      side: BorderSide(width: 2.0, color: Colors.black)),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Signup(),
                      )),
                  child: Text(AppLocalizations.of(context)!.signup,
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.black, fixedSize: buttonSize),
                )
              ],
            ),
          ),
        ]));

    return context.read<ProviderHelper>().isLoggedIn
        ? Loader()
        : initialOptions;
  }
}

class SunEffectPainter extends CustomPainter {
  double screenWidth = 100;

  SunEffectPainter({
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset offset = Offset(size.width / 2, size.height / 2);
    double radiusArcShape = screenWidth;
    double totalEffectShine = 20;

    List<Color> colors = [
      Colors.white.withOpacity(0.2),
      Colors.white.withOpacity(0),
    ];
    Paint paint = new Paint()
      ..shader = ui.Gradient.radial(
        offset,
        radiusArcShape,
        colors,
      );
    double radius = (1 * pi) / totalEffectShine;
    for (var i = 0; i < totalEffectShine; i++) {
      canvas.drawPath(
          drawPieShape(radiusArcShape, radius * (i * 2), radius, size, offset),
          paint);
    }
  }

  Path drawPieShape(double radiusArcShape, double d, double radius, Size size,
      Offset offset) {
    return Path()
      ..moveTo(offset.dx, offset.dy)
      ..arcTo(Rect.fromCircle(center: offset, radius: radiusArcShape), d,
          radius, false)
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
