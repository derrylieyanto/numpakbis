import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class DistanceMatrix {
  final List<String> destinations;
  final List<String> origins;
  final List<Element> elements;
  final String status;

  DistanceMatrix({this.destinations, this.origins, this.elements, this.status});

  factory DistanceMatrix.fromJson(Map<String, dynamic> json) {
    var destinationsJson = json['destination_addresses'];
    var originsJson = json['origin_addresses'];
    var rowsJson = json['rows'][0]['elements'] as List;

    return DistanceMatrix(
        destinations: destinationsJson.cast<String>(),
        origins: originsJson.cast<String>(),
        elements: rowsJson.map((i) => new Element.fromJson(i)).toList(),
        status: json['status']);
  }

  static Future<DistanceMatrix> loadData() async {
    DistanceMatrix distanceMatrix;
    try{
      String jsonData = await rootBundle.loadString('assets/data.json');
      distanceMatrix = new DistanceMatrix.fromJson(json.decode(jsonData));
    } catch (e){
      print(e);
    }
    return distanceMatrix;
  }
}

class Element {
  final Distance distance;
  final Durations duration;
  final String status;

  Element({this.distance, this.duration, this.status});

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
        distance: new Distance.fromJson(json['distance']),
        duration: new Durations.fromJson(json['duration']),
        status: json['status']);
  }
}

class Distance {
  final String text;
  final int value;

  Distance({this.text, this.value});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return new Distance(text: json['text'], value: json['value']);
  }
}

class Durations {
  final String text;
  final int value;

  Durations({this.text, this.value});

  factory Durations.fromJson(Map<String, dynamic> json) {
    return new Durations(text: json['text'], value: json['value']);
  }
}