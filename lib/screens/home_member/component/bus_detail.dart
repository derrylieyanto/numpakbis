import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:numpakbis/models/bus.dart';
import 'package:numpakbis/models/distance.dart';
import 'package:numpakbis/shared/global_function.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;



class BusDetail extends StatefulWidget {
  Bus bus;
  String halteLat;
  String halteLong;
  BusDetail({ this.bus , this.halteLat, this.halteLong });


  @override
  _BusDetailState createState() => _BusDetailState();
}

class _BusDetailState extends State<BusDetail> {
  final _API = "AIzaSyB5DAWFw7QfviInDgsmiNSblskzqkUVSGk";
  SocketIO socketIO;
  Dio dio = new Dio();
  DistanceMatrix _distanceMatrix;
  var lat,long;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  LatLng _lastMapPosition = _center;
  static const LatLng _center = const LatLng(-7.797068, 110.370529);
  Position _currentPosition;
  Circle _circle;
  BitmapDescriptor iconMe;
  BitmapDescriptor iconHalte;
  final Set<Marker> _markers = {};
  String _infoTracking;

  // for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;




  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _controller.complete(controller);

    LatLng latLng_2 = LatLng(double.parse(widget.halteLat),double.parse(widget.halteLong));
    LatLng latLng_1 = LatLng(double.parse(widget.bus.latitude),double.parse(widget.bus.longitude));

    LatLng mid = MidPoint(double.parse(widget.halteLat), double.parse(widget.halteLong), double.parse(widget.bus.latitude), double.parse(widget.bus.longitude));

