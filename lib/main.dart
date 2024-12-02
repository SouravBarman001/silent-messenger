import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

import 'package:we_chat/screens/sign_language/constraints.dart';
import 'package:we_chat/screens/sign_language/live_translation.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

//global object for accessing device screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //loadDetectionModel();
  cameras = await availableCameras();
  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

   await _initializeFirebase();
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey: "AIzaSyA1agQF8nNs1DCz6l6KkY__tcD5v2CroFs",
  //     authDomain: "test-chat-47cd4.firebaseapp.com", // Constructed based on standard Firebase domain format
  //     databaseURL: "https://test-chat-47cd4.firebaseio.com", // Constructed based on standard Firebase database URL format
  //     projectId: "test-chat-47cd4",
  //     appId: "1:328288931432:android:e2a5ddb61584067b2135dd",
  //     messagingSenderId: "328288931432", // Extracted from project_number
  //     storageBucket: "test-chat-47cd4.appspot.com",
  //   ),
  // );

  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'We Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: false,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 1,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 19),
              backgroundColor: Colors.white,
            )),
        home:  const SplashScreen());
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  var result = await FlutterNotificationChannel().registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');

  log('\nNotification Channel Result: $result');
}


// Future<void> _initializeFirebase() async {
//   try {
//     // Check if Firebase is already initialized
//     if (Firebase.apps.isEmpty) {
//       await Firebase.initializeApp(
//         options: const FirebaseOptions(
//           apiKey: "AIzaSyA1agQF8nNs1DCz6l6KkY__tcD5v2CroFs",
//           authDomain: "test-chat-47cd4.firebaseapp.com",
//           databaseURL: "https://test-chat-47cd4.firebaseio.com",
//           projectId: "test-chat-47cd4",
//           appId: "1:328288931432:android:e2a5ddb61584067b2135dd",
//           messagingSenderId: "328288931432",
//           storageBucket: "test-chat-47cd4.appspot.com",
//         ),
//       );
//     } else {
//       log('Firebase is already initialized.');
//     }
//
//     var result = await FlutterNotificationChannel().registerNotificationChannel(
//       description: 'For Showing Message Notification',
//       id: 'chats',
//       importance: NotificationImportance.IMPORTANCE_HIGH,
//       name: 'Chats',
//     );
//
//     log('\nNotification Channel Result: $result');
//   } catch (e) {
//     log('Error initializing Firebase: $e');
//   }
// }

