import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/MainScreens.dart';

class AboutScreen extends StatefulWidget
{
  static const String idScreen = "about";

  @override
  _MyAboutScreenState createState() => _MyAboutScreenState();
}

class _MyAboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amber,
        body: ListView(
          children: <Widget>[
            Container(
              height: 250,
              child: Center(
                child: Image.asset('images/logo.png'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30, left: 24, right: 24),
              child: Column(
                children: <Widget>[
                  Text(
                    'TAKSİ UYGULAMASI',
                    style: TextStyle(
                        fontSize: 50, fontFamily: 'Signatra'),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Google Map tabanlı bu konum uygulaması, '
                        'gitmek istediğiniz konumu bulduktan sonra, '
                        'sizin için en yakın taksiyi bulup, en uygun fiyatla yolculuk yapmanızı sağlar.',
                    style: TextStyle(fontFamily: "Brand-Bold",fontSize: 18 ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
            FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
                },
                child: const Text(
                    'HADİ BAŞLAYALIM !',
                    style: TextStyle(
                        fontSize: 20, color: Colors.black,
                    )
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0))
            ),
          ],
        ));
  }
}