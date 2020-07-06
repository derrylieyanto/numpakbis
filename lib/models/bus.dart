import 'dart:convert';


class Bus{
  final String key;
  final String name;
  final String rute;
  final String latitude;
  final String longitude;
  final String halteLat;
  final String halteLong;
  final String halteName;
  final String halteKey;
  final String distance;
  Bus({ this.key, this.name, this.rute , this.latitude, this.longitude, this.halteName, this.halteKey, this.distance, this.halteLat, this.halteLong});

  @override
  String toString() {
    return 'Bus{key: $key, name: $name, rute: $rute, latitude: $latitude, longitude: $longitude, halteLat: $halteLat, halteLong: $halteLong, halteName: $halteName, halteKey: $halteKey, distance: $distance}';
  }


}




class Message{
  String halteKey;
  String halteLat;
  String halteLong;
  String halteName;
  String latitude;
  String longitude;
  String nameBus;
  String ruteKey;
  String ruteName;
  String status;

  Message.fromJson(Map<String, dynamic> jsonMap) {
    this.halteKey = jsonMap['halteKey'];
    this.halteLat = jsonMap['halteLat'];
    this.halteLong = jsonMap['halteLong'];
    this.halteName = jsonMap['halteName'];
    this.latitude = jsonMap['latitude'];
    this.longitude = jsonMap['longitude'];
    this.nameBus = jsonMap['nameBus'];
    this.ruteKey = jsonMap['ruteKey'];
    this.ruteName = jsonMap['ruteName'];
    this.status = jsonMap['status'];
  }


}

class ReceiveMessage{
  String sender;
  Message message;

  ReceiveMessage.fromJson(String jsonStr) {
    final _map = jsonDecode(jsonStr);
    this.sender = _map['sender'];
    this.message = new Message.fromJson(_map['message']);
  }

}