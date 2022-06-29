// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supply_deliver_app/common/constants.dart';
import 'package:supply_deliver_app/common/palette.dart';
import 'package:http/http.dart' as http;
import 'package:supply_deliver_app/models/Database_Model.dart';
import 'package:supply_deliver_app/screen/manager/components/mySearch.dart';
import 'package:supply_deliver_app/services/user_service.dart';

import '../../../main.dart';
import '../../../services/position_service.dart';
import '../menu_content/nav_bar.dart';
import '../tri_rapide.dart';

class ManagerHome extends StatefulWidget {
  //UserModel currentManager;
  String currentManagerID;
  ManagerHome({required this.currentManagerID, Key? key}) : super(key: key);
  @override
  _ManagerHomeState createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  // initialisation du manager courant
  UserModel currentManager = new UserModel(name: 'fabiol', idDoc: "audrey");
  //var Deliver = Map<UserModel, double>();
  // var deliver = null;
  bool isdeliver = false;
  bool isDev = false;
  var taille = 0;

  // var icon = BitmapDescriptor.defaultMarker;
//pour le appBar
  bool isSearching = false;
  var deliver = new UserModel(name: 'fabiol', idDoc: "audrey").toMap();
  var Dev = new UserModel(name: 'fabiol', idDoc: "audrey");
  Map<String, dynamic> tab = {
    'Deliver': new UserModel(name: 'fabiol', idDoc: "audrey"),
    'Distance': 0
  };

  List<Map<String, dynamic>> tableauJson = [];
  List<Map<String, dynamic>> tableauJsontrie = [];

  List<UserModel> DeliverSort = [];

  //  LatLng startLocation = LatLng(latCurrentManager,longCurrentManager);

  GoogleMapController? mapController; //controller pour Google map
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyDMvPHsbM0l51gW4shfWTHMUD-8Df-2UKU"; //google api
  //Marker est un tableau qui contient toutes les positions representees sur la map

  final Set<Marker> markers = new Set(); //markers for google map
  // Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  UserModel? exampleModel = new UserModel(name: 'fabiol', idDoc: "audrey");
  CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("user");

  UserService ServiceUser = new UserService();
  PositionService ServicePosition = new PositionService();
  //PositionModel x = new PositionModel(longitude: 0, latitude: 0);
  LatLng currentManagerPosition = new LatLng(0, 0);
  PositionModel xdeliver =
      new PositionModel(idPosition: "", longitude: 0, latitude: 0);
  LatLng ydeliver = new LatLng(0, 0);

  //tableau des identifiants des position de tous les livreurs
  List<UserModel> exampleModelDeliver = [];
  //liste des positions de tous les livreurs
  List<LatLng> listecoordonnees = [];
  List<double> Distances = [];
  List<double> DistanceInter = [];

  @override
  void initState() {
    getUserPosition();
    requestPermission();
    loadFCM();
    listenFCM();
    listenOpenFCM();
    //   storedNotificationToken();
    display();
    super.initState();
  }

  getUserPosition() async {
    LatLng coordonnees = new LatLng(0, 0);
    //get current manager and current manager position
    await ServiceUser.getUserbyId(widget.currentManagerID).then((value) {
      setState(() {
        currentManager = value;
        print('currrent user $currentManager');
      });
    });
    await ServicePosition.getPosition('${currentManager.idPosition}').then(
      (value) {
        setState(() {
          currentManagerPosition = LatLng(value.latitude, value.longitude);
        });
        //Maquer le manager courant
        markers.add(Marker(
          //add distination location marker
          markerId: MarkerId(ydeliver.toString()),
          position: currentManagerPosition,
          infoWindow: InfoWindow(
            //popup info
            title: 'ma position ',
            snippet: currentManager.name,
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
      },
    ).catchError((onError) {
      print("le marker est incorrecte");
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      requestPermission();
    }
  }

/*   static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', //id
    'High Importance Notifications', //title

    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true); */

  display() async {
    print('channel channel channel');
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  void loadFCM() async {
    print("receive notification");
    if (!kIsWeb) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel', //id
          'High Importance Notifications', //title

          description: 'This channel is used for important notifications.',
          importance: Importance.high,
          playSound: true,
          enableVibration: true);
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void listenOpenFCM() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessage eevent was published');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(" ${notification.title}"),
                content: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(" ${notification.body}")],
                )),
              );
            });
      }
    });
  }

  void sendPushMessage(String body, String title, String? token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAALOR35JE:APA91bHzS-FNsPRD-UmapTvVLGxo3-uneI7xnuk1yZdWJqZjqLH-F65UoLc3VYtkcl13NmVgkYqxg4tlzVqg78CWmWMnNhm5ziF7nv8ekaIKpl6nb5onU76eeIgq1nU3oH03l1wfCc6F',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );

      print("notification is send");
    } catch (e) {
      print("error push notification");
    }
  }

