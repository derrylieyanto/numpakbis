
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:numpakbis/models/rute_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendDataInfo extends ChangeNotifier{
  bool _flag2;
  String _nameBus = '';
  RuteBus _rute;
  RuteHalteBus _halteTujuan;


  SendDataInfo(bool b){
    _flag2 = b;
    _setFlag();
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
    _flag2 = currentFlag;
  }

  ValueNotifier<bool> _flag = ValueNotifier(false);

  ValueListenable<bool> get flag => _flag;

  void toggleFlag(){
    _flag.value = !_flag.value;
    _writeFlag(_flag.value);
  }


  Future<void> _writeFlag(bool bool) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.setBool('serviceStarted', bool);
  }

  bool get flag2Val => _flag2;
  String get nameBusVal => _nameBus;
  RuteBus get ruteVal => _rute;
  RuteHalteBus get ruteHalteBusVal => _halteTujuan;


  set nameBus(String value) {
    _nameBus = value;
    notifyListeners();
  }

  set flag2(bool newFlag){
    _flag2 = newFlag;
    notifyListeners();
  }

  set rute(RuteBus value) {
    _rute = value;
    notifyListeners();
  }

  set halteTujuan(RuteHalteBus value) {
    _halteTujuan = value;
    notifyListeners();
  }
}