
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:numpakbis/models/halte_bus.dart';
import 'package:numpakbis/screens/home_member/component/bus_stops_tile.dart';
import 'package:numpakbis/shared/global_function.dart';
import 'package:provider/provider.dart';

class BusStopList extends StatefulWidget {
  @override
  _BusStopListState createState() => _BusStopListState();
}

class _BusStopListState extends State<BusStopList> {
  Position _currentPosition;
  TextEditingController editingController = TextEditingController();
  String filter;
  bool filtered = false;


  _getCurrentLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState((){
        _currentPosition = position;
        print(position);
      });
    }).catchError((e) {
      print(e);
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editingController.addListener(() {
      setState(() {
        if(editingController.text == '' || editingController.text == null){
          filtered = false;
        }else{
          filtered = true;
        }
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
    final halte_buses = Provider.of<List<HalteBus>>(context) ?? [];
    if(_currentPosition == null){
      _getCurrentLocation();
    }
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
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
              itemCount: halte_buses.length,
              itemBuilder: (context,index) {
                var tempDistance = CalculationByDistance(
                    _currentPosition == null ? 0 : _currentPosition.latitude,
                    _currentPosition == null ? 0 : _currentPosition.longitude,
                    double.parse(halte_buses[index].latitude),
                    double.parse(halte_buses[index].longitude));
                  return double.parse(tempDistance) <= 3.0 || double.parse(tempDistance) == 0.0 ? BusStopTile(halteBus: halte_buses[index], distance: tempDistance) : Container();
              },
            )
            :  ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: halte_buses.length,
              itemBuilder: (context,index) {
                var tempDistance = CalculationByDistance(
                    _currentPosition == null ? 0 : _currentPosition.latitude,
                    _currentPosition == null ? 0 : _currentPosition.longitude,
                    double.parse(halte_buses[index].latitude),
                    double.parse(halte_buses[index].longitude));
                  return halte_buses[index].name.toLowerCase().contains(filter.toLowerCase()) ? BusStopTile(halteBus: halte_buses[index], distance: tempDistance) : Container();

              },
            ),
          ),
        ],
      ),
    );
  }
}


