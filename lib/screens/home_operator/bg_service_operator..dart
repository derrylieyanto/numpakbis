import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:numpakbis/models/send_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService extends StatelessWidget {

  void stopServiceInPlatform() async{
    if(Platform.isAndroid){
      var methodChannel = MethodChannel("com.lieweitek.numpakbis/services");
      String data = await methodChannel.invokeMethod("stopService");
      debugPrint(data);
    }
  }

  Future<void> _setBoolFalseFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('serviceStarted', false);
  }

  @override
  Widget build(BuildContext context) {
    var sendDataInfo = Provider.of<SendDataInfo>(context);
    return Scaffold(
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30, width: MediaQuery.of(context).size.width),
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
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: new Divider(color: Colors.grey[300], thickness: 5,

                ),
              ),
              SizedBox(height: 20,),
              SpinKitPouringHourglass(
                color: Colors.grey[400],
                size: 100,
              ),
              SizedBox(height: 40,),
              Text(
                'service running in background...',
                style: TextStyle(fontSize: 20,color: Colors.black54),

              ),
              SizedBox(height: 20,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: new Divider(color: Colors.grey[300], thickness: 5,

                ),
              ),
            ],
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
                  stopServiceInPlatform();
                  _setBoolFalseFromSharedPref();
                  sendDataInfo.flag2 = false;
                },
              backgroundColor: Colors.red,
              child: Text(
                'STOP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
