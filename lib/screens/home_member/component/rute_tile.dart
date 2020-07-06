import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:numpakbis/models/rute_bus.dart';
import 'package:numpakbis/screens/home_member/component/rute_detail.dart';
import 'package:numpakbis/shared/global_function.dart';

class RuteTile extends StatelessWidget {
  final RuteBus ruteBus;
  RuteTile({ this.ruteBus });




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Card(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            decoration: new BoxDecoration(
                border: new Border(
                    right: new BorderSide(width: 2.0, color: getColor(getRute(ruteBus.name))))),
            child: FaIcon(FontAwesomeIcons.route ,color: getColor(getRute(ruteBus.name)), size: 30,),//Icon(Icons.directions_bus, color: Colors.blueAccent),
          ),
          title: Text(
            ruteBus.name,
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Row(
            children: <Widget>[
              Text( getType(ruteBus.type) , style: TextStyle(color: Colors.black54))
            ],
          ),
          trailing:
          Icon(Icons.keyboard_arrow_right, color: Colors.black45, size: 40.0),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => RuteDetail(ruteBus: ruteBus)));
          },
        ),
      ),
    );
  }
}
