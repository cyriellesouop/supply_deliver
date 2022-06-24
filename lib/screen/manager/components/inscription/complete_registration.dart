import 'package:flutter/material.dart';

import '../../../../common/constants.dart';

class CompleteRegistrationScreen extends StatelessWidget {
  final String username;

  const CompleteRegistrationScreen({Key? key, required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: kDefaultPadding * 2, vertical: kDefaultPadding),
                height: size.height * 0.5,
                width: size.width * 0.6,
                child: Center(
                  child: Image.asset("assets/images/logo.png"),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: theme.textTheme.headline4,
                ),
                Text(
                  username,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Great job! you made it upto this point. Your account was successfully created and you can now use our services while we backup your progression and data.',
                  style: theme.textTheme.bodyLarge!.copyWith(fontSize: 15),
                  textAlign: TextAlign.justify,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        primary: Colors.black,
                        onPrimary: Colors.white),
                    onPressed: () {
                      /// TODO: push to the first complete page
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Complete registration',
                        style: theme.textTheme.headline6!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
