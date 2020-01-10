import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/account_bloc.dart';
import 'package:kilat/app/models/Account.dart';
import 'package:kilat/app/views/custom_materials/custom_form.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/colors.dart' as colors;

class SignUp extends StatefulWidget {
  final AccountBloc _bloc;
  SignUp(this._bloc);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _signUpKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();

  Account _account;
  bool _canNext = true;

  @override
  void initState() {
    widget._bloc.init();
    super.initState();
  }

  @override
  void dispose() {
    widget._bloc.dispose();
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 8, 0),
                    child: IconButton(
                      icon: Icon(Icons.close, color: colors.primary[50]),
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
                      "SIGN UP",
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
                  key: _signUpKey,
                  child: Column(
                    children: <Widget>[
                      CustomTextFormField(
                          controller: _emailController,
                          hintText: "Enter email",
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail),
                      SizedBox(height: 10),
                      CustomTextFormField(
                          controller: _passwordController,
                          hintText: "Enter password",
                          obscureText: true,
                          validator: _validatePassword),
                      SizedBox(height: 10),
                      CustomTextFormField(
                          controller: _repeatController,
                          hintText: "Repeat password",
                          obscureText: true,
                          validator: _validateRepeatPassword),
                      SizedBox(height: 30),
                      RaisedButton(
                        color: colors.primary[700],
                        child: Container(
                          width: 100,
                          alignment: Alignment.center,
                          child: Text("NEXT",
                              style: TextStyle(color: colors.primary[50])),
                        ),
                        onPressed: (_canNext) ? _next : null,
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

  String _validateEmail(String value) {
    if (value.isEmpty)
      return "Field cannot be empty";
    else if (!value.contains('@')) return "Incorrect email format";
    return null;
  }

  String _validatePassword(String value) {
    if (value.isEmpty)
      return "Field cannot be empty";
    else if (value.length < 4) return "Password too short (min: 4)";
    return null;
  }

  String _validateRepeatPassword(String value) {
    if (value.isEmpty)
      return "Field cannot be empty";
    else if (_repeatController.text != _passwordController.text)
      return "Password does not match";
    return null;
  }

  void _next() {
    FocusScope.of(context).requestFocus(FocusNode());

    if (_signUpKey.currentState.validate()) {
      // disable next button and clear error message
      setState(() {
        _canNext = false;
      });

      // create temp account
      _account = Account();
      _account.email = _emailController.text.toLowerCase();
      _account.password = _passwordController.text;

      // request http, can signup?
      widget._bloc.canSignup(_account).whenComplete(() {
        if (mounted) setState(() => _canNext = true);
      }).then((value) {
        // if can signup, go to next page
        if (value) {
          _gotoSignupProfilePage();
        }
      }).catchError((e) {
        dialogs.errorDialog(context, e);
      }).timeout(Duration(seconds: 10), onTimeout: () {
        setState(() => _canNext = true);
        dialogs.alertDialog(context, "Connection timeout", title: "Timeout");
      });
    }
  }

  _gotoSignupProfilePage() {
    Navigator.pushNamed(context, 'signup_profile', arguments: _account);
  }
}
