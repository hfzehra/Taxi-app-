import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/Kay%C4%B1tOl.dart';
import 'package:flutter_app/AllScreens/MainScreens.dart';
import 'package:flutter_app/AllWidgets/%C4%B0lerlemeDiyalogu.dart';
import 'package:flutter_app/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget {

  static const String idScreen="login";

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber,Colors.black54],
            ),
          ),

        child: Padding(
          padding: const EdgeInsets.all(8.0),

          child: Column(

            children: [
              SizedBox(height: 120.0,),
              Image(
                image: AssetImage("images/logo1.png"),
                width:250.0 ,
                height: 330.0,
                alignment: Alignment.center,
              ),
              SizedBox(height: 1.0,),
              Text(
                "Kullanıcı Girişi",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),


              Padding(
                padding: EdgeInsets.all(20.0),//kenarlara dolgu veriyoruz
                child: Column(
                  children: [
                    SizedBox(height: 1.0,),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "email",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0,),
                    ),

                    SizedBox(height: 1.0,),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Şifre",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),

                      ),
                      style: TextStyle(fontSize: 14.0,),
                    ),

                    SizedBox(height: 25.0,),
                    RaisedButton(
                      color: Colors.amber,
                      textColor: Colors.white,
                      child: Container(
                        width: 100.0,
                        child: Center(
                          child: Text(
                            "GİRİŞ",
                            style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold",),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: ()
                      {
                        if(!emailTextEditingController.text.contains("@")){
                          displayToastMessage("Geçerli bir email adresi giriniz", context);
                        }
                        else if(passwordTextEditingController.text.length < 9){
                          displayToastMessage("Şifreniz en az 8 karakterli olmalıdır", context);
                        }
                        else {
                          loginUser(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: ()
                {
                  Navigator.pushNamedAndRemoveUntil(context, KayitOl.idScreen, (route) => false);
                },
                child: Text(
                  " KAYIT OL ",
                )
              ),
            ],
          ),
        ),
        ),
      )
    );
  }

  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
  void loginUser(BuildContext context) async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)
      {
        return IlerlemeDiyalogu(message: "Lütfen bekleyin..." ) ;
      },
    );

    final User firebaseUser= (await _firebaseAuth
        .signInWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text).catchError((errMsg){
          Navigator.pop(context);
          displayToastMessage("Hata: " + errMsg.toString(), context);
    })).user;

    if(firebaseUser != null)
    {
      kullanici.child(firebaseUser.uid).once().then((DataSnapshot snap)
      {
        if(snap.value != null)
        {
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false) ;
          displayToastMessage("Başarıyla giriş yaptınız", context);
        }
        else
        {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage("Böyle bir kullanıcı bulanamadı", context);
        }
      });
    }
    else {
      Navigator.pop(context);
      displayToastMessage("Oturum açılamadı", context);
    }
  }
  displayToastMessage (String message, BuildContext context)
  {
    Fluttertoast.showToast(msg: message);
  }
}


