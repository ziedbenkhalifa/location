import 'dart:async';
import 'package:flutter/material.dart';
import 'package:malocation/pages/home.dart';
import 'package:malocation/main.dart';
import 'package:malocation/pages/crudclient.dart';
import 'package:malocation/pages/crudlocation.dart';
import 'package:malocation/pages/crudvoiture.dart';
import 'package:malocation/auth.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  final String role;

  const SplashScreen({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(seconds: 3),
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainApp(role: role)),
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Lottie.asset(
                    'assets/Lottie/Animation - 1723805346832.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 150,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Lottie.asset(
                    'assets/Lottie/Animation - 1711455985630.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
