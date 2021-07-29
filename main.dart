import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/Kay%C4%B1tOl.dart';
import 'package:flutter_app/AllScreens/LoginScreen.dart';
import 'package:flutter_app/AllScreens/MainScreens.dart';
import 'package:flutter_app/DataHandler/AppData.dart';
import 'package:provider/provider.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference kullanici= FirebaseDatabase.instance.reference().child("Kullanıcılar");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Taxi Rider App',
        theme: ThemeData(
          fontFamily: "Brand Bold",
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : MainScreen.idScreen,
        routes: {
          KayitOl.idScreen:(content)=> KayitOl(),
          LoginScreen.idScreen:(content)=> LoginScreen(),
          MainScreen.idScreen:(content)=> MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


