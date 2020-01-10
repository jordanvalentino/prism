import 'package:flutter/material.dart';
import 'package:kilat/app/blocs/account_bloc.dart';
import 'package:kilat/app/models/Account.dart';
import 'package:kilat/app/views/custom_materials/custom_form.dart';
import 'package:kilat/app/views/custom_materials/template_dialog.dart'
    as dialogs;
import 'package:kilat/colors.dart' as colors;
import 'package:kilat/globals.dart' as globals;

class SignIn extends StatefulWidget {
  final AccountBloc _bloc;
  SignIn(this._bloc);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _signInKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Account _account;
  bool _canNext = true;

  @override
  void initState() {
    _emailController.clear();
    _passwordController.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.primary[500],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("SIGN IN",
                        style: TextStyle(
                            fontFamily: 'FredokaOne',
                            fontSize:
                                Theme.of(context).textTheme.display2.fontSize,
                            color: colors.primary[50])),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(56, 60, 56, 30),
                child: Form(
                  key: _signInKey,
                  child: Column(
                    children: <Widget>[
                      CustomTextFormField(
                          controller: _emailController,
                          hintText: "Enter your email",
                          validator: _onValidateEmptyField,
                          keyboardType: TextInputType.emailAddress),
                      SizedBox(height: 10),
                      CustomTextFormField(
                          controller: _passwordController,
                          hintText: "Enter your password",
                          obscureText: true,
                          validator: _onValidateEmptyField),
                      SizedBox(height: 30),
                      RaisedButton(
                        color: colors.primary[700],
                        child: Container(
                          width: 100,
                          alignment: Alignment.center,
                          child: Text("SIGN IN",
                              style: TextStyle(color: colors.primary[50])),
                        ),
                        onPressed: (_canNext) ? _signIn : null,
                      ),
                      Visibility(
                          visible: !_canNext,
                          child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
              Text("or",
                  style: TextStyle(
                      color: colors.primary[700], fontWeight: FontWeight.w600)),
              SizedBox(height: 20),
              InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Create an account",
                        style: TextStyle(
                            color: colors.primary[700],
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600)),
                  ),
                  onTap: () {
                    // clear inputs
                    _emailController.clear();
                    _passwordController.clear();
                    _gotoSignup();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  String _onValidateEmptyField(String value) {
    if (value.isEmpty) return "Field cannot be empty";
    return null;
  }

  void _gotoSignup() => Navigator.pushNamed(context, 'signup');
  void _gotoHome() => Navigator.pushReplacementNamed(context, 'master_home');

  void _signIn() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_signInKey.currentState.validate()) {
      setState(() => _canNext = false);

      _account = Account();
      _account.email = _emailController.text;
      _account.password = _passwordController.text;

      widget._bloc.signin(_account).whenComplete(() {
        if (mounted) setState(() => _canNext = true);
      }).then((value) {
        if (value) _fetchSettings().then((_) => _gotoHome());
      }).catchError((e) {
        dialogs.errorDialog(context, e);
      }).timeout(Duration(seconds: 10), onTimeout: () {
        setState(() => _canNext = true);
        dialogs.alertDialog(context, "Connection timeout.", title: "Timeout");
      });
    }
  }

  Future _fetchSettings() async {
    await widget._bloc.fetchEventSetting(
        globals.account.evsetSysId, globals.account.evsetUserId);
    await widget._bloc.fetchTaskSetting(
        globals.account.tasetSysId, globals.account.tasetUserId);

    globals.account.save();
  }
}
