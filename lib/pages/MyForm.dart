import 'package:flutter/material.dart';

enum GenderList { male, female }

class MyForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyFormState();
}

class MyFormState extends State<MyForm>{
  final _formKey = GlobalKey<FormState>();
  GenderList _gender;
  bool _agreement = false;

  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      appBar: new AppBar(title: new Text('Registration'),
        backgroundColor: Colors.red,),
      body:
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: new Form(key: _formKey, child: new Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              new Text('First Name:', style: TextStyle(fontSize: 14.0)),
              new TextFormField(validator: (value) {
                if (value.isEmpty) return 'Please enter a first name';
              }),
              new SizedBox(height: 6.0),
              new Text('Last Name:', style: TextStyle(fontSize: 14.0)),
              new TextFormField(validator: (value) {
                if (value.isEmpty) return 'Please enter a last name';
              }),
              new SizedBox(height: 6.0),
              new Text('Gender:', style: TextStyle(fontSize: 14.0),),


              Row(
                children: <Widget>[
                  new Container(
                    width: 170.0,
                    child: RadioListTile(
                      title: const Text('Masculine', style: TextStyle(fontSize: 14.0)),
                      activeColor: Colors.red,
                      value: GenderList.male,
                      groupValue: _gender,
                      onChanged: (GenderList value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),),
                  new Container(
                    width: 170.0,
                    child: RadioListTile(
                      title: const Text('Feminine', style: TextStyle(fontSize: 14.0)),
                      activeColor: Colors.red,
                      value: GenderList.female,
                      groupValue: _gender,
                      onChanged: (GenderList value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),),
                ],
              ),

              new SizedBox(height: 6.0),

              new Text('Faculty:', style: TextStyle(fontSize: 14.0),),
              new TextFormField(validator: (value) {
                if (value.isEmpty) return 'Please enter faculty';
              }),

              new SizedBox(height: 6.0),

              new Text('Hobby:', style: TextStyle(fontSize: 14.0),),
              new TextFormField(validator: (value) {
                if (value.isEmpty) return 'Please enter hobby';
              }),

              new SizedBox(height: 6.0),
              new CheckboxListTile(
                  value: _agreement,
                  title: new Text(
                      'I agree to the terms and condition.',
                      style: TextStyle(fontSize: 12.0)),
                  activeColor: Colors.red,
                  onChanged: (bool value) => setState(() => _agreement = value)
              ),

              new SizedBox(height: 6.0),

              new RaisedButton(onPressed: () {
                if (_formKey.currentState.validate()) {
                  Color color = Colors.red;
                  String text;

                  if (_gender == null)
                    text = 'Please enter your gender';
                  else if (_agreement == false)
                    text = 'Please agree to the terms and condition';
                  else {
                    text = 'Your profile is created';
                    color = Colors.green;
                  }

                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text(text), backgroundColor: color));
                }
              },
                child: Text('Create'),
                color: Colors.red,


                textColor: Colors.white,),
            ],)
          ),
          ),
      ),
    );
  }
}

