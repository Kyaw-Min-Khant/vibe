import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/providers/user_provider.dart';
import 'package:messaging_app/routes/custom_bottomnavigation.dart';
import 'package:messaging_app/screens/login_screen.dart';
import 'package:messaging_app/screens/room_screen.dart';
import 'package:messaging_app/screens/signup_screen.dart';
import 'package:messaging_app/services/appwrite_service.dart';
import 'package:messaging_app/services/firebase_messaging_service.dart';
import 'package:messaging_app/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🌙 Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  AppWriteService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseMessagingService.instance.init();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  await SocketService().init();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messaging App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const CustomBottomNavigation(),
        '/room': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return RoomScreen(
            friendId: args['friendId'],
            friendUsername: args['friendUsername'],
            friendAvatar: args['friendAvatar'],
            activeStatus: args['activeStatus'],
            lastSeen: args['lastSeen'],
          );
        },
      },
      // home: LoginScreen(),
    );
  }
}
