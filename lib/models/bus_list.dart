
import 'package:flutter/cupertino.dart';
import 'package:numpakbis/models/bus.dart';

class BusLocInfo extends ChangeNotifier{
  final List<Bus> _buses = [];
  String _latitude = '';
  String _longitude = '';


  List<Bus> get buses => _buses;

  void define(Bus bus, int index){
    _buses[index] = bus;
    notifyListeners();
  }

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void add(Bus bus) {
    _buses.add(bus);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    _buses.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void removeAt(int index){
    _buses.removeAt(index);
    notifyListeners();
  }

  String get longitude => _longitude;

  set longitude(String value) {
    _longitude = value;
    notifyListeners();
  }

  String get latitude => _latitude;

  set latitude(String value) {
    _latitude = value;
    notifyListeners();
  }

  @override
  String toString() {
    return 'BusLocInfo{_buses: $_buses}';
  }


}