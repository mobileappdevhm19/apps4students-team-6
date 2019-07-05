import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CampusLogo extends StatelessWidget {
  CampusLogo({
    Key key,
    this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
          fit: StackFit.expand, children: <Widget>[_showLogo(context)]),
    );
  }

  Widget _showLogo(BuildContext context) {
    return new Material(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Image.asset(
          'assets/flutter-icon.png',
          width: 100.0,
          height: 100.0,
        ),
      ),
    );
  }
}
