import 'package:cloud_firestore/cloud_firestore.dart';

class RuteBus{
   String key;
   String name;
   String type;
   RuteHalteBus halteBus;
  RuteBus({ this.key, this.name, this.halteBus, this.type });

  bool operator ==(o) => o is RuteBus && o.name == name;
  int get hashCode => name.hashCode;

  @override toString() => 'Name: $name';
}

class RuteHalteBus{
  String key;
  String name;
  String latitude;
  String longitude;
  String type;
  RuteHalteBus({ this.key, this.name, this.latitude, this.longitude, this.type });

  bool operator ==(o) => o is RuteHalteBus && o.name == name;
  int get hashCode => name.hashCode;

  factory RuteHalteBus.fromFireStore(DocumentSnapshot doc)
  {
    Map data = doc.data ;
    return RuteHalteBus(
        key: doc.documentID,
        name: data['name'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        type:  data['type'],
    );
  }


  @override toString() => 'Name: $name';


}