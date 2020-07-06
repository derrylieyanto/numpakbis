
import 'package:flutter/material.dart';
import 'package:numpakbis/models/bus_list.dart';
import 'package:numpakbis/screens/wrapper.dart';
import 'package:numpakbis/services/auth.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: ChangeNotifierProvider(
        create: (context) => BusLocInfo(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Wrapper(),
        ),
      ),
    );
  }
}
