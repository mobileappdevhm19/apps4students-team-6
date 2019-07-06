import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_campus_connected/services/authentication.dart';
import 'package:flutter_campus_connected/logos/login_logo.dart';
import 'package:flutter_campus_connected/pages/welcome_page.dart';
import 'package:flutter_campus_connected/utils/screen_aware_size.dart';

class LoginSignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage>
    with SingleTickerProviderStateMixin {
  Auth auth = new Auth();

  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _email;
  String _password;
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@hm.edu$',
  );
  AnimationController _animationController;
  Animation _animation;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _animationController = new AnimationController(
        vsync: this, duration: Duration(microseconds: 500));
    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //it will show when procesing to login
  Widget _showCircularProgressIndicator() {
    if (_isLoading) {
      return Container(
        margin: EdgeInsets.all(10),
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  //for showing response we get from firebase auth
  void _showSnackBar(String msg) {
    SnackBar snackBar = new SnackBar(
      content: new Text(
        msg,
        style: TextStyle(color: Colors.white),
      ),
      duration: new Duration(seconds: 5),
      backgroundColor: Colors.black,
      action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          }),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => SystemNavigator.pop(),
      child: Theme(
        data: ThemeData(
          primaryColor: Theme.of(context).primaryColor,
        ),
        child: Scaffold(
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.red, Colors.redAccent])),
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Align(
                    child: _showCircularProgressIndicator(),
                    alignment: Alignment.bottomCenter,
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.height * 0.12,
                      child: _showLogo()),
                  Positioned(
                      width: MediaQuery.of(context).size.width - 30,
                      top: MediaQuery.of(context).size.height * 0.35,
                      child: _showBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      FocusScope.of(context).requestFocus(new FocusNode()); //keyboard close
      form.save();
      return true;
    }
    return false;
  }

  // Perform login
  void _validateAndSubmit() async {
    FocusScope.of(context).requestFocus(new FocusNode()); //keyboard close
    if (_validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      String userId = "";
      try {
        userId = await auth.signIn(_email, _password);
        bool isUserVerified = await auth.isEmailVerified();
        if (userId != null && isUserVerified) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return WelcomePage(
              firebaseUser: userId,
            );
          }));
        } else if (userId != null && !isUserVerified) {
          auth.sendEmailVerification();
          _showSnackBar(
              'Please verify your email adress. A verification link has been sent to given email Adress');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null) {}
      } catch (e) {
        if (e.toString().contains('PlatformException')) {
          print('Error: $e');
          setState(() {
            _isLoading = false;
            if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
              _showSnackBar('Email adress or password is invalid');
            } else if (e.toString().contains('ERROR_WRONG_PASSWORD')) {
              _showSnackBar('Email adress or password is invalid');
            } else {
              _showSnackBar(e.toString());
            }
          });
        }
      }
    }
  }

  //White Card
  Widget _showBody() {
    return Container(
        child: new Form(
      key: _formKey,
      child: Card(
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: screenAwareSize(20, context)),
            _showEmailInput(),
            _showPasswordInput(),
            SizedBox(height: screenAwareSize(20, context)),
            _showPrimaryButton(context),
            SizedBox(height: screenAwareSize(10, context)),
            _showSecondaryButton(),
            SizedBox(height: screenAwareSize(10, context)),
            _showThirdButton(),
          ],
        ),
      ),
    ));
  }

  //app Logo
  Widget _showLogo() {
    return new Hero(
        tag: 'hero',
        child: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, Widget widger) {
            return LoginLogo(
              size: _animation.value * screenAwareSize(100, context),
            );
          },
        ));
  }

//user email
  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 10),
      child: TextFormField(
        key: Key("Email"),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            contentPadding: EdgeInsets.all(0.0),
            filled: true,
            labelText: 'Email',
            fillColor: Colors.white,
            prefixIcon: new Icon(
              Icons.mail,
            )),
        validator: (value) {
          if (value.isEmpty) {
            return 'Email can\'t be empty';
          } else if (!_emailRegExp.hasMatch(value)) {
            return 'Invalid Email. Try example@hm.edu';
          }
        },
        onSaved: (value) => _email = value,
      ),
    );
  }

//user Password
  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14),
      child: TextFormField(
        key: Key("Password"),
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            filled: true,
            labelText: 'Password',
            contentPadding: EdgeInsets.all(0.0),
            fillColor: Colors.white,
            prefixIcon: new Icon(
              Icons.lock,
            )),
        validator: (value) {
          if (value.isEmpty) {
            return 'Password can\'t be empty';
          } else if (value.length < 6) {
            return 'Password can\'t be less than 6 character';
          }
        },
        onSaved: (value) => _password = value,
      ),
    );
  }

//to navigate to the sign up page
  Widget _showSecondaryButton() {
    return Align(
      child: FlatButton(
        child: new Text('Create an account',
            style: new TextStyle(
                fontSize: screenAwareSize(18, context),
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        onPressed: () {
          Navigator.of(context).pushNamed('/signup');
        },
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  //to navigate to the sign up page
  Widget _showThirdButton() {
    return Align(
      child: FlatButton(
        child: new Text('Forgot password? Click here for Reset',
            style: new TextStyle(
                fontSize: screenAwareSize(12, context),
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        onPressed: () {
          Navigator.of(context).pushNamed('/passwordreset');
        },
      ),
      alignment: Alignment.bottomCenter,
    );
  }

//login button
  Widget _showPrimaryButton(context) {
    return SizedBox(
      width: screenAwareSize(200, context),
      height: screenAwareSize(40, context),
      child: RaisedButton(
        key: Key("Login"),
        elevation: 8.0,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0)),
        color: _isLoading == false ? Colors.red : Colors.redAccent,
        child: new Text('Login',
            style: new TextStyle(
                fontSize: screenAwareSize(18, context), color: Colors.white)),
        onPressed: _isLoading == false ? _validateAndSubmit : null,
      ),
    );
  }
}
