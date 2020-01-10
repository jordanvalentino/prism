import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kilat/app/blocs/account_bloc.dart';
import 'package:kilat/app/models/Account.dart';
import 'package:kilat/app/views/custom_materials/custom_form.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;

class SignUpProfile extends StatefulWidget {
  final AccountBloc _bloc;
  final Account _account;
  SignUpProfile(this._bloc, this._account);

  @override
  _SignUpProfileState createState() => _SignUpProfileState(this._account);
}

class _SignUpProfileState extends State<SignUpProfile> {
  final _registrationKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();

  Account _account;
  String _gender = 'female';
  bool _canNext = true;

  _SignUpProfileState(this._account);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.primary[500],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 0, 0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: colors.primary[50]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 44),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "REGISTRATION",
                      style: TextStyle(
                          fontFamily: 'FredokaOne',
                          fontSize:
                              Theme.of(context).textTheme.display2.fontSize,
                          color: colors.primary[50]),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(56, 60, 56, 30),
                child: Form(
                  key: _registrationKey,
                  child: Column(
                    children: <Widget>[
                      CustomTextFormField(
                          controller: _nameController,
                          hintText: "Enter your name",
                          validator: _validateName),
                      SizedBox(height: 10),
                      CustomTextFormField(
                        hintText: "Enter your birthday",
                        readOnly: true,
                        validator: _validateDate,
                        onTap: () => _buildDateTimePicker(context),
                        controller: _birthdayController,
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField(
                        hint: Text("Select your gender"),
                        value: _gender,
                        items: [
                          CustomDropdownMenuItem(
                              text: "Female", value: "female"),
                          CustomDropdownMenuItem(text: "Male", value: "male"),
                        ],
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          enabledBorder: CustomUnderlineBorder(
                              borderColor: colors.primary[50], borderWidth: 1),
                          focusedBorder: CustomUnderlineBorder(
                              borderColor: colors.primary[50], borderWidth: 2),
                          errorBorder: CustomUnderlineBorder(
                              borderColor: Colors.red, borderWidth: 1),
                          focusedErrorBorder: CustomUnderlineBorder(
                              borderColor: Colors.red, borderWidth: 2),
                        ),
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                      SizedBox(height: 30),
                      RaisedButton(
                        color: colors.primary[700],
                        child: Container(
                          width: 100,
                          alignment: Alignment.center,
                          child: Text("SIGN UP",
                              style: TextStyle(color: colors.primary[50])),
                        ),
                        onPressed: _register,
                      ),
                      Visibility(
                          visible: !_canNext,
                          child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _validateName(String value) {
    if (value.isEmpty) return "Field cannot be empty";
    return null;
  }

  String _validateDate(dynamic value) {
    if (value.toString().isEmpty) return "Field cannot be empty";
    return null;
  }

  _buildDateTimePicker(BuildContext context) async {
    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 5 + 2)),
      firstDate: DateTime(DateTime.now().year - 200),
      lastDate: DateTime.now().subtract(Duration(days: 365 * 5 + 2)),
    );

    if (selectedDate != null) {
      setState(() {
        _birthdayController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  void _register() {
    FocusScope.of(context).requestFocus(FocusNode());

    if (_registrationKey.currentState.validate()) {
      setState(() => _canNext = false);

      _account.name = _nameController.text;
      _account.birthday = DateTime.parse(_birthdayController.text);
      _account.gender = _gender;

      widget._bloc.signup(_account).whenComplete(() {
        if (mounted) setState(() => _canNext = true);
      }).then((value) async {
        if (value) {
          await fetchSettings();
          globals.account.save();

          dialogs.alertDialog(
              context, "Congratulation!\nYou are an official member now.",
              title: "Registered",
              onConfirm: () => Navigator.pushNamedAndRemoveUntil(
                  context, 'signup_busy', (Route<dynamic> route) => false));
        }
      }).catchError((e) {
        dialogs.errorDialog(context, e);
      }).timeout(Duration(seconds: 10), onTimeout: () {
        setState(() => _canNext = true);
        dialogs.alertDialog(context, "Connection timeout.", title: "Timeout");
      });
    }
  }

  Future fetchSettings() async {
    await widget._bloc.fetchEventSetting(
        globals.account.evsetSysId, globals.account.evsetUserId);
    await widget._bloc.fetchTaskSetting(
        globals.account.tasetSysId, globals.account.tasetUserId);
    return Future;
  }
}