//widget final
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(
        'la tailles de liste des marqueurs est : ${markers.length} et les marqueurs sont : $markers');
    print('les distances sont :${exampleModelDeliver}');

    print('la table json esst $tableauJson');
    print('le tableau json trie est ${tableauJsontrie.length}');
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Mon application'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: MysearchDelegate(
                    tableauJsontrie: tableauJson,
                    hintText: " rechercher un livreur",
                    current_user: currentManager),
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            child: StreamBuilder<Future<Set<Marker>>>(
                stream: userCollection
                  //  .where('isDeliver', isEqualTo: true)
                    .snapshots()
                    .map((event) async {
                  var users = event.docs;
                  for (var i in users) {
                    final user = i.data();
                    final UserModel Adeliver = UserModel(
                        idDoc: user['idDoc'],
                        idUser: user['idUser'],
                        adress: user['adress'],
                        name: user['name'],
                        phone: user['phone'],
                        tool: user['tool'],
                        picture: user['picture'],
                        idPosition: user['idPosition'],
                        isManager: user['isManager'],
                        isClient: user['isClient'],
                        isDeliver: user['isDeliver'],
                        token: user['token']);
                    await PositionService()
                        .getPosition(Adeliver.idPosition)
                        .then((value) async {
                      LatLng coordonnees =
                          LatLng(value.latitude, value.longitude);
                      var addresses = await GeocodingPlatform.instance
                          .placemarkFromCoordinates(
                              value.latitude, value.longitude);
                      var first = addresses.first;
                      print(
                          ' ${first.locality},${first.subLocality}, ${first.administrativeArea}, ${first.subAdministrativeArea},${first.street}, ${first.name},${first.thoroughfare}, ${first.subThoroughfare}');
                      setState(() {
                        final LatLng pos = currentManagerPosition;
                        markers.add(Marker(
                            //add start location marker
                            markerId: MarkerId(coordonnees.toString()),
                            position: coordonnees,
                            infoWindow: InfoWindow(
                              //popup info
                              title:Adeliver.isDeliver
                    ? 'Livreur ${Adeliver.name} A ${getDistance(pos, coordonnees)} km de vous'
                    : 'Entreprise ${Adeliver.name} A ${getDistance(pos, coordonnees)} km de vous',
                                  
                              //le user name envoye depuis la page de validation
                              snippet:
                                  '${first.locality}, ${first.street}, ${first.name}',
                            ),
                            icon: Adeliver.isDeliver
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueViolet)
                                : BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen),
                            onTap: () {} //Icon for Marker
                            ));
                      });
                    });
                  }
                  return markers;
                }),
                builder:
                    (context, AsyncSnapshot<Future<Set<Marker>>> snapshot) {
                  if (!snapshot.hasData) {
                    // ignore: prefer_const_constructors
                    return Center(
                      child: const CircularProgressIndicator(),
                    );
                  }
                  return GoogleMap(
                    zoomGesturesEnabled: true, //enable Zoom in, out on map
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: this.currentManagerPosition,
                      zoom: 10,
                    ),
                    markers: markers,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  );
                }),
          ),
          Positioned(
              bottom: size.width * 0.1,
              right: size.width * 0.02,
              // margin: const EdgeInsets.symmetric(vertical: kDefaultPadding / 5),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryColor,
                ),
                child: InkWell(
                  onTap: () {},
                  child: Stack(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_active,
                            size: 30,
                            color: Colors.white,
                          )),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(1),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Text(
                              "12",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              )),
          // )
        ],
      ),
      // ),
    );
  }
}

//calcul de la distance entre deux positions
double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var x = 12742 * asin(sqrt(a));
  return roundDouble(x, 2);
}

//fonction pour arrondir

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

//supprime les doublons dans une liste
List<Map<String, dynamic>> tableauTrie(List<Map<String, dynamic>> table) {
  int i, j, k;
  var n = table.length;
  for (i = 0; i < n; i++) {
    for (j = i + 1; j < n;) {
      if (table[j]['Distance'] == table[i]['Distance'] &&
          table[j]['Deliver']['name'] == table[i]['Deliver']['name'] &&
          table[j]['Deliver']['adress'] == table[i]['Deliver']['adress']) {
        table.removeAt(j);
        n--;
      } else
        j++;
    }
  }
  return table;
}

double getDistance(LatLng currentManagerPosition, LatLng positionDeliverList) {
  var dist;
  dist = calculateDistance(
      currentManagerPosition.latitude,
      currentManagerPosition.longitude,
      positionDeliverList.latitude,
      positionDeliverList.longitude);
  return dist;
}
