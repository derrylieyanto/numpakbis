
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numpakbis/models/halte_bus.dart';
import 'package:numpakbis/screens/home_member/component/bus_stops_detail.dart';
import 'package:numpakbis/shared/global_function.dart';

class BusStopTile extends StatelessWidget {
  final HalteBus halteBus;
  final String distance;
  BusStopTile({ this.halteBus , this.distance });

  @override
  Widget build(BuildContext context) {
    var _text = halteBus.rute.split(',');
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Card(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      right: new BorderSide(width: 2.0, color: Colors.blueAccent))),
              child: Icon(Icons.directions_bus, color: Colors.blueAccent, size: 45,),
            ),
            title: Text(
              halteBus.name,
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text( 'Jarak: $distance km', style: TextStyle(color: Colors.black54)),
                Text( getType(halteBus.type), style: TextStyle(color: Colors.black54)),
                Container(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: new ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: _text.length,
                          itemBuilder: (context,index){
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(0,5,10,10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 1,horizontal: 1),
                                decoration: new BoxDecoration(
                                    border: new Border.all(color: getColor(_text[index].trim())),
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: new Text(
                                  _text[index].trim(),
                                  style: TextStyle(color: getColor(_text[index].trim())),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                     // Text( _text[0], style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                //Text( halteBus.rute, style: TextStyle(color: Colors.black54)),
              ],
            ),
            trailing:
            Icon(Icons.keyboard_arrow_right, color: Colors.black45, size: 60.0),
            onTap: () {

              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => BusStopDetail(halteBus: halteBus)));
            },
         /* leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue,
            backgroundImage: AssetImage('assets/car_icon.png'),
          ),
          title: Text(halteBus.name),
          subtitle: Text(halteBus.type == 'TJ' ? 'Halte Transjogja':'Halte Bus'),*/
        ),
      ),
    );
  }
}
