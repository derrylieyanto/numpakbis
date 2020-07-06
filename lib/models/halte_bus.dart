
import 'package:numpakbis/models/rute_bus.dart';

class HalteBus{
  String key;
  String name;
  String latitude;
  String longitude;
  String type;
  String rute;
  HalteBus({ this.key, this.name, this.latitude, this.longitude, this.type, this.rute });


  HalteBus.fromRute(RuteHalteBus r,String rute){
    this.key = r.key;
    this.name = r.name;
    this.latitude = r.latitude;
    this.longitude = r.longitude;
    this.type = r.type;
    this.rute = rute;
  }

}