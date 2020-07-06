import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numpakbis/models/halte_bus.dart';
import 'package:numpakbis/models/member.dart';
import 'package:numpakbis/models/rute_bus.dart';
import 'package:numpakbis/models/user.dart';

class DatabaseService{

  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference memberCollection = Firestore.instance.collection('member');
  final CollectionReference haltebusCollection = Firestore.instance.collection('halte_bus');
  final CollectionReference rutebusCollection = Firestore.instance.collection('rute_bus');

  Future updateUserData(String name, String email, String noHP, String job) async {
    return await memberCollection.document(uid).setData({
      'name': name,
      'email': email,
      'noHP': noHP,
      'job': job,
    });
  }

  // Member list from snapshot
  List<Member> _memberListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return Member(
          name: doc.data['name'] ?? '',
          email : doc.data['email'] ?? '',
          noHP : doc.data['noHP'] ?? '',
          job : doc.data['job'] ?? '',
      );
    }).toList();
  }

  // Halte Bus list from snapshot
  List<HalteBus> _halteBusListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return HalteBus(
        key: doc.documentID ?? '',
        name: doc.data['name'] ?? '',
        latitude : doc.data['latitude'] ?? '',
        longitude : doc.data['longitude'] ?? '',
        type : doc.data['type'] ?? '',
        rute : doc.data['rute'] ?? '',
      );
    }).toList();
  }

  // Rute Bus list from snapshot
  List<RuteBus> _ruteBusListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return RuteBus(
        key: doc.documentID ?? '',
        name: doc.data['rute_name'] ?? '',
        type : doc.data['rute_type'] ?? '',
      );
    }).toList();
  }

  // get member stream
  Stream<List<Member>> get members{
    return memberCollection.snapshots()
        .map(_memberListFromSnapshot);
  }

  // get halte bus stream
  Stream<List<HalteBus>> get haltebuses{
    return haltebusCollection.snapshots()
        .map(_halteBusListFromSnapshot);
  }

  // get rute bus stream
  Stream<List<RuteBus>> get rutebuses{
    return rutebusCollection.snapshots()
        .map(_ruteBusListFromSnapshot);
  }


  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot){
    return UserData(
      uid: uid,
      name: snapshot.data['name'],
      email : snapshot.data['email'],
      noHP : snapshot.data['noHP'],
      job : snapshot.data['job'],
    );
  }


  //get user doc stream
  Stream<UserData> get userData {
    return memberCollection.document(uid).snapshots()
        .map(_userDataFromSnapshot);
  }


}