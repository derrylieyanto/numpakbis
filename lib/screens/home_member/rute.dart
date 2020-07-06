import 'package:flutter/material.dart';
import 'package:numpakbis/models/rute_bus.dart';
import 'package:numpakbis/services/database.dart';
import 'package:provider/provider.dart';

import 'component/rute_list.dart';

class Rute extends StatefulWidget {
  @override
  _RuteState createState() => _RuteState();
}

class _RuteState extends State<Rute> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<RuteBus>>.value(
      value: DatabaseService().rutebuses,
      child: Scaffold(
        body:RuteList(),
      ),
    );
  }
}
