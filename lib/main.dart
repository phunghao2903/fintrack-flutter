import 'dart:ui';

import 'package:fintrack/core/di/injector.dart' as di;
import 'package:fintrack/core/services/notification_service.dart';
import 'package:fintrack/features/add_transaction/presentation/page/add_transaction_page.dart';

import 'package:fintrack/features/auth/presentation/page/sign_in_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('[onMessage] title=${message.notification?.title}, body=${message.notification?.body}');
  print('[onMessage] data=${message.data}');
});

  FirebaseMessaging.instance.requestPermission() ;
  await  NotificationService.instance.init(); 
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationService.instance.showForegroundNotification(message);
  });
  await di.init();
  runApp(const MyApp());

  // Setup cửa sổ khi app khởi động
  // doWhenWindowReady(() {
  //   const initialSize = Size(412, 892);
  //   // const initialSize = Size(412, 592); // Kích thước iPhone 12
  //   appWindow.minSize = initialSize;
  //   appWindow.size = initialSize;
  //   appWindow.alignment = Alignment.center; // Cửa sổ mở giữa màn hình
  //   appWindow.title = "Fintrack App";
  //   appWindow.show();
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // scrollBehavior: DesktopScrollBehavior(),
      // debugShowCheckedModeBanner: false,
      home: SignInPage(),
    );
  }
}

// class DesktopScrollBehavior extends MaterialScrollBehavior {
//   @override
//   Set<PointerDeviceKind> get dragDevices => {
//     PointerDeviceKind.touch,
//     PointerDeviceKind.mouse,
//     PointerDeviceKind.trackpad,
//     PointerDeviceKind.stylus,
//     PointerDeviceKind.unknown,
//   };
// }
