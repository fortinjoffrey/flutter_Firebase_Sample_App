import 'package:firebase_sample_app/models/user.dart';
import 'package:firebase_sample_app/models/user_data.dart';
import 'package:firebase_sample_app/services/databaseService.dart';
import 'package:firebase_sample_app/shared/constants.dart';
import 'package:firebase_sample_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  SettingsForm({Key key}) : super(key: key);

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  String _currentName;
  String _currentSugars;
  int _currentStrength;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data;
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Update your brew settings",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 20.0),
                  _buildUsernameInput(userData),
                  SizedBox(height: 20.0),
                  _buildSugarsDropdownInput(userData),
                  SizedBox(height: 20.0),
                  _buildStrengthSlider(userData),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        await DatabaseService(uid: user.uid).updateUserData(
                            _currentSugars ?? userData.sugars,
                            _currentName ?? userData.username,
                            _currentStrength ?? userData.strength);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return Loading();
          }
        });
  }

  Slider _buildStrengthSlider(UserData userData) {
    return Slider(
      value: (_currentStrength ?? userData.strength).toDouble(),
      min: 100,
      max: 900,
      divisions: 8,
      activeColor: Colors.brown[_currentStrength ?? 100],
      inactiveColor: Colors.brown[_currentStrength ?? 100],
      onChanged: (val) => setState(() => _currentStrength = val.round()),
    );
  }

  DropdownButtonFormField<String> _buildSugarsDropdownInput(UserData userData) {
    return DropdownButtonFormField(
      decoration: textInputDecoration,
      value: _currentSugars ?? userData.sugars,
      onChanged: (value) => setState(() => _currentSugars = value),
      items: sugars.map((sugar) {
        return DropdownMenuItem(
          child: Text("$sugar sugars"),
          value: sugar,
        );
      }).toList(),
    );
  }

  TextFormField _buildUsernameInput(UserData userData) {
    return TextFormField(
      initialValue: userData.username,
      decoration: textInputDecoration,
      validator: (val) => val.isEmpty ? 'Please enter a username' : null,
      onChanged: (val) => setState(() => _currentName = val),
    );
  }
}
