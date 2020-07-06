import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:numpakbis/models/rute_bus.dart';
import 'package:numpakbis/models/plat_bus.dart';
import 'package:numpakbis/models/send_data.dart';
import 'package:numpakbis/shared/loading.dart';
import 'package:numpakbis/shared/loading_logo.dart';
import 'package:numpakbis/shared/global_function.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numpakbis/models/user.dart';

class FormOperator extends StatefulWidget {
  final UserData userData;
  FormOperator({ this.userData });
  @override
  _FormOperatorState createState() => _FormOperatorState();
}

class _FormOperatorState extends State<FormOperator> {
  final _formKey = GlobalKey<FormState>();

  // text field state
  String typeBus = '';
  String error = '';
  bool loading = false;
  RuteBus _selectedRute;
  RuteHalteBus _selectedHalte;
  PlatBus _selectedPlat;
  TypeBus _selectedType;
  var sendDataInfo;
  Position _currentPosition;

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

  void startServiceInPlatform() async{
    if(Platform.isAndroid){
      var methodChannel = MethodChannel("com.lieweitek.numpakbis/services");
      String data = await methodChannel.invokeMethod("startService",{
        "sender" : widget.userData.name,
        "senderKey" : widget.userData.uid,
        "nameBus" : _selectedPlat.noPlat,
        "ruteKey": _selectedRute.key,
        "ruteName": _selectedRute.name,
        "halteKey": _selectedHalte.key,
        "halteName": _selectedHalte.name,
        "halteLat": _selectedHalte.latitude,
        "halteLong": _selectedHalte.longitude,
        "lat": _currentPosition.latitude.toString(),
        "long": _currentPosition.longitude.toString(),
        "type": _selectedType.type,
      });
      debugPrint(data);
    }
  }

