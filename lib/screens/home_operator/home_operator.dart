
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:android_intent/android_intent.dart';
import 'package:numpakbis/models/send_data.dart';
import 'package:numpakbis/screens/home_operator/operator_wrapper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:numpakbis/models/rute_bus.dart';
import 'package:numpakbis/services/database.dart';
import 'package:numpakbis/shared/loading_logo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numpakbis/models/user.dart';


class HomeOperator extends StatefulWidget {
  final UserData userData;
  HomeOperator({ this.userData });
  @override
  _HomeOperatorState createState() => _HomeOperatorState();
}

class _HomeOperatorState extends State<HomeOperator> {

  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;
  bool _serviceStarted;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestLocationPermission();
    _gpsService();
    _setFlag();
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }
/*Checking if your App has been Given Permission*/
  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted!=true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }
/*Show dialog if GPS not enabled and open settings location*/
  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get gurrent location"),
                content:const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        _gpsService();
                      })],
              );
            });
      }
    }
  }

/*Check if gps service is enabled or not*/
  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else
      return true;
  }

  Future<bool> _getBoolFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final serviceStarted = prefs.getBool('serviceStarted');
    if (serviceStarted == null) {
      return false;
    }
    return serviceStarted;
  }

  Future<void> _setFlag() async {
    bool currentFlag = await _getBoolFromSharedPref();

    setState(() {
      _serviceStarted = currentFlag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RuteBus>>(
      stream: DatabaseService().rutebuses,
      builder: (context,snapshot){
        if(snapshot.hasData){
          return ChangeNotifierProvider(
            create: (context) => SendDataInfo(_serviceStarted),
            child: OperatorWrapper(userData: widget.userData,),
          );
        }else{
          return LoadingLogo();
        }
      },
    );
  }
}

Future<void> checkGPS() async{
  GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
  return print(geolocationStatus);
}

