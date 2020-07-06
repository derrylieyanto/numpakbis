import 'package:flutter/material.dart';
import 'package:numpakbis/services/auth.dart';
import 'package:numpakbis/shared/constant.dart';
import 'package:numpakbis/shared/loading_logo.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String name = '';
  String noHP = '';
  String error = '';

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _namaFocus = FocusNode();
  final FocusNode _noHPFocus = FocusNode();

  @override
  Widget build(BuildContext context) {

    _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }

    return loading ? LoadingLogo() : Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('SIGN UP', style: TextStyle(color: Colors.lightBlue),),
        iconTheme: IconThemeData(
          color: Colors.lightBlue,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  /*SizedBox(height: 20),
                  Icon(Icons.directions_bus,color: Colors.lightBlue, size: 120,),*/
                  SizedBox(height: 20,),
                  TextFormField( // email form
                    decoration: textInputDecoration.copyWith(hintText: 'Email'),
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocus,
                    onFieldSubmitted: (term){
                      _fieldFocusChange(context, _emailFocus, _passwordFocus);
                    },
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField( // pass form
                    decoration: textInputDecoration.copyWith(hintText: 'Password'),
                    textInputAction: TextInputAction.next,
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (term){
                      _fieldFocusChange(context, _passwordFocus, _namaFocus);
                    },
                    validator: (val) => val.length < 6 ? 'Enter a password (min 6 char)' : null,
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 20,),
                  TextFormField( // name form
                    decoration: textInputDecoration.copyWith(hintText: 'Name'),
                    textInputAction: TextInputAction.next,
                    focusNode: _namaFocus,
                    onFieldSubmitted: (term){
                      _fieldFocusChange(context, _namaFocus, _noHPFocus);
                    },
                    validator: (val) => val.isEmpty ? 'Enter a name' : null,
                    onChanged: (val) {
                      setState(() {
                        name = val;
                      });
                    },
                  ),
                  SizedBox(height: 20,),
                  TextFormField( // No HP form
                    decoration: textInputDecoration.copyWith(hintText: 'No. HP'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    focusNode: _noHPFocus,
                    onFieldSubmitted: (term) async{
                      _noHPFocus.unfocus();
                      if (_formKey.currentState.validate()){
                        setState(() => loading = true);
                        dynamic result = await _auth.registerEmailPass(email, password, name, noHP);
                        if (result == null){
                          setState(() {
                            error = 'email or password not valid';
                            loading = false;
                          });
                        }else{
                          await Navigator.pop(context);
                        }
                      }
                    },
                    validator: (val) => val.isEmpty ? 'Enter a valid phone number' : null,
                    onChanged: (val) {
                      setState(() {
                        noHP = val;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(28),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()){
                          setState(() => loading = true);
                          dynamic result = await _auth.registerEmailPass(email, password, name, noHP);
                          if (result == null){
                            setState(() {
                              error = 'email or password not valid';
                              loading = false;
                            });
                          }else{
                            await Navigator.pop(context);
                          }
                        }
                      },
                      color: Colors.lightBlue,
                      child: Text(
                        'SIGN-UP',
                        style: TextStyle(color: Colors.white,fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    error,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20,),

                ],
              ),
            ),
          ],
        ),

      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already member?',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          FlatButton(
            onPressed: () async {
              await Navigator.pop(context);
            },
            child: Text(
              'Log in now',
              style: TextStyle(
                color: Colors.lightBlue,
                decoration: TextDecoration.underline,
              ),

            ),
          ),
        ],
      ),
    );
  }
}
