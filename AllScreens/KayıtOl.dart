import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/LoginScreen.dart';
import 'package:flutter_app/AllScreens/MainScreens.dart';
import 'package:flutter_app/AllWidgets/%C4%B0lerlemeDiyalogu.dart';
import 'package:flutter_app/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

class KayitOl extends StatelessWidget {

  static const String idScreen="register";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
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
                SizedBox(height: 50.0,),
                Image(
                  image: AssetImage("images/logo1.png"),
                  width:250.0 ,
                  height: 350.0,
                  alignment: Alignment.center,
                ),
                SizedBox(height: 1.0,),
                Text(
                  "KAYIT OL",
                  style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                  textAlign: TextAlign.center,
                ),


                Padding(
                  padding: EdgeInsets.all(20.0),//kenarlara dolgu veriyoruz
                  child: Column(
                    children: [
                      SizedBox(height: 1.0,),
                      TextField(
                        controller: nameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "İsim",
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
                        controller: phoneTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Telefon",
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

                      SizedBox(height: 20.0,),
                      RaisedButton(
                        color: Colors.amber,
                        textColor: Colors.white,
                        child: Container(
                          width: 100.0,
                          child: Center(
                            child: Text(
                              "KAYIT OL",
                              style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold",),
                            ),
                          ),
                        ),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(24.0),
                        ),
                        onPressed: ()
                        {
                          if(nameTextEditingController.text.length <4) {
                            displayToastMessage("İsminiz en az 3 karakterli olmalıdır", context);
                          }
                          else if(!emailTextEditingController.text.contains("@")){
                            displayToastMessage("Geçerli bir email adresi giriniz", context);
                          }
                          else if(phoneTextEditingController.text.isEmpty){
                            displayToastMessage("Telefon numarası girmek zorunludur", context);
                          }
                          else if(passwordTextEditingController.text.length < 9){
                            displayToastMessage("Şifreniz en az 8 karakterli olmalıdır", context);
                          }
                          else
                            {
                              registerNewUser(context);
                            }
                        },
                      ),

                    ],
                  ),
                ),
                FlatButton(
                    onPressed: ()
                    {
                      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                    },
                    child: Text(
                      "GİRİŞ YAPINIZ",
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
  void registerNewUser(BuildContext context) async
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
        .createUserWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text).catchError((errMsg){
          Navigator.pop(context);
          displayToastMessage("Hata: " + errMsg.toString(), context);
    })).user;

    if(firebaseUser != null) //kullanıcı oluşturma
    {
      //kullanıcıyı veritabanına kaydetme
      Map UserDataMap =
      {
        "İsim": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "Telefon": phoneTextEditingController.text.trim(),
      };
      kullanici.child(firebaseUser.uid).set(UserDataMap);
      displayToastMessage("Hasabınız başarıyla oluşturuldu", context);
      
      Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false) ;
    }
    else {
      Navigator.pop(context);
      displayToastMessage("Kullanıcı oluşturulamadı", context);
    }
  }

  displayToastMessage (String message, BuildContext context)
  {
    Fluttertoast.showToast(msg: message);
  }
}
