import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:numpakbis/models/bus.dart';
import 'package:numpakbis/models/bus_list.dart';
import 'package:numpakbis/models/halte_bus.dart';
import 'package:numpakbis/models/rute_bus.dart';
import 'package:numpakbis/screens/home_member/component/rute_bus_detail.dart';
import 'package:numpakbis/shared/curve_painter.dart';
import 'package:numpakbis/shared/global_function.dart';
import 'package:numpakbis/shared/loading.dart';
import 'package:provider/provider.dart';




class RuteDetail extends StatefulWidget {
  final RuteBus ruteBus;
  RuteDetail({ this.ruteBus });

  @override
  _RuteDetailState createState() => _RuteDetailState();
}

class _RuteDetailState extends State<RuteDetail> {

  List<RuteHalteBus> ruteHalteBusList = [] ;
  bool loading = true;
  List<Bus> _buses = [];
  final _API = "AIzaSyB5DAWFw7QfviInDgsmiNSblskzqkUVSGk";


  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  LatLng _lastMapPosition = _center;
  static const LatLng _center = const LatLng(-7.797068, 110.370529);
  Position _currentPosition;
  Circle _circle;
  BitmapDescriptor iconMe;
  BitmapDescriptor iconHalte;
  String _infoBus;
  final Set<Marker> _markers = {};
  List<LatLng> points = [];

  // for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

    _polylines = Set<Polyline>();

