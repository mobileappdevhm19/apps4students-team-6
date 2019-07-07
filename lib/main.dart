import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_campus_connected/pages/faq_page.dart';
import 'package:flutter_campus_connected/pages/password_reset.dart';
import 'package:flutter_campus_connected/pages/privacy_policy.dart';

import 'package:flutter_campus_connected/services/authentication.dart';
import 'pages/create_event.dart';
import 'pages/dashboard.dart';
import 'pages/login_signup_page.dart';
import 'pages/profile.dart';
import 'pages/signup_page.dart';
import 'pages/users_profile.dart';
import 'root_page.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

Future main() async {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final Brightness brightness = Brightness.light;
  MyApp({Brightness brightness});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return new DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
            primarySwatch: Colors.red,
            brightness: brightness,
            accentColor: Colors.redAccent,
          ),
      themedWidgetBuilder: (context, theme) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: theme.primaryColor, // status bar color
        ));
        return new MaterialApp(
          title: 'Campus Connected',
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder>{
            '/login': (BuildContext context) => new LoginSignUpPage(),
            '/dashboard': (BuildContext context) => new Dashboard(),
            '/signup': (BuildContext context) => new SignUpPage(),
            '/home': (BuildContext context) => new MyHomePage(),
            '/logout': (BuildContext context) => new LoginSignUpPage(),
            '/home': (BuildContext context) => new MyHomePage(),
            '/passwordreset': (BuildContext context) => new PasswordResetPage(),
            '/faq': (BuildContext context) => new FAQPage(),
            '/privacy_policy': (BuildContext context) => new PrivacyPolicy()
          },
          theme: theme,
          home: new RootPage(),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  var firebaseUser;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseUser firebaseUser;
  Auth auth = new Auth();
  int currentTab = 0;

  Dashboard dashboard;
  UsersProfile usersProfile;
  CreateEvent createEvent;
  ProfilePage profilePage;
  static List<Widget> pages;
  Widget currentPage;
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    auth.getCurrentUser().then((user) {
      setState(() {
        firebaseUser = user;
        dashboard = Dashboard();
        usersProfile = UsersProfile(firebaseUser);
        createEvent = CreateEvent(currentUser: firebaseUser);
        profilePage = ProfilePage(firebaseUser: firebaseUser);
        pages = [dashboard, usersProfile, createEvent, profilePage];
      });
    });
    pages = [dashboard, usersProfile, createEvent, profilePage];
    currentPage = dashboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentTab],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab,
        onTap: (int index) {
          setState(() {
            currentTab = index;
            currentPage = pages[index];
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text(''),
          ),
        ],
      ),
    );
  }
}
