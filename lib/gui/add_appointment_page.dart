import 'dart:math';

///
/// `add_appointment_page.dart`
/// Class for appointment addition page GUI
///

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediccare/core/appointment.dart';
import 'package:mediccare/core/doctor.dart';
import 'package:mediccare/core/user.dart';
import 'package:mediccare/util/alert.dart';
import 'package:mediccare/util/datetime_picker_formfield.dart';
import 'package:mediccare/util/firebase_utils.dart';

class AddAppointmentPage extends StatefulWidget {
  AddAppointmentPage();

  @override
  State<StatefulWidget> createState() {
    return _AddAppointmentPageState();
  }
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final TextEditingController _controllerTitle = TextEditingController();
  static final TextEditingController _controllerDescription =
      TextEditingController();
  static final TextEditingController _controllerHospital =
      TextEditingController();
  Doctor _currentDoctor;
  DateTime _currentDateTime;

  void clearFields() {
    _controllerTitle.text = '';
    _controllerDescription.text = '';
    _controllerHospital.text = '';
    this._currentDoctor = null;
    this._currentDateTime = null;
  }

  @override
  void initState() {
    super.initState();
    this.clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          title: Text(
            'Add Appointment',
            style: TextStyle(color: Colors.blueGrey),
          ),
          backgroundColor: Colors.white.withOpacity(0.9),
          elevation: 0.1,
          actions: <Widget>[]),
      body: Form(
        key: this._formKey,
        child: Center(
          child: ListView(
            padding: EdgeInsets.only(
                left: 30.0, top: 15.0, right: 30.0, bottom: 15.0),
            children: <Widget>[
              TextFormField(
                controller: _controllerTitle,
                decoration: InputDecoration(labelText: 'Appointment Title'),
                validator: (String text) {
                  if (text.isEmpty) {
                    return 'Please fill appointment title';
                  }
                },
              ),
              TextFormField(
                controller: _controllerDescription,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButton(
                isExpanded: true,
                value: this._currentDoctor,
                items:
                    // widget._user.doctorList
                    //         .map(
                    //           (e) => DropdownMenuItem(
                    //                 value: e,
                    //                 child: Row(
                    //                   children: <Widget>[
                    //                     Icon(
                    //                       Icons.person,
                    //                       color: Theme.of(context).primaryColor,
                    //                     ),
                    //                     Text(' ' + e.prefix + ' ' + e.firstName + ' ' + e.lastName),
                    //                   ],
                    //                 ),
                    //               ),
                    //         )
                    //         .toList() +
                    [
                  DropdownMenuItem(
                    value: null,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.person_outline,
                          color: Colors.grey,
                        ),
                        Text(' Unspecified'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    this._currentDoctor = value;
                  });
                },
              ),
              TextFormField(
                controller: _controllerHospital,
                decoration: InputDecoration(
                  labelText: 'Hospital',
                ),
                validator: (text) {
                  if (this._currentDoctor == null && text.trim().isEmpty) {
                    return 'Please fill hospital';
                  }
                },
              ),
              DateTimePickerFormField(
                initialValue: DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day + 1, 10),
                initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day + 1, 10),
                format: DateFormat('yyyy-MM-dd HH:mm'),
                inputType: InputType.both,
                editable: true,
                decoration: InputDecoration(
                  labelText: 'Date and Time',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onChanged: (DateTime dateTime) {
                  try {
                    this._currentDateTime = dateTime;
                  } catch (e) {}
                },
                validator: (DateTime dateTime) {
                  if (this._currentDateTime == null) {
                    return 'Please select a valid date and time';
                  }
                },
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                color: Theme.of(context).primaryColor,
                child: Text('Save'),
                onPressed: () {
                  if (this._formKey.currentState.validate()) {
                    Appointment appointment = Appointment(
                      title: _controllerTitle.text,
                      description: _controllerDescription.text,
                      doctor: this._currentDoctor,
                      hospital: (_controllerHospital.text.trim().isNotEmpty)
                          ? _controllerHospital.text
                          : this._currentDoctor.hospital,
                      dateTime: this._currentDateTime,
                    );

                    FirebaseUtils.addAppointment(appointment);

                    Navigator.pop(context);
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
