import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supply_deliver_app/screen/manager/components/inscription/inscription_name.dart';
import 'package:supply_deliver_app/screen/accueil/into.dart';

push(BuildContext context, Widget page, {bool replace = false}) async {
  MaterialPageRoute pageRoute =
      MaterialPageRoute(builder: (BuildContext context) => page);
  
 /*  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              isInscription ? SignInScreen() : IntroScreen())); */
  replace
      ? await Navigator.of(context).pushReplacement(pageRoute)
      : await Navigator.of(context).push(pageRoute);
}
