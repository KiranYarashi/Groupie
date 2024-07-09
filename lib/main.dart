import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:groupchat/constraints.dart';
import 'package:groupchat/firebase_options.dart';
import 'package:groupchat/helper/helper_function.dart';
import 'package:groupchat/pages/auth/login_page.dart';
import 'package:groupchat/pages/home_page.dart';

import 'package:groupchat/pushnot/local_notifications.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;

//import 'package:student2/push_notification/push_notification.dart';

// Future _firebaseBackgroundMessage(RemoteMessage message) async {
//   if (message.notification != null) {
//     print("Some notification Received");
//   }
// }
// final navigatorKey = GlobalKey<NavigatorState>();
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
final navigatorKey = GlobalKey<NavigatorState>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // PushNotifications.init();
    // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
    // var initialNotification =
    //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    // if (initialNotification?.didNotificationLaunchApp == true) {
    //   // LocalNotifications.onClickNotification.stream.listen((event) {
    //   Future.delayed(Duration(seconds: 1), () {
    //     // print(event);
    //     navigatorKey.currentState!.pushNamed('/another',
    //         arguments: initialNotification?.notificationResponse?.payload);
    //   });
    // }

//  handle in terminated state
    var initialNotification =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (initialNotification?.didNotificationLaunchApp == true) {
      // LocalNotifications.onClickNotification.stream.listen((event) {
      Future.delayed(Duration(seconds: 1), () {
        // print(event);
        navigatorKey.currentState!.pushNamed('/another',
            arguments: initialNotification?.notificationResponse?.payload);
      });
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Constants().primaryColor,
          scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? const HomePage() : const LoginPage(),
      //home: MyhomePage(title: 'Flutter Local Notifications'),
      // routes: {
      //   '/': (context) => const Homepage(),
      //   '/another': (context) => const AnotherPage(),
      // },
    );
  }
}
