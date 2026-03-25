import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notiflex/screens/platform_selection_screen.dart';
import 'package:notiflex/services/notifications_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:notiflex/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();
  final notificationService = NotificationService();
  notificationService.initNotification();
  tz.initializeTimeZones();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotiFlex',
      theme: ThemeData(
        primaryColor: const Color(0xFF9C27B0),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.hasData
              ? const PlatformSelectionScreen()
              : const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
