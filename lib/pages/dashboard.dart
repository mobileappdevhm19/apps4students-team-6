import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_campus_connected/helper/authentication.dart';
import 'package:flutter_campus_connected/models/dashboard_item.dart';
import 'package:flutter_campus_connected/models/event_model.dart';
import 'package:flutter_campus_connected/pages/create_event.dart';
import 'package:flutter_campus_connected/pages/profile.dart';
import 'package:flutter_campus_connected/pages/search_events.dart';
import 'package:flutter_campus_connected/pages/users_profile.dart';
import 'package:flutter_campus_connected/pages/view_event.dart';
import 'package:flutter_campus_connected/utils/screen_aware_size.dart';
//import 'package:flutter_campus_connected/pages/create_event.dart';

class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  FirebaseUser firebaseUser;
  String email = '';
  Auth auth = new Auth();
  EventModel eventModel;

  bool isLoggedIn = false;

  //to check if a user logged in or not , it will call from initState
  checkIsLoggedIn() async {
    auth.getCurrentUser().then((user) {
      if (user != null) {
        setState(() {
          isLoggedIn = true;
        });
      } else {
        setState(() {
          isLoggedIn = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    super.initState();
    checkIsLoggedIn();
    auth.getCurrentUser().then((user) {
      setState(() {
        firebaseUser = user;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: appBar(context),
      drawer: getDrawer(context),
      body: getBody(context),
    );
  }

  Drawer getDrawer(BuildContext context) {
    return Drawer(
      key: Key("Drawer"),
      child: ListView(
        children: <Widget>[
          appLogo(context),
          isLoggedIn ? profileNameAndImage(context, _getUserData()) : Container(),
          isLoggedIn ? Divider() : Container(),
          isLoggedIn
              ? Container()
              : drawerItem(context, 'Login', Icons.account_circle, 'login'),
          isLoggedIn
              ? drawerItem(context, 'Users', Icons.person, 'users')
              : Container(),
          drawerItem(context, 'Events', Icons.event_available, 'events'),
          drawerItem(context, 'Create Events', Icons.event, 'login'),
          isLoggedIn
              ? drawerItem(context, 'Log Out', Icons.exit_to_app, 'logout')
              : Container(),
        ],
      ),
    );
  }

  Container getBody(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder(
        stream: Firestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return eventList(snapshot);
        },
      ),
    );
  }

  //events List
  ListView eventList(AsyncSnapshot snapshot) {
    return ListView.builder(
        itemCount: snapshot.data.documents.length,
        itemBuilder: (context, ind) {
          return Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            margin: EdgeInsets.all(6.0),
            elevation: 3.0,
            child: ListTile(
              title: Text(
                snapshot.data.documents[ind]['eventName'],
                style: TextStyle(fontSize: 20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  snapshot.data.documents[ind]['eventDescription'],
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Hero(
                    tag: snapshot.data.documents[ind].documentID,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: screenAwareSize(80, context),
                        height: screenAwareSize(60, context),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/loadingfailed.png',
                          image: snapshot.data.documents[ind]['eventPhotoUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(new MaterialPageRoute(builder: (context) {
                  return EventView(
                    snapshot.data.documents[ind],
                    firebaseUser,
                  );
                }));
              },
            ),
          );
        });
  }

  //appBar
  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text('Campus Connected'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return SearchEvent();
            }));
          },
        )
      ],
    );
  }

  //appLogo
  Container appLogo(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      height: screenAwareSize(150, context),
      child: Center(
        child: FlutterLogo(
          size: screenAwareSize(80, context),
        ),
      ),
    );
  }

  //drawer Item profile name and Image
  Padding profileNameAndImage(BuildContext context,  Stream<QuerySnapshot> data) {
    return Padding(
      padding: EdgeInsets.only(
          top: screenAwareSize(12.0, context),
          bottom: screenAwareSize(8.0, context)),
      child: StreamBuilder(
        stream: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          final item = DashbaoardItem(snapshot.data.documents[0]['displayName'],
            snapshot.data.documents[0]['photoUrl'],);
          return getListItem((snapshot.hasData && snapshot.data.documents.length == 0), item, context);
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getUserData() {
    return Firestore.instance
        .collection('users')
        .where('uid', isEqualTo: firebaseUser.uid)
        .snapshots();
  }

  StatelessWidget getListItem(bool val,DashbaoardItem item, BuildContext context) {
    return !(val)
        ? ListTile(
      title: Text(
        item.displayName,
        //snapshot.data.documents[0]['displayName'],
        style: TextStyle(fontSize: 18),
        maxLines: 1,
        key: Key('UserName'),
        overflow: TextOverflow.ellipsis,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: screenAwareSize(50, context),
          height: screenAwareSize(50, context),
          child: FadeInImage.assetNetwork(
            image: item.photoUrl,
            //snapshot.data.documents[0]['photoUrl'],
            fit: BoxFit.cover,
            placeholder: 'assets/person.jpg',
          ),
        ),
      ),
      onTap: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) {
          return ProfilePage(
            firebaseUser: firebaseUser,
          );
        }));
      },
    )
        : Container();
  }

  //drawer Items
  ListTile drawerItem(BuildContext context, String title, IconData icon,
      [String route]) {
    return new ListTile(
      key: Key(title),
      title: Text(title),
      leading: Icon(icon),
      onTap: () {
        if (route == 'logout') {
          Navigator.of(context).pop();
          FirebaseAuth.instance.signOut();
          checkIsLoggedIn();
        } else if (route == 'events') {
          Navigator.of(context).pop();
        } else if (route == 'login') {
          Navigator.of(context).pop();
          isLoggedIn
              ? Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
            return CreateEvent(
              currentUser: firebaseUser,
            );
          }))
              : Navigator.of(context).pushNamed('/login');
        } else if (route == 'users') {
          Navigator.of(context).pop();
          isLoggedIn
              ? Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
            return UsersProfile();
          }))
              : Navigator.of(context).pushNamed('/login');
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
