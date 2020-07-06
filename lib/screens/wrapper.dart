import 'package:flutter/material.dart';
import 'package:numpakbis/models/bus_list.dart';
import 'package:numpakbis/models/user.dart';
import 'package:numpakbis/screens/authenticate/authenticate.dart';
import 'package:numpakbis/screens/home_member/home_member.dart';
import 'package:numpakbis/screens/home_operator/home_operator.dart';
import 'package:numpakbis/services/database.dart';
import 'package:numpakbis/shared/loading_logo.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);


    if (user == null){
      return Authenticate();
    }else{
      return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            UserData userData = snapshot.data;
            if(userData.job == 'member'){
              return HomeMember(userData: userData,);
            }else{
              return HomeOperator(userData: userData,);
            }
          }else{
            return LoadingLogo();
          }
        }
      );
    }
  }
}
