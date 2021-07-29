import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/profileTabPage.dart';
import 'package:flutter_app/AllScreens/searchScreen.dart';
import 'package:flutter_app/AllScreens/aboutScreen.dart';
import 'package:flutter_app/AllWidgets/%C4%B0lerlemeDiyalogu.dart';
import 'package:flutter_app/AllWidgets/Divider.dart';
import 'package:flutter_app/Assistans/assistantMethods.dart';
import 'package:flutter_app/DataHandler/AppData.dart';
import 'package:flutter_app/Model/directDetails.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../MapKey.dart';
import 'LoginScreen.dart';



class MainScreen extends StatefulWidget {

  static const String idScreen="MainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin
{

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey =new GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {} ;

  BitmapDescriptor nearByIcon;
  String uName="";

  //kendi konumumuzu ayarlama
  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet ={};
  Set<Circle> circlesSet = {};

  double rideDetailsContainer = 0;
  double requestDetailsContainerHeight = 0;
  double searchContainerHeight = 250.0;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;

  DatabaseReference rideRequestRef;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest()
  {
    rideRequestRef = FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap =
    {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMap =
    {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideInfoMap =
    {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };

    rideRequestRef.set(rideInfoMap);

  }

  void cancelRideRequest()
  {
    rideRequestRef.remove();
  }

  void displayRequestRideContainer()
  {
    setState(() {
      requestDetailsContainerHeight = 250.0;
      rideDetailsContainer = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  resetApp()
  {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 250.0;
      rideDetailsContainer = 0;
      requestDetailsContainerHeight=0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();

    });
    locatePosition();
  }

  void displayRideDetailsContainer() async
  {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainer = 250.0;
      bottomPaddingOfMap= 250.0;
      drawerOpen= false;
    });
  }

  void locatePosition() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(position, context);

    uName = userCurrentInfo.name;
    //burada yazdığımız position temelde neredde olduğumuzun koordinatlarını verir.

    print("Burası senin adresin:"+ address.toString());
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        color: Colors.amber,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer Header
              Container(
                height: 165.0,
                child: DrawerHeader(
                  //decoration: BoxDecoration(color: Colors.amber),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png", height: 65.0, width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(uName, style: TextStyle(fontSize: 16.0, fontFamily: "Brand Bold"),),
                          SizedBox(height: 6.0,),
                          GestureDetector(
                              onTap: ()
                              {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileTabPage()));
                              },
                              child: Text("Visit Profile")
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              DividerWidget(),
              SizedBox(height:10.0),
              GestureDetector(
                onTap: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileTabPage()));
                },
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Profil", style: TextStyle(fontSize: 20.0),),
                ),
              ),
              SizedBox(height:16.0),
              GestureDetector(
                onTap: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> AboutScreen()));
                },
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text("Hakkında", style: TextStyle(fontSize: 19.0),),
                ),
              ),
              SizedBox(height:16.0),
              GestureDetector(
                onTap: ()
                {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.close),
                  title: Text("Çıkış", style: TextStyle(fontSize: 20.0)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap
          (
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers:markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap: 300.0;
              });
              locatePosition();
            },
          ),

          //hamburger button
          Positioned(
            top:38.0,
            left:22.0,
            child: GestureDetector( //kaydırma efekti
              onTap: ()
              {
                if(drawerOpen)
                {
                  scaffoldKey.currentState.openDrawer(); //kaydırma komutu
                }
                else
                {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child:  Icon((drawerOpen) ? Icons.menu : Icons.close, color: Colors.black,),
                  radius:20.0,
                ),
              ),
            ),
          ),

          Positioned(
            left:0.0,
            right:0.0,
            bottom:0.0,
            child: AnimatedSize(
              vsync:this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white,Colors.amber],
                    ),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0),topRight: Radius.circular(18.0)),
                  boxShadow:
                  [
                    BoxShadow //buton gölge
                    (
                      color: Colors.black,
                      blurRadius: 16.0, //bulanıklık yarıçapı
                      spreadRadius: 0.5, //yayılma yarıçapı
                      offset: Offset(0.7,0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.5,),
                      Text("MERHABA", style: TextStyle(fontSize:13.0),),
                      Text("Nereye gitmek istersiniz?", style: TextStyle(fontSize:20.0, fontFamily: "Brand-Bold"),),
                      SizedBox(height: 20.0,),
                      GestureDetector(
                        onTap: () //kullanıcıyı arama ekranına yönlendirme
                        async {
                         var res= await Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchScreen()));
                         if(res =="obtainDirection")
                         {
                            displayRideDetailsContainer();
                         }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow:
                            [
                              BoxShadow //buton gölge
                                (
                                color: Colors.black54,
                                blurRadius: 6.0, //bulanıklık yarıçapı
                                spreadRadius: 0.5, //yayılma yarıçapı
                                offset: Offset(0.7,0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row
                            (
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent,),
                                SizedBox(width: 10.0,),
                                Text("Konum arayınız..."),
                              ],

                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0,),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.grey,),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context).pickUpLocation != null
                                  ? Provider.of<AppData>(context).pickUpLocation.placeName
                                  : "Ev Ekle" ,
                              ),
                              SizedBox(height: 4.0,),
                              Text("Ev adresinizi girin", style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10.0,),

                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom:0.0,
            left:0.0,
            right:0.0,
            child: AnimatedSize(
              vsync:this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainer,
                  decoration: BoxDecoration(
                    gradient:  LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white,Colors.amber],
                    ),

                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0),),
                  boxShadow: [
                    BoxShadow(
                      color:Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    ),
                  ]
                ),

                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children:[
                              Image.asset("images/taxi.png",height:70.0, width:80.0),
                              SizedBox(width:16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Text(
                                    "TAKSİ",style: TextStyle(fontSize: 18.0,fontFamily: "Brand-Bold"),
                                  ),
                                  Text(
                                    ((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : '') , style: TextStyle(fontSize: 16.0, color: Colors.grey,),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails != null) ? '\₺${AssistantMethods.calculateFares(tripDirectionDetails)}' : ''), style: TextStyle(fontFamily: "Brand Bold",fontSize: 16.0),
                              )
                            ]
                          ),
                        ),
                      ),

                      SizedBox(height:20.0),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckAlt,size:18.0, color: Colors.black54),
                            SizedBox(width:16.0),
                            Text("Para"),
                            SizedBox(width:6.0),
                            Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16.0),
                          ],
                        ),
                      ),

                      SizedBox(height:20.0),

                      Padding(
                        padding: EdgeInsets.all(17.0),
                        // ignore: deprecated_member_use
                        child: RaisedButton(
                            onPressed:(){
                              displayRequestRideContainer();
                            },
                            color: Theme.of(context).accentColor,
                            child:Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                 Text("İstek", style: TextStyle(fontSize:20.0, fontWeight: FontWeight.bold, color: Colors.white )),
                                 Icon(FontAwesomeIcons.taxi,color: Colors.white, size: 20.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                height: requestDetailsContainerHeight,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children:[
                      SizedBox(height: 12.0),

                      SizedBox(
                        width: double.infinity,
                        child: ColorizeAnimatedTextKit(
                          onTap: () {
                            print("Tap Event");
                          },
                          text: [
                            "Yolculuk İsteniyor...",
                            "Lütfen bekleyin...",
                            "Bir taksi Bulunuyor ...",
                          ],
                          textStyle: TextStyle(
                            fontSize: 35.0,
                            fontFamily: "Signatra"
                          ),
                          colors: [
                            Colors.green,
                            Colors.purple,
                            Colors.pink,
                            Colors.blue,
                            Colors.yellow,
                            Colors.red,
                          ],
                          textAlign: TextAlign.start,
                          alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                        ),
                      ),
                      SizedBox(height: 22.0,),

                      GestureDetector(
                        onTap: ()
                        {
                          cancelRideRequest();
                          resetApp();
                        },
                        child: Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26.0),
                              border: Border.all(width: 2.0, color: Colors.grey[300]),
                            ),
                            child: Icon(Icons.close, size: 26.0,),
                          ),
                      ),

                      SizedBox(height: 10.0,),

                      Container(
                        width: double.infinity,
                        child: Text("İptal et", textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0),),
                      ),
                    ],
              ),
                ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> getPlaceDirection() async
  {
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
      context: context,
      builder: (BuildContext context) => IlerlemeDiyalogu(message: "Lütfen bekleyin..."),
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    print("This is Encoded Points ::");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if(decodedPolyLinePointsResult.isNotEmpty)
    {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();

   setState(() {
     Polyline polyline = Polyline( //yol cizgisi ozellikleri
       color: Colors.pink,
       polylineId: PolylineId("PolylineID"),
       jointType: JointType.round,
       points: pLineCoordinates,
       width: 5,
       startCap: Cap.roundCap,
       endCap: Cap.roundCap,
       geodesic: true,
     );

     polylineSet.add(polyline);
   });

     LatLngBounds latLngBounds;
    if(pickUpLatLng.latitude > dropOffLatLng.latitude  &&  pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    }
    else if(pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude), northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    }
    else if(pickUpLatLng.latitude > dropOffLatLng.latitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude), northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    }
    else
    {
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

     newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds,70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

}