    setState(() {
      _markers.clear();
      addMarker(latLng_2, "Halte", widget.bus.halteName,iconHalte);
      addMarker(latLng_1, "Bus", widget.bus.name,BitmapDescriptor.defaultMarker);
    });

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: mid,
        zoom: 16.00)));

    setPolylines();


  }

  void addMarker(LatLng mLatLng, String mTitle, String mDescription, BitmapDescriptor mIcon){
    _markers.add(Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId(mTitle),
      position: mLatLng,
      infoWindow: InfoWindow(
        title: mDescription,
      ),
      icon: mIcon,
    ));
  }



  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }


  Future<void> _onCalculateDistance(String lat1, String long1) async {
    try{
      Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$lat1,$long1&destinations=${widget.halteLat},${widget.halteLong}&key=$_API");
      _distanceMatrix = new DistanceMatrix.fromJson(response.data);
      print(_distanceMatrix.elements[0].distance.text + ' - ' + _distanceMatrix.elements[0].distance.value.toString());
      print(_distanceMatrix.elements[0].duration.text + ' - ' + _distanceMatrix.elements[0].duration.value.toString());
      setState(() {
        _infoTracking = '${_distanceMatrix.elements[0].duration.text} (${(_distanceMatrix.elements[0].distance.value/1000).toStringAsFixed(1)} km)';
      });
    }catch(e){
      print(e);
    }
  }

  void setPolylines() async {
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        _API,
        double.parse(widget.bus.latitude),double.parse(widget.bus.longitude),
        double.parse(widget.halteLat),double.parse(widget.halteLong));
    print(result);
    if(result.isNotEmpty){
    result.forEach((PointLatLng point){
      polylineCoordinates.add(
          LatLng(point.latitude,point.longitude)
      );
    });     
    setState(() {
      _polylines.add(Polyline(
          width: 5, // set the width of the polylines
          polylineId: PolylineId("poly"),
          color: Colors.blue,
          points: polylineCoordinates
      ));
    });
  }
  }

  void updatePinOnMap() async {

    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(double.parse(lat),double.parse(long)),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));   // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {      // updated position
    var pinPosition = LatLng(double.parse(lat),double.parse(long));
    // the trick is to remove the marker (by id)
    // and add it again at the updated location
    _markers.removeWhere(
    (m) => m.markerId.value == 'Bus');
      _markers.add(Marker(
          markerId: MarkerId('Bus'),
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
    super.initState();
    _onCalculateDistance(widget.bus.latitude, widget.bus.longitude);

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

    socketIO = SocketIOManager().createSocketIO(
      'https://numpakbis-server.herokuapp.com/',
      '/',
    );
    //Call init before doing anything with socket
    socketIO.init();
    //Subscribe to an event to listen to
    socketIO.subscribe('receive_message', (jsonData) {
      //Convert the JSON data received into a Map
      if(jsonData != null){
        ReceiveMessage data = new ReceiveMessage.fromJson(jsonData);
        if(data.message.nameBus == widget.bus.name){
          setState(() {
            lat = data.message.latitude;
            long = data.message.longitude;
          });
          updatePinOnMap();
          _onCalculateDistance(lat, long);
          var distance = CalculationByDistance(double.parse(lat), double.parse(long)
              ,double.parse(widget.halteLat) , double.parse(widget.halteLong));
          if(double.parse(distance)<0.1){
            _sampaiTujuan();
          }
        }
      }
    });
    //Connect to the socket
    socketIO.connect();
  }

  _sampaiTujuan(){
    return showDialog(
      context: context,
      builder: (context)=>AlertDialog(
        content: Text('Bus telah sampai pada tujuan ${widget.bus.halteName}..'),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: (){
              var count = 0;
              Navigator.popUntil(context, (route) {
                return count++ == 2;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            markers:Set.of((_markers != null) ? _markers : []),
            circles: Set.of((_circle != null) ? [_circle] : []),
            polylines: Set.of((_polylines != null) ? _polylines : []),
            initialCameraPosition: CameraPosition(
              target: _center , //MidPoint(double.parse(widget.halteLat),double.parse(widget.halteLong),double.parse(widget.bus.latitude),double.parse(widget.bus.longitude)),
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
                            Expanded(
                              child: Container(
                                child: ListView(
                                  controller: myscrollController,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Card( //                           <-- Card
                                          child: ListTile(
                                            title: Text(
                                              'REAL-TIME TRACKING',
                                              style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                        ),

                                        Card(
                                          elevation: 1,
                                          //margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10.0,),
                                            title: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  _infoTracking == null ? '' : _infoTracking,
                                                  style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                                SizedBox(height: 5,),
                                                Text(
                                                  'Fastest route with traffic jam',
                                                  style: TextStyle(color: Colors.black54, fontSize: 14),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(height: 10,),
                                              ],
                                            ),
                                            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
                                          ),
                                        ),

                                        Card(
                                          elevation: 1,
                                          //margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                            leading: Container(
                                              padding: EdgeInsets.only(right: 12.0),
                                              decoration: new BoxDecoration(
                                                  border: new Border(
                                                      right: new BorderSide(width: 2.0, color: Colors.blueAccent))),
                                              child: Icon(Icons.directions_bus, color: Colors.blueAccent, size: 60,),
                                            ),
                                            title: Text(
                                              widget.bus.name,
                                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 24),
                                            ),
                                            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(height: 2,),
                                                Text( 'Transjogja', style: TextStyle(color: Colors.black54, fontSize: 18)),
                                                SizedBox(height: 2,),
                                                Text( '${widget.bus.rute}', style: TextStyle(color: Colors.black54, fontSize: 18)),
                                                SizedBox(height: 2,),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Card(
                                          elevation: 1,
                                          //margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10.0,),
                                            leading: Text(
                                              'Halte Tujuan :',
                                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
                                              textAlign: TextAlign.left,
                                            ),
                                            title: Text(
                                              '${widget.bus.halteName}',
                                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
                                            ),
                                            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      /*  Expanded(
                                          child: Container(
                                            child: ListView.builder(
                                                controller: myscrollController,
                                                itemCount: 25,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return ListTile(
                                                      title: Text(
                                                        'Item $index',
                                                        style: TextStyle(color: Colors.black54),
                                                      ));
                                                },
                                            ),
                                          ),
                                        ),*/
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
/*      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: (){
            _getCurrentLocation();
          }),*/
    );
  }
}