    if(ruteHalteBusList != null){
      for(var i = 0; i<ruteHalteBusList.length; i++){
        LatLng latLng = LatLng(double.parse(ruteHalteBusList[i].latitude),double.parse(ruteHalteBusList[i].longitude));
        points.add(latLng);
        setState(() {
          addMarker(latLng, 'halte${ruteHalteBusList[i].key}', ruteHalteBusList[i].name, iconHalte, ruteHalteBusList[i]);
        });
        LatLng sw = southwestFromLatLngList(points);
        LatLng ne = northeastFromLatLngList(points);
        LatLng mid = MidPoint(sw.latitude, sw.longitude, ne.latitude, ne.longitude);
        print('mid : ${mid.latitude} - ${mid.longitude}');
        print('mid : ${mid.latitude} - ${mid.longitude}');
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: mid,
            zoom: 12.00)));
        setPolylines(ruteHalteBusList[i].latitude, ruteHalteBusList[i].longitude, ruteHalteBusList[i+1].latitude, ruteHalteBusList[i+1].longitude, '$i');
      }


    }





  }

  void addMarker(LatLng mLatLng, String mTitle, String mDescription, BitmapDescriptor mIcon, RuteHalteBus ruteHalteBus){
    _markers.add(Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId(mTitle),
      position: mLatLng,
      infoWindow: InfoWindow(
        title: mDescription,
        onTap: (){
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RuteBusStopDetail(halteBus: HalteBus.fromRute(ruteHalteBus, getRute(widget.ruteBus.name)))));
        },
      ),
      icon: mIcon,
    ));
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void setPolylines(String lat1, String lon1, String lat2, String lon2, String id) async {
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        _API,
        double.parse(lat1),double.parse(lon1),
        double.parse(lat2),double.parse(lon2));
    if(result.isNotEmpty){
      polylineCoordinates = [];
      result.forEach((PointLatLng point){
        polylineCoordinates.add(
            LatLng(point.latitude,point.longitude)
        );
      });
      setState(() {
        _polylines.add(Polyline(
            width: 5, // set the width of the polylines
            polylineId: PolylineId('poly_$id'),
            color: getColor(getRute(widget.ruteBus.name)),
            points: polylineCoordinates
        ));
      });
    }
  }


  void updateMarkerOnMap(String id,String bus,String lat, String long){
    setState(() {      // updated position
      var pinPosition = LatLng(double.parse(lat),double.parse(long));
      // the trick is to remove the marker (by id)
      // and add it again at the updated location

      _markers.removeWhere(
              (m) => m.markerId.value == '$id');
      _markers.add(Marker(
          markerId: MarkerId('$id'),
          infoWindow: InfoWindow(
            title: '$bus',
          ),
          position: pinPosition, // updated position
          icon: BitmapDescriptor.defaultMarker
      ));
    });
  }

  _getCurrentLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState((){
        _currentPosition = position;
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.00)));
        createCurrentMarker(position);
        print(position);
      });
    }).catchError((e) {
      print(e);
    });
  }

  /// This method sets selectedLocation to current location.
  void setCurrentLocation() async{
    if (mapController != null) {
      setState(() {
        createCurrentMarker(_currentPosition);
      });
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition.latitude - 0.0001,
              _currentPosition.longitude,
            ),
            zoom: 16,
          ),
        ),
      );
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition.latitude,
              _currentPosition.longitude,
            ),
            zoom: 16,
          ),
        ),
      );

    }
  }


  void createCurrentMarker(Position pos){
    this.setState(() {
      _markers.add(Marker(
        markerId: MarkerId('Me'),
        icon: iconMe,
        infoWindow: InfoWindow(title: 'Me',),
        position: LatLng(pos.latitude, pos.longitude ),
      ));
      _circle = Circle(
        circleId: CircleId("Me"),
        radius: pos.accuracy,
        zIndex: 1,
        strokeColor: Colors.blue,
        strokeWidth: 0,
        center: LatLng(pos.latitude, pos.longitude ),
        fillColor: Colors.blue.withAlpha(60),
      );
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    MasterList();

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
        'assets/halteMark1.png')
        .then((d) {
      iconHalte = d;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2),
        'assets/meMark.png')
        .then((d) {
      iconMe = d;
    });

    polylinePoints = PolylinePoints();

    super.initState();


  }




  @override
  Widget build(BuildContext context) {
    var busDataInfo = Provider.of<BusLocInfo>(context);
    if(busDataInfo.buses.isNotEmpty){
      for(var i=0;i<busDataInfo.buses.length;i++){
        if(busDataInfo.buses[i].rute.toLowerCase() == widget.ruteBus.name.toLowerCase()) {
          if(_buses == null || _buses.isEmpty){
            _buses.add(busDataInfo.buses[i]);
            updateMarkerOnMap(busDataInfo.buses[i].name, busDataInfo.buses[i].name, busDataInfo.buses[i].latitude, busDataInfo.buses[i].longitude);
            _infoBus = '${_buses.length} Transjogja available';
          }else{
            bool isSameBus = false;
            for(var j = 0 ; j<_buses.length; j++){
              if(_buses[j].name == busDataInfo.buses[i].name){
                _buses[j] = busDataInfo.buses[i];
                isSameBus = true;
                updateMarkerOnMap(busDataInfo.buses[i].name, busDataInfo.buses[i].name, busDataInfo.buses[i].latitude, busDataInfo.buses[i].longitude);
                _infoBus = '${_buses.length} Transjogja available';
              }
            }
            if(isSameBus == false){
              _buses.add(busDataInfo.buses[i]);
              updateMarkerOnMap(busDataInfo.buses[i].name, busDataInfo.buses[i].name, busDataInfo.buses[i].latitude, busDataInfo.buses[i].longitude);
              _infoBus = '${_buses.length} Transjogja available';
            }
          }
        }
      }
    }




    ListTile makeListTile(RuteHalteBus ruteHalteBus) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
     /* leading: Container(
        padding: EdgeInsets.only(right: 12.0),
        decoration: new BoxDecoration(
            border: new Border(
                right: new BorderSide(width: 2.0, color: getColor(getRute(widget.ruteBus.name))))),
        child: Icon(Icons.directions_bus, color: getColor(getRute(widget.ruteBus.name))),
      ),*/
      title: Text(
        ruteHalteBus.name,
        style: TextStyle(color: Colors.black54, ),
      ),
      trailing:
      Icon(Icons.keyboard_arrow_right, color: Colors.black26, size: 30.0),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RuteBusStopDetail(halteBus: HalteBus.fromRute(ruteHalteBus, getRute(widget.ruteBus.name)))));
      },

    );

    Card makeCard(RuteHalteBus ruteHalteBus) => Card(
      elevation: 0.0,
      margin: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
        ),
        child: makeListTile(ruteHalteBus),
      ),
    );



      return loading ? Loading() : Scaffold(
        body: Stack(
            children: <Widget>[

              GoogleMap(
                mapType: MapType.normal,
                markers:Set.of((_markers != null) ? _markers : []),
                circles: Set.of((_circle != null) ? [_circle] : []),
                polylines: Set.of((_polylines != null) ? _polylines : []),
                initialCameraPosition: CameraPosition(
                  target: _center ,
                  zoom: 12,
                ),
                onMapCreated: _onMapCreated,
                onCameraMove: _onCameraMove,
              ),

              Positioned(
                left: 8.0,
                top: 35.0,
                child: Container(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.lightBlue, size: 35,),
                  ),
                ),
              ),

              DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.13,
                maxChildSize: 0.8,
                builder: (BuildContext context, myscrollController){
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FloatingActionButton(
                                child: Icon(Icons.location_searching),
                                onPressed: (){
                                  _getCurrentLocation();
                                }),
                            SizedBox(width: 10,),
                          ],
                        ),
                        SizedBox(height: 10,),

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                              color: Colors.white,
                              boxShadow: [BoxShadow(
                                color: Colors.black,
                                offset: new Offset(0.0, 10.0),
                                blurRadius: 15.0,
                              )],
                            ),
                            child: SingleChildScrollView(
                              controller: myscrollController,
                              physics: ScrollPhysics(),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      child: SizedBox(height: 5,width: 50),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        color: Colors.black26,
                                      ),
                                    ),
                                  ),

                                  Card(
                                    elevation: 1,
                                    //margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                      leading: Container(
                                        padding: EdgeInsets.only(right: 12.0, left: 5),
                                        decoration: new BoxDecoration(
                                            border: new Border(
                                                right: new BorderSide(width: 3.0, color: getColor(getRute(widget.ruteBus.name))))),
                                        child: FaIcon(FontAwesomeIcons.route ,color: getColor(getRute(widget.ruteBus.name)), size: 40,),
                                      ),
                                      title: Text(
                                        widget.ruteBus.name,
                                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 24),
                                      ),
                                      subtitle: Text(
                                          _infoBus??"Real-time departure not avaible",
                                          style: TextStyle(color: Colors.black54, fontSize: 18)),

                                    ),
                                  ),

                                  Card(
                                    child: ListTile(
                                      title: Text(
                                        'ALL STOPS',
                                        style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: ruteHalteBusList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Row(
                                          children: <Widget>[
                                            Container(
                                                child: CustomPaint(
                                                  painter: CurvePainter(color: getColor(getRute(widget.ruteBus.name))),
                                                ),
                                              color: Colors.white,
                                              width: 60,
                                              height: 60,
                                            ),
                                            Expanded(child: Container(child: makeCard(ruteHalteBusList[index]))),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
        ),
      );



  }

  void CreateListofHalte(QuerySnapshot snapshot) async
  {
    var docs = snapshot.documents;
    ruteHalteBusList = [];
    for (var Doc in docs)
    {
      await ruteHalteBusList.add(RuteHalteBus.fromFireStore(Doc));
    }
    setState(() {
      loading = false;
    });

  }

  void MasterList() async {
    await Firestore.instance.collection("rute_bus").document(widget.ruteBus.key.toString())
        .collection('halte_bus').orderBy('key').snapshots().listen(await CreateListofHalte);
  }
}



