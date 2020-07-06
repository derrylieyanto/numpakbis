import 'package:flutter/material.dart';
import 'package:numpakbis/models/rute_bus.dart';
import 'package:numpakbis/screens/home_member/component/rute_tile.dart';
import 'package:provider/provider.dart';

class RuteList extends StatefulWidget {
  @override
  _RuteListState createState() => _RuteListState();
}

class _RuteListState extends State<RuteList> {
  TextEditingController editingController = TextEditingController();
  String filter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editingController.addListener(() {
      setState(() {
        filter = editingController.text;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rute_buses = Provider.of<List<RuteBus>>(context) ?? [];
    return Column(
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: TextField(
                controller: editingController,
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: filter == null || filter == "" || editingController.text.isEmpty ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: rute_buses.length,
            itemBuilder: (context,index) {
              return RuteTile(ruteBus: rute_buses[index]);
            },
          ) : ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: rute_buses.length,
            itemBuilder: (context,index) {
              return rute_buses[index].name.toLowerCase().contains(filter.toLowerCase()) ? RuteTile(ruteBus: rute_buses[index]) : new Container();
            },
          ),
        ),
      ],
    );
  }
}