  Future<void> _setBoolTrueFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('serviceStarted', true);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Future.delayed(Duration.zero,() {
      setState(() {
        sendDataInfo = Provider.of<SendDataInfo>(context,listen: false);
      });
    });
    if(_currentPosition == null){
      _getCurrentLocation();
    }

  }





  @override
  Widget build(BuildContext context) {

    if(_currentPosition == null){
      _getCurrentLocation();
    }

    return loading ? LoadingLogo() : Scaffold(
      body: Container(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/numpakbis.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                // Drop Down Type Bus
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection("type_bus").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Loading();
                      else {
                        List<DropdownMenuItem<TypeBus>> typeItems = [];
                        for (int i = 0; i < snapshot.data.documents.length; i++) {
                          DocumentSnapshot snap = snapshot.data.documents[i];
                          typeItems.add(
                            DropdownMenuItem<TypeBus>(
                              child: SizedBox(
                                width: 250,
                                child: Text(
                                  snap.data['type'],
                                  //style: TextStyle(color: Color(0xff11b719)),
                                ),
                              ),
                              value: TypeBus(key: snap.documentID, type: snap.data['type'],city: snap.data['city']),
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20,0,0,0),
                              child: Icon(FontAwesomeIcons.road,
                                  size: 25.0, color: Colors.blueAccent),
                            ),
                            SizedBox(width: 30.0),
                            DropdownButton<TypeBus>(
                              items: typeItems,
                              onChanged: (TypeBus val) {
                                setState(() {
                                  //var temp = val.split("-");
                                  //print("rute = "+temp[0]+"-"+temp[1]);
                                  _selectedType = val;
                                  typeBus = val.type;
                                  _selectedRute = null;
                                  _selectedPlat = null;
                                  _selectedHalte = null;
                                });
                              },
                              value: _selectedType,
                              //validator: (val) => val == null ? 'Pilih Plat Bus' : null,
                              isExpanded: false,
                              hint: new Text(
                                "Pilih Jenis Bus",
                                //style: TextStyle(color: Color(0xff11b719)),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                SizedBox(height: 20.0),

                // Drop Down Plat Nomor Bus
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection("plat_bus").where("type",isEqualTo: typeBus).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Loading();
                      else {
                        List<DropdownMenuItem<PlatBus>> platItems = [];
                        for (int i = 0; i < snapshot.data.documents.length; i++) {
                          DocumentSnapshot snap = snapshot.data.documents[i];
                          platItems.add(
                            DropdownMenuItem<PlatBus>(
                              child: SizedBox(
                                width: 250,
                                child: Text(
                                  snap.data['noPlat'],
                                  //style: TextStyle(color: Color(0xff11b719)),
                                ),
                              ),
                              value: PlatBus(key: snap.documentID,noPlat: snap.data['noPlat'], type: snap.data['type'],city: snap.data['city']),
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20,0,0,0),
                              child: Icon(FontAwesomeIcons.busAlt,
                                  size: 25.0, color: Colors.blueAccent),
                            ),
                            SizedBox(width: 30.0),
                            DropdownButton<PlatBus>(
                              items: platItems,
                              onChanged: (PlatBus val) {
                                setState(() {
                                  //var temp = val.split("-");
                                  //print("rute = "+temp[0]+"-"+temp[1]);
                                  _selectedPlat = val;
                                  _selectedRute = null;
                                  _selectedHalte = null;
                                });
                              },
                              value: _selectedPlat,
                              //validator: (val) => val == null ? 'Pilih Plat Bus' : null,
                              isExpanded: false,
                              hint: new Text(
                                "Pilih Plat Nomor Bus",
                                //style: TextStyle(color: Color(0xff11b719)),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                SizedBox(height: 20.0),
                //DropDown Rute BUS
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection("rute_bus").where("rute_type",isEqualTo: typeBus).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Loading();
                      else {
                        List<DropdownMenuItem<RuteBus>> ruteItems = [];
                        for (int i = 0; i < snapshot.data.documents.length; i++) {
                          DocumentSnapshot snap = snapshot.data.documents[i];
                          ruteItems.add(
                            DropdownMenuItem<RuteBus>(
                              child: SizedBox(
                                width: 250,
                                child: Text(
                                  snap.data['rute_name'],
                                  //style: TextStyle(color: Color(0xff11b719)),
                                ),
                              ),
                              value: RuteBus(key: snap.documentID,name: snap.data['rute_name']),
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20,0,0,0),
                              child: Icon(FontAwesomeIcons.route,
                                  size: 25.0, color: Colors.blueAccent),
                            ),
                            SizedBox(width: 30.0),
                            DropdownButton<RuteBus>(
                              items: ruteItems,
                              onChanged: (RuteBus val) {
                                setState(() {
                                  //var temp = val.split("-");
                                  //print("rute = "+temp[0]+"-"+temp[1]);
                                  _selectedRute = val;
                                  _selectedHalte = null;
                                });
                              },
                              value: _selectedRute,
                              //validator: (val) => val == null ? 'Pilih rute bus' : null,
                              isExpanded: false,
                              hint: new Text(
                                "Pilih Koridor",
                                //style: TextStyle(color: Color(0xff11b719)),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                SizedBox(height: 20.0),
                // DropDown Halte Tujuan
                StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection("rute_bus").document(_selectedRute == null ? 'a' : _selectedRute.key.toString()).collection("halte_bus").orderBy("key").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Loading();
                      else {
                        List<DropdownMenuItem<RuteHalteBus>> halteItems = [];
                        for (int i = 0; i < snapshot.data.documents.length; i++) {
                          DocumentSnapshot snap = snapshot.data.documents[i];
                          if(i != snapshot.data.documents.length-1){
                            halteItems.add(
                              DropdownMenuItem<RuteHalteBus>(
                                child: SizedBox(
                                  width: 250,
                                  child: Text(
                                    snap.data['name'],
                                    //style: TextStyle(color: Color(0xff11b719)),
                                  ),
                                ),
                                value: RuteHalteBus(key: snap.documentID,name: snap.data['name'], latitude: snap.data['latitude'], longitude: snap.data['longitude']),
                              ),
                            );
                          }

                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20,0,0,0),
                              child: Icon(FontAwesomeIcons.mapMarkedAlt,
                                  size: 25.0, color: Colors.blueAccent),
                            ),
                            SizedBox(width: 30.0),
                            DropdownButton<RuteHalteBus>(
                              items: halteItems,
                              onChanged: (RuteHalteBus val) {
                                setState(() {
                                  //  var temp = val.split("-");
                                  _selectedHalte = val;
                                });

                              },
                              value: _selectedHalte ,//== null ? _selectedHalte : ruteHalteBus.where( (i) => i.name == _selectedHalte.name).first as RuteHalteBus,
                              //validator: (val) => val == null ? 'Pilih halte tujuan bus' : null,
                              isExpanded: false,
                              hint: new Text(
                                "Pilih Halte Tujuan",
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                const Divider(
                  height: 1.0,
                ),
                SizedBox(height: 10,),

                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: new Divider(color: Colors.grey[300], thickness: 3,

                  ),
                ),

                SizedBox(height: 5,),


                //SizedBox(height: 20,),
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0,0,0,20),
        child: Container(
          height: 136.0,
          width: 136.0,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                if (_formKey.currentState.validate()){
                  setState(() => loading = true);
                  if (_selectedType == null || _selectedRute == null || _selectedHalte == null || _selectedPlat == null){
                    setState(() {
                      error = 'isikan semua data !!!';
                      loading = false;
                    });
                  }else{
                    _setBoolTrueFromSharedPref();
                    startServiceInPlatform();
                    loading = false;
                    sendDataInfo.flag2 = true;
                  }
                }
              },
              backgroundColor: Colors.green[400],
              child: Text(
                'START',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomPadding: false,
    );
  }

}

