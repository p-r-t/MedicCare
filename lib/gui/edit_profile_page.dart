import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mediccare/core/user.dart';
import 'package:mediccare/util/datetime_picker_formfield.dart';
import 'package:mediccare/util/firebase_utils.dart';

class EditProfilePage extends StatefulWidget {
  final User _user;

  EditProfilePage(this._user);

  @override
  State<StatefulWidget> createState() {
    return _EditProfilePageState();
  }
}

class _EditProfilePageState extends State<EditProfilePage> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerHeight = TextEditingController();
  final TextEditingController _controllerWeight = TextEditingController();
  DateTime _currentBirthDate;
  File _image;

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String userId = await FirebaseUtils.getUserId();

    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('$userId/profile');

    try {
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      String imageUrl = await firebaseStorageRef.getDownloadURL();

      setState(() {
        _image = image;
        widget._user.image = imageUrl;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _controllerFirstName.text = widget._user.firstName;
    _controllerLastName.text = widget._user.lastName;
    _controllerHeight.text = widget._user.height.toString();
    _controllerWeight.text = widget._user.weight.toString();
    _currentBirthDate = widget._user.birthDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.blueGrey),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0.1,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            padding: EdgeInsets.only(
              left: 30.0,
              top: 15.0,
              right: 30.0,
              bottom: 15.0,
            ),
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Color(0xffffffff),
                            child: ClipOval(
                              child: SizedBox(
                                width: 150.0,
                                height: 150.0,
                                child: (widget._user.image != null)
                                    ? Image.network(widget._user.image, fit: BoxFit.fill)
                                    : Image.asset(
                                        "assets/person.png",
                                        fit: BoxFit.fill,
                                      ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
              FloatingActionButton(
                onPressed: getImage,
                tooltip: 'Change Image',
                child: Icon(Icons.add_a_photo),
              ),
              TextFormField(
                controller: _controllerFirstName,
                decoration:
                    InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person)),
                keyboardType: TextInputType.text,
                validator: (String text) {
                  if (text.isEmpty) {
                    return 'Please fill first name';
                  }
                },
              ),
              TextFormField(
                controller: _controllerLastName,
                decoration: InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.person)),
                keyboardType: TextInputType.text,
                validator: (String text) {
                  if (text.isEmpty) {
                    return 'Please fill last name';
                  }
                },
              ),
              SizedBox(height: 10.0),
              DropdownButton(
                isExpanded: true,
                hint: Text('Gender'),
                value: widget._user.gender,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('Female'),
                  ),
                  DropdownMenuItem(
                    value: 'others',
                    child: Text('Others'),
                  ),
                ],
                onChanged: (String value) {
                  setState(() {
                    widget._user.gender = value;
                  });
                },
              ),
              DateTimePickerFormField(
                format: DateFormat('yyyy-MM-dd'),
                initialValue: widget._user.birthDate,
                inputType: InputType.date,
                editable: true,
                decoration: InputDecoration(
                  labelText: 'Birthdate',
                  prefixIcon: Icon(Icons.cake),
                ),
                onChanged: (DateTime date) {
                  try {
                    _currentBirthDate = date;
                  } catch (e) {}
                },
                validator: (DateTime date) {
                  if (date == null) {
                    return 'Please fill birthdate';
                  } else if (date.compareTo(DateTime.now()) > 0) {
                    return 'Invalid birthdate';
                  }
                },
              ),
              TextFormField(
                controller: _controllerHeight,
                decoration: InputDecoration(
                  hintText: 'Height',
                  labelText: 'Height',
                  prefixIcon: Icon(Icons.assessment),
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                validator: (String text) {
                  if (text.isEmpty) {
                    return 'Please fill height';
                  }
                  try {
                    if (double.parse(text) <= 0) {
                      return 'Invalid height';
                    }
                  } catch (e) {
                    return 'Height must be a valid number';
                  }
                },
              ),
              TextFormField(
                controller: _controllerWeight,
                decoration: InputDecoration(
                  hintText: 'Weight',
                  labelText: 'Weight',
                  prefixIcon: Icon(Icons.assessment),
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
                validator: (String text) {
                  if (text.isEmpty) {
                    return 'Please fill weight';
                  }
                  try {
                    if (double.parse(text) <= 0) {
                      return 'Invalid weight';
                    }
                  } catch (e) {
                    return 'Weight must be a valid number';
                  }
                },
              ),
              SizedBox(height: 20.0),
              DropdownButton(
                isExpanded: true,
                hint: Text('Blood Group'),
                value: widget._user.bloodGroup,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    value: 'O+',
                    child: Text('O+'),
                  ),
                  DropdownMenuItem(
                    value: 'O-',
                    child: Text('O-'),
                  ),
                  DropdownMenuItem(
                    value: 'A+',
                    child: Text('A+'),
                  ),
                  DropdownMenuItem(
                    value: 'A-',
                    child: Text('A-'),
                  ),
                  DropdownMenuItem(
                    value: 'B+',
                    child: Text('B+'),
                  ),
                  DropdownMenuItem(
                    value: 'B-',
                    child: Text('B-'),
                  ),
                  DropdownMenuItem(
                    value: 'AB+',
                    child: Text('AB+'),
                  ),
                  DropdownMenuItem(
                    value: 'AB-',
                    child: Text('AB-'),
                  ),
                ],
                onChanged: (String value) {
                  setState(() {
                    widget._user.bloodGroup = value;
                  });
                },
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                color: Theme.of(context).primaryColor,
                child: Text('Save', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    widget._user.firstName = _controllerFirstName.text;
                    widget._user.lastName = _controllerLastName.text;
                    widget._user.height = double.parse(_controllerHeight.text);
                    widget._user.weight = double.parse(_controllerWeight.text);
                    widget._user.birthDate = _currentBirthDate;

                    FirebaseUtils.updateUserData(widget._user);

                    Navigator.of(context).pop(true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
