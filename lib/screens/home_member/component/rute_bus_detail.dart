
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:numpakbis/models/bus.dart';
import 'package:numpakbis/models/bus_list.dart';

import 'package:numpakbis/models/halte_bus.dart';
import 'package:numpakbis/screens/home_member/component/bus_detail.dart';
import 'package:numpakbis/shared/global_function.dart';
import 'package:provider/provider.dart';


class RuteBusStopDetail extends StatefulWidget {
  final HalteBus halteBus;
  RuteBusStopDetail({ this.halteBus });
  @override
  _RuteBusStopDetailState createState() => _RuteBusStopDetailState();
}

class _RuteBusStopDetailState extends State<RuteBusStopDetail> {
  List<Bus> _buses = [];

  @override
  Widget build(BuildContext context) {
    var busDataInfo = Provider.of<BusLocInfo>(context);
    var isSameHalte = false;
    if(busDataInfo.buses.isNotEmpty){
      for(var i=0;i<busDataInfo.buses.length;i++){
        if(busDataInfo.buses[i].halteName.toLowerCase() == widget.halteBus.name.toLowerCase()){
          isSameHalte = true;
          print('Rute dari Socket: ${busDataInfo.buses[i].rute}');
          print('Rute widget: ${widget.halteBus.rute}');
          if(busDataInfo.buses[i].rute == 'Rute ${widget.halteBus.rute}'){
            if(_buses == null || _buses.isEmpty){
              _buses.add(busDataInfo.buses[i]);
            }else{
              bool isSameBus = false;
              for(var j = 0 ; j<_buses.length; j++){
                if(_buses[j].name == busDataInfo.buses[i].name){
                  _buses[j] = busDataInfo.buses[i];
                  isSameBus = true;
                }
              }
              if(isSameBus == false){
                _buses.add(busDataInfo.buses[i]);
              }
            }
          }

        }
      }
    }

    var _text = widget.halteBus.rute.split(',');

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 50.0),
        Icon(
          Icons.airport_shuttle,
          color: Colors.lightBlue,
          size: 40.0,
        ),
        Container(
          width: 120.0,
          child: new Divider(color: Colors.lightBlue, thickness: 3,
          ),
        ),
        SizedBox(height: 10.0),
        SizedBox(
          height: 110,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(
            widget.halteBus.name,
            style: TextStyle(color: Colors.black54, fontSize: widget.halteBus.name.length>28 ? 30.0 : 40),
          ),
        ),
        SizedBox(height: 3.0),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 5,
                  child:  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: new ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _text.length,
                      itemBuilder: (context,index){
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: FlatButton(
                            onPressed: (){},
                            child: Text(
                              _text[index].trim(),
                              style: TextStyle(color: getColor(_text[index].trim()), fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            shape: RoundedRectangleBorder(side: BorderSide(
                                color: getColor(_text[index].trim()),
                                width: 2,
                                style: BorderStyle.solid
                            ), borderRadius: BorderRadius.circular(5)),
                          ),
                        );
                        /*Container(
                        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        decoration: new BoxDecoration(
                            border: new Border.all(color: getColor(_text[index].trim()), width: 2),
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text(
                            _text[index].trim(),
                            style: TextStyle(color: getColor(_text[index].trim()), fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );*/
                      },
                    ),
                  )
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 1),
                  decoration: new BoxDecoration(
                    //border: new Border.all(color: Colors.black54, width: 2),
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5.0)),
                  child: new Text(
                    getType(widget.halteBus.type),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(40.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Colors.white),//fromRGBO(58, 66, 86, .9)),
          child: Center(
            child: topContentText,
          ),
        ),
        Positioned(
          left: 8.0,
          top: 35.0,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.lightBlue, size: 35,),
          ),
        )
      ],
    );

    ListTile makeListTile(Bus bus){
      //_onCalculateDistance(bus);
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        leading: Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: getColor(getRute(bus.rute)), width: 2),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            getRute(bus.rute)??'',
            style: TextStyle(color: getColor(getRute(bus.rute)), fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        title: Text(
          bus.name??'',
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ), // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
        subtitle: Text(
            bus.distance??'calculate distance...',
            style: TextStyle(color: Colors.black87)
        ),
        trailing:
        Icon(Icons.keyboard_arrow_right, color: Colors.black45, size: 30.0),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => BusDetail(bus: bus,halteLat: widget.halteBus.latitude,halteLong: widget.halteBus.longitude,)));
        },

      );
    }

    Card makeCard(Bus bus) => Card(
      elevation: 1.0,
      margin: new EdgeInsets.fromLTRB(8,0,8,10),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: makeListTile(bus),
      ),
    );

    final bottomContent = Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _buses.length,
        itemBuilder: (BuildContext context, int index) {
          return makeCard(_buses[index]);
        },
      ),
    );

    final bottomContent2 = Card(
      elevation: 1.0,
      margin: new EdgeInsets.symmetric(
          horizontal: 0.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0, vertical: 10.0),
          title: Text(
            'At the moment there are no real-time departures.',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );


    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[Expanded(child: topContent),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                          Text('REAL-TIME DEPARTURE', style: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          ),
                          isSameHalte == false ? bottomContent2 : _buses == null ?  bottomContent2 : _buses.length == 0 ?  bottomContent2 : bottomContent,
                          SizedBox(height: 20,),
                          Text('SCHEDULE FROM 6:00 AM TILL 6:00 PM',
                            style: TextStyle(color: Colors.black38,
                              fontWeight: FontWeight.bold,fontSize: 14,),),
                          Card(
                            elevation: 1.0,
                            margin: new EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 10.0),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                title: Text(
                                  'Every 15 min',
                                  style: TextStyle(color: Colors.black54,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}


