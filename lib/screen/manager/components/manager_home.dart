// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  UserModel currentManager = new UserModel(name: 'fabiol');
  //var Deliver = Map<UserModel, double>();
  // var deliver = null;
  bool isdeliver = false;
  bool isDev = false;
  var taille = 0;

 // var icon = BitmapDescriptor.defaultMarker;
//pour le appBar
  bool isSearching = false;
  var deliver = UserModel(name: 'audrey').toMap();
  var Dev = UserModel(name: 'audrey');
  Map<String, dynamic> tab = {
    'Deliver': UserModel(name: 'audrey'),
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

  UserModel? exampleModel = new UserModel(name: 'fabiol');

  UserService ServiceUser = new UserService();
  PositionService ServicePosition = new PositionService();
  //PositionModel x = new PositionModel(longitude: 0, latitude: 0);
  LatLng currentManagerPosition = new LatLng(0, 0);
  PositionModel xdeliver = new PositionModel(longitude: 0, latitude: 0);
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

  /* _listDeliver() async {
    await ServiceUser.getDelivers().forEach((element) {
      setState(() {
        this.exampleModelDeliver = element;
      });

      print(
          "le nombre de livreur est exactement ${exampleModelDeliver.length}");
    });

    print("le nombre de livreur est ${exampleModelDeliver.length}");
    return exampleModelDeliver.length;
  } */

  //changer la couleur du markeur

  //liste de posiition des livreur
getUserPosition() async {
  
    LatLng coordonnees = new LatLng(0, 0);

    //get current manager and current manager position
    await ServiceUser.getUserbyId(widget.currentManagerID).then((value) {
      setState(() {
        currentManager = value;
        print('currrent user $currentManager');
      });
    });
     print("la position du current manager est: ${currentManager.idPosition}");

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
        print(
            "dans le then la latitude manager est ${currentManagerPosition.latitude}, et sa longitude est ${currentManagerPosition.longitude}");
      },
    ).catchError((onError){print("le marker est incorrecte");});
    print(
        "la latitude du manager est ${currentManagerPosition.latitude}, et sa longitude est ${currentManagerPosition.longitude}");
    //end



    //affiche la position du current manager
    print('curent usermanager position ${this.currentManager}');
    //recupere la liste de livreurs
    print('curent userposition ${this.currentManager}');
    await ServiceUser.getUsers().forEach((element) async {
      //modifier la letat de la liste des livreurs
      setState(() {
        this.exampleModelDeliver = element;
      });

      var n = -1;
      //pour chaque livreur, on renvoie sa posion
      for (var i in this.exampleModelDeliver) {
        n++;
        await ServicePosition.getPosition(i.idPosition).then((value) {
          LatLng coordonnees = LatLng(value.latitude, value.longitude);

          print(
              'la coordonnees est actuellement la latitude:${coordonnees.latitude} et la longitude est :${coordonnees.longitude}');
          //modifier l'etat de la liste des positions de chaque livreurs et de la table des identifiants
          setState(() {
            listecoordonnees.add(coordonnees);
            print('la liste de coordonnees mise a jour est:$listecoordonnees');
            //mise a jour du tableau contenant les infos sur les livreurs et leur distance
            tableauJson.add({
              //json.decode9tableaujson[i]['Deliver']
              "Deliver": i.toMap(),
              "Distance": getDistance(this.currentManagerPosition, coordonnees)
            });
            taille++;
            print('lacoordonnees est:$coordonnees');
            print('le tableau json mise a jour est:$listecoordonnees');

            //  Deliver[i]=getDistanceBetween(this.currentManagerPosition, this.listecoordonnees)[n];

            /*   deliver = {
              "Deliver": i,
              "Distance": getDistance(
                      this.currentManagerPosition, coordonnees)
                  
            };*/

            //marquage sur la map de tous les livreurs contenus dans la precedente liste
            //-------------------------------------------
            markers.add(Marker(
                //add start location marker
                markerId: MarkerId(coordonnees.toString()),
                position: coordonnees,
                infoWindow: InfoWindow(
                  //popup info
                  title: i.isDeliver
                      ? 'Livreur ${i.name} '
                      : 'entreprise ${i.name} ',
                  //le user name envoye depuis la page de validation
                  snippet:
                      ' situe a ${getDistance(this.currentManagerPosition, coordonnees)} km de vous',
                ),
                icon: i.isDeliver
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet)
                    : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                /* icon: WhichIcon(widget.currentManagerID, i.idUser, i.isDeliver)
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet)
                    : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen), */
           /*      onTap: () {
                  setState(() {
                    isDev = false;

                    Dev = i;
                  });
                  Dev != UserModel(name: 'audrey')
                      ? isDev = true
                      : isDev = false;
                }  *///Icon for Marker
                ));

            print(
                'la tailles de liste des marqueurs est : ${markers.length} et les marqueurs sont : $markers');

            //marquage de tous les livreurs sur la map
            //-------------------------------------------
          });
        });
      }
      /*  setState(() {
       tableauJsontrie = TriRapidejson(table: tableauJson).QSort(0, n - 1) ;
      }); */
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
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
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
    // final allDelivers = Provider.of<List<UserModel>>(context);
    // var n = this.tableauJson.length;
    print(
        'la tailles de liste des marqueurs est : ${markers.length} et les marqueurs sont : $markers');

   /*  setState(() {
      tableauJsontrie = tableauTrie(
          TriRapidejson(table: this.tableauJson).QSort(0, this.taille - 1));
    }); */

    // DeliverSort = listeTrie(tableauJsontrie);
    print('les distances sont :${exampleModelDeliver}');

    print('la table json esst $tableauJson');
    print('le tableau json trie est ${tableauJsontrie.length}');
    /* print(
        'la liste des distance et livreurs associees est ${TriRapide(table: this.DistanceInter).tableauTrie(this.Distances)}');
 */
    return Scaffold(
      drawer: NavBar(
        currentManagerID: widget.currentManagerID,
      ), //Visibility(visible: isVisible(), child: NavBar()),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        //   backgroundColor: Colors.transparent,
        title: /* !isSearching
                  ? Text(
                      'Mon application',
                      style: GoogleFonts.philosopher(fontSize: 20),
                    )
                  : */
            Text('Mon application'),
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
      body: /* SingleChildScrollView(
        child: */
          Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            //height: size.height,
            child: GoogleMap(
              zoomGesturesEnabled: true, //enable Zoom in, out on map
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: this.currentManagerPosition,
                zoom: 10,
              ),
              markers: this.markers, //markers to show on map
              // polylines: Set<Polyline>.of(polylines.values), //polyl
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
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
  double getDistance(
      LatLng currentManagerPosition, LatLng positionDeliverList) {
    var dist;

    dist = calculateDistance(
        currentManagerPosition.latitude,
        currentManagerPosition.longitude,
        positionDeliverList.latitude,
        positionDeliverList.longitude);

    //  return tableauTrie(Distances);
    return dist;
    // TriRapide(table: this.DistanceInter).tableauTrie(this.DistanceInter);
  }


