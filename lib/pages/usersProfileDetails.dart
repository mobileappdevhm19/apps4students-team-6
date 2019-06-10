import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_campus_connected/helper/cloud_firestore_helper.dart';
import 'package:flutter_campus_connected/pages/view_event.dart';
import 'package:flutter_campus_connected/utils/screen_aware_size.dart';

class UsersProfileDetails extends StatefulWidget {
  final details;

  UsersProfileDetails({this.details});

  @override
  _UsersProfileDetailsPageState createState() =>
      _UsersProfileDetailsPageState();
}

class _UsersProfileDetailsPageState extends State<UsersProfileDetails> {
  String photoUrl;
  String displayName;
  FireCloudStoreHelper cloudStoreHelper = new FireCloudStoreHelper();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
      },
      child: Scaffold(
        appBar: appBar(context),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            topPart(context),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(7),
                child: Text(
                  'My Events',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: screenAwareSize(16, context)),
                ),
              ),
            ),
            bottomEventListPart()
          ],
        ),
      ),
    );
  }

  // organized Event List by the user
  Expanded bottomEventListPart() {
    return Expanded(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('events')
            .where('createdBy', isEqualTo: widget.details['uid'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, ind) {
                return Card(
                  margin: EdgeInsets.all(6.0),
                  elevation: 3.0,
                  child: ListTile(
                    title: Text(
                      snapshot.data.documents[ind]['eventName'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                          snapshot.data.documents[ind]['eventDescription'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16)),
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
                                image: snapshot.data.documents[ind]
                                    ['eventPhotoUrl'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.visibility,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) {
                                return EventView(
                                  snapshot.data.documents[ind],
                                );
                              }));
                            }),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              });
        },
      ),
    );
  }

  //users's photo, name , email
  Container topPart(BuildContext context) {
    return Container(
      color: Colors.red,
      height: MediaQuery.of(context).size.height / 3,
      child: Center(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .where('uid', isEqualTo: widget.details['uid'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }

            if (!(snapshot.hasData && snapshot.data.documents.length == 0)) {
              photoUrl = snapshot.data.documents[0]['photoUrl'];
              displayName = snapshot.data.documents[0]['displayName'];
            } else {
              return Container();
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 120,
                        height: 120,
                        child: Image.asset(
                          'assets/person.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                          width: 120,
                          height: 120,
                          child: Image(
                            image: NetworkImage(
                                snapshot.data.documents[0]['photoUrl']),
                            fit: BoxFit.cover,
                          )),
                    )
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      snapshot.data.documents[0]['displayName'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenAwareSize(20, context),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    )),
                Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      snapshot.data.documents[0]['email'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenAwareSize(18, context)),
                    ))
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return new AppBar(
      backgroundColor: Colors.red,
      elevation: 0.0,
      leading: new IconButton(
        icon: new Icon(
          Icons.arrow_back_ios,
        ),
        color: const Color(0xFFDDDDDD),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
