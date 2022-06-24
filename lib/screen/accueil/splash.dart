import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_deliver_app/common/helpers.dart';
import 'package:supply_deliver_app/common/palette.dart';
import 'package:supply_deliver_app/screen/accueil/into.dart';
import 'package:supply_deliver_app/screen/manager/components/manager_home.dart';

import '../../services/auth1_service.dart';
import '../manager/components/inscription/inscription_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool isFirstRun = true;

  _fetch() async {
    final prefs = await SharedPreferences.getInstance();
    final showHome = prefs.getBool('isAuthenticated') ?? false;
    final id = prefs.getString('id') ?? '';
    var isInscription = prefs.getBool('InscriptionName') ?? false;
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && (isInscription == false) && (showHome == false)) {
      push(context, const IntroScreen(), replace: true);
      return;
    } else if (mounted && (isInscription == true) && (showHome == false)) {
      push(context, const InscriptionName(), replace: true);
    } else if (mounted && (showHome == true)) {
      push(context, ManagerHome(currentManagerID: id), replace: true);
    }

    /*     
    AuthService.isLogged().then((value) {
      if (!value) {
        push(context, const SignInScreen(), replace: isInscription);
        
      }
    }); */
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Container(
                height: size.height * 0.5,
                width: size.width * 0.6,
                child: Image.asset("assets/images/logo.png"),
              ),
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black.withOpacity(.7),
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
              children: [
                const TextSpan(text: "deliver"),
                TextSpan(
                  text: "er",
                  style: TextStyle(color: Palette.primarySwatch.shade300),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
