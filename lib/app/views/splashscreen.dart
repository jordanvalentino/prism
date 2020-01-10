import 'package:flutter/material.dart';
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    checkPrefs().then((value) {
      if (value) _loadResources().then((_) => _gotoHome());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.primary[500],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "PRISM",
                  style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: Theme.of(context).textTheme.display3.fontSize,
                      color: colors.primary[50]),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Priority-based Schedule Manager",
                  style: TextStyle(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: colors.primary[50],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            RaisedButton(
              color: colors.primary[700],
              child: Text(
                "GET STARTED",
                style: TextStyle(
                  color: colors.primary[50],
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, 'signin'),
            )
          ],
        ),
      ),
    );
  }

  void _gotoHome() => Navigator.pushReplacementNamed(context, 'master_home');

  Future<bool> checkPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('account')) return Future.value(true);
    return Future.value(false);
  }

  Future _loadResources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await globals.account.load();

    if (prefs.containsKey('events') || prefs.containsKey('tasks'))
      await globals.activities.load();
    if (prefs.containsKey('busys')) await globals.busys.load();
  }
}
