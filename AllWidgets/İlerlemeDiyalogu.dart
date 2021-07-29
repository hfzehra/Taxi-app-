import 'package:flutter/material.dart';

class IlerlemeDiyalogu extends StatelessWidget {

  String message;
  IlerlemeDiyalogu({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(width: 6.0,),
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black54)),
              SizedBox(width: 26.0,),
              Text(
                message,
                style: TextStyle(color: Colors.black54, fontSize: 15.0),
              ),
            ],
          ),
        ) ,
      ),
    );
  }
}
