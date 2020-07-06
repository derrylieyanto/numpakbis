import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String getRute(String string){
  var temp = string.split(" ");
  return temp[1];
}

String getType(String string){
  String temp = '';
  switch(string){
    case 'TJ':{
      temp = 'Transjogja';
    }
    break;
    case 'TJ-P':{
      temp = 'Transjogja Portable';
    }
    break;
    default:{
      temp = 'Halte Bus';
    }
    break;
  }
  return temp;
}


Color getColor(String s){
  Color temp;
  switch(s){
    case '1A':{
      temp = Colors.orange;
    }
    break;
    case '1B':{
      temp = Colors.blue;
    }
    break;
    case '2A':{
      temp = Colors.red;
    }
    break;
    case '2B':{
      temp = Colors.deepPurpleAccent;
    }
    break;
    case '3A':{
      temp = Colors.purpleAccent;
    }
    break;
    case '3B':{
      temp = Colors.cyan;
    }
    break;
    case '4A':{
      temp = Colors.brown;
    }
    break;
    case '5A':{
      temp = Colors.pink;
    }
    break;
    case '5B':{
      temp = Colors.pinkAccent;
    }
    break;
    case '07':{
      temp = Colors.green;
    }
    break;
    case '08':{
      temp = Colors.lightGreen;
    }
    break;
    case '09':{
      temp = Colors.green[400];
    }
    break;
    case '10':{
      temp = Colors.indigo;
    }
    break;
    case '11':{
      temp = Colors.indigo[400];
    }
    break;
    default:{
      temp = Colors.black54;
    }
    break;
  }
  return temp;
}

String CalculationByDistance(double initialLat,double initialLong, double finalLat, double finalLong){
  int R = 6371; // km (Earth radius)
  double dLat = toRadians(finalLat-initialLat);
  double dLon = toRadians(finalLong-initialLong);
  initialLat = toRadians(initialLat);
  finalLat = toRadians(finalLat);

  double a = sin(dLat/2) * sin(dLat/2) +
      sin(dLon/2) * sin(dLon/2) * cos(initialLat) * cos(finalLat);
  double c = 2 * atan2(sqrt(a), sqrt(1-a));
  return (R * c).toStringAsFixed(1);
}

LatLng MidPoint(double lat1,double long1, double lat2, double long2){

  double Bx = cos(lat2) * cos(long2-long1);
  double By = cos(lat2) * sin(long2-long1);
 /* double a = ((cos(lat1)+Bx)*(cos(lat2)+Bx))+(By*By);
  double b = sin(lat1)+sin(lat2);
  double latMid = atan2(b , sqrt(a))*/

  double lonMid = long1 + atan2(By, cos(lat1)+Bx);
  double latMid = (lat1+lat2)/2;

  print(latMid);
  print(lonMid);
  return LatLng(latMid,lonMid);

}

double toRadians(double deg) {
  return deg * (pi/180);
}

LatLng southwestFromLatLngList(List<LatLng> list) {
  assert(list.isNotEmpty);
  double x0, x1, y0, y1;
  for (LatLng latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
  }
  return LatLng(x0,y0);
}

LatLng northeastFromLatLngList(List<LatLng> list) {
  assert(list.isNotEmpty);
  double x0, x1, y0, y1;
  for (LatLng latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
  }

  return LatLng(x1,y1);
}

double area(List<LatLng> arr) {
  double area=0;
  int nPts = arr.length-1;
  int j=nPts-1;
  LatLng p1;
  LatLng p2;
  for (int i=0;i<nPts;j=i++) {

    p1=arr[i]; p2=arr[j];
    area+=p1.latitude*p2.longitude;
    area-=p1.longitude*p2.latitude;
  }
  area/=2;

  return area;
}

LatLng Centroid (List<LatLng> pts) {
  int nPts = pts.length-1;
  double x=0; double y=0;
  double f;
  int j=nPts-1;
  LatLng p1; LatLng p2;

  for (int i=0;i<nPts;j=i++) {
    p1=pts[i]; p2=pts[j];
    f=p1.latitude*p2.longitude-p2.latitude*p1.longitude;
    x+=(p1.latitude+p2.latitude)*f;
    y+=(p1.longitude+p2.longitude)*f;
  }

  f=area(pts)*6;

  return new LatLng(x/f, y/f);
}