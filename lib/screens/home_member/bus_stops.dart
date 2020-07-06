import 'package:flutter/material.dart';
import 'package:numpakbis/models/halte_bus.dart';
import 'package:numpakbis/screens/home_member/component/bus_stops_list.dart';
import 'package:numpakbis/services/database.dart';
import 'package:provider/provider.dart';

class BusStop extends StatefulWidget {
  @override
  _BusStopState createState() => _BusStopState();
}

class _BusStopState extends State<BusStop> {

  @override
  Widget build(BuildContext context) {

    return StreamProvider<List<HalteBus>>.value(
      value: DatabaseService().haltebuses,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: BusStopList(),
      ),
    );
  }
}
