
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:numpakbis/models/bus.dart';
import 'package:numpakbis/models/bus_list.dart';
import 'package:numpakbis/models/distance.dart';
import 'package:numpakbis/models/user.dart';
import 'package:numpakbis/screens/home_member/rute.dart';
import 'package:numpakbis/screens/home_member/bus_stops.dart';
import 'package:numpakbis/screens/home_member/home_page.dart';
import 'package:numpakbis/screens/home_member/profile.dart';
import 'package:numpakbis/services/auth.dart';
import 'package:provider/provider.dart';


class HomeMember extends StatefulWidget {
  final UserData userData;
  HomeMember({ this.userData });
  @override
  _HomeMemberState createState() => _HomeMemberState();
}

class _HomeMemberState extends State<HomeMember> {

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  int _selectedTabIndex = 0;
  var busData;
  final _API = "AIzaSyB5DAWFw7QfviInDgsmiNSblskzqkUVSGk";
  SocketIO socketIO;
  Dio dio = new Dio();
  DistanceMatrix _distanceMatrix;
  String _infoTracking;

  Future<void> _onCalculateDistance(lat1,lon1,lat2,lon2) async {
    try{
      Response response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$lat1,$lon1&destinations=$lat2,$lon2&key=$_API");
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

  Future _onNavBarTapped(int index) async{
    return await setState(() {
        _selectedTabIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Future.delayed(Duration.zero,() {
      setState(() {
        busData = Provider.of<BusLocInfo>(context, listen: false);
      });
    });

    socketIO = SocketIOManager().createSocketIO(
      'https://numpakbis-server.herokuapp.com/',
      '/',
    );
    //Call init before doing anything with socket
    socketIO.init();
    //Subscribe to an event to listen to
    socketIO.subscribe('receive_message', (jsonData) async{
      print('SOCKET DITERIMA');
      //Convert the JSON data received into a Map
      if(jsonData != null){
        ReceiveMessage data = new ReceiveMessage.fromJson(jsonData);
        await _onCalculateDistance(double.parse(data.message.latitude),
          double.parse(data.message.longitude),
          double.parse(data.message.halteLat),
          double.parse(data.message.halteLong)
        );
        Bus tempBus = new Bus(
          name: data.message.nameBus,
          halteName: data.message.halteName,
          halteKey: data.message.halteKey,
          latitude: data.message.latitude,
          longitude: data.message.longitude,
          rute: data.message.ruteName,
          halteLat: data.message.halteLat,
          halteLong: data.message.halteLong,
          distance: _infoTracking,
        );
        if(data.message.status == "active"){
          if(busData.buses == null || busData.buses.isEmpty){
            busData.add(tempBus);
          }else{
            bool isContains = false;
            for(var i = 0; i<busData.buses.length;i++){
              if(busData.buses[i].name.toLowerCase() == tempBus.name.toLowerCase()){
                isContains = true;
                busData.define(tempBus,i);
              }
            }
            if(isContains == false){
              busData.add(tempBus);
            }
          }
        }else{
          if(busData.buses.isNotEmpty){
            for(var i = 0; i<busData.buses.length;i++){
              if(busData.buses[i].name.toLowerCase() == tempBus.name.toLowerCase()){
                busData.removeAt(i);
              }
            }
          }
        }
      }
    });
    //Connect to the socket
    socketIO.connect();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(socketIO != null){
      socketIO.disconnect();
      socketIO.destroy();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final _listPage = <Widget>[
      HomePage(),
      BusStop(),
      Rute(),
      Profile(userData: widget.userData),
    ];

    final _pageTitle = <String>[
      'Home',
      'Stops near me',
      'Buses',
      'Profile',
    ];

    final _bottomNavBarItem = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        title: Text('Home'),
        icon: Icon(Icons.home),
      ),
      BottomNavigationBarItem(
        title: Text('Stops'),
        icon: Icon(Icons.pin_drop),
      ),
      BottomNavigationBarItem(
        title: Text('Routes'),
        icon: Icon(Icons.directions_bus),
      ),
      BottomNavigationBarItem(
        title: Text('Profile'),
        icon: Icon(Icons.person),
      ),
    ];

    final _bottomNavBar = BottomNavigationBar(
      items: _bottomNavBarItem,
      currentIndex: _selectedTabIndex,
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.grey,
      elevation: 20,
      showUnselectedLabels: true,
      onTap: _onNavBarTapped,
    );

    Future<bool> _onBackPressed(){
      return showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          content: Text('Do you really want to exit NumpakBis?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: ()=>Navigator.pop(context,false),
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: (){
                Navigator.pop(context,true);
              },
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.grey[100],
          key: _scaffoldKey,
          appBar: AppBar(
          title: Text(_pageTitle[_selectedTabIndex], style: TextStyle(color: Colors.lightBlue),),
          backgroundColor: Colors.white,
          elevation: 1,
          /*actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person, color: Colors.redAccent,),
              label: Text('Sign Out', style: TextStyle(color: Colors.redAccent),),
              onPressed: () async {
                 await _auth.signOut();
              },
            ),
          ],*/
        ),
        body: Center(
          child: _listPage[_selectedTabIndex],
        ),
        bottomNavigationBar: _bottomNavBar,
      ),
    );
  }
}
