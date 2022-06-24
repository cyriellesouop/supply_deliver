import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Database_Model.dart';

class UserService {
  CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("user");

  //Get users
  Stream<List<UserModel>> getUsers() {
    // int x = 0;
    print("moguem souop audrey");
    return userCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return UserModel(
              idUser: doc.get('idUser'),
              adress: doc.get('adress'),
              name: doc.get('name'),
              //phone: int.parse(doc.get('phone')),
              tool: doc.get('tool'),
              picture: doc.get('picture'),
              idPosition: doc.get('idPosition'),
              isManager: doc.get('isManager'),
              isClient: doc.get('isClient'),
              isDeliver: doc.get('isDeliver'),
             // token: doc.get('token')
              // createdAt: doc.get('createdAt')
              );
        }).toList();
      },
    );
  }

//liste de tous les utilisateurs 
  Stream<List<UserModel>> getAlluser() {

    print("tous les livreurs");
    return userCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return UserModel(
            //idUser: data['idUser'],
            idUser: doc.get('idUser'),
            adress: doc.get('adress'),
            name: doc.get('name'),
            phone: int.parse(doc.get('phone')),
            tool: doc.get('tool'),
            picture: doc.get('picture'),
            idPosition: doc.get('idPosition'),
            isManager: doc.get('isManager'),
            isClient: doc.get('isClient'),
            isDeliver: doc.get('isDeliver'),
            token: doc.get('token')
            //createdAt: doc.get('createdAt')
          );
        }).toList();
      },
    );
  }

//liste de livreurs correcte
  Stream<List<UserModel>> getDelivers() {
    print("moguem souop audrey");
    return userCollection.where('isDeliver', isEqualTo: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return UserModel(
              idUser: doc.get('idUser'),
              // adress: doc.get('adress'),
              name: doc.get('name'),
              // phone: int.parse(doc.get('phone')),
              tool: doc.get('tool'),
              picture: doc.get('picture'),
              idPosition: doc.get('idPosition'),
              isManager: doc.get('isManager'),
              isClient: doc.get('isClient'),
              isDeliver: doc.get('isDeliver'),
              token: doc.get('token')
              // createdAt: doc.get('createdAt')
              );
        }).toList();
      },
    );
  }

  //liste des managers correctes
  Stream<List<UserModel>> getManagers() {
    print("moguem souop audrey");
    return userCollection.where('isManager', isEqualTo: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return UserModel(
              idUser: doc.get('idUser'),
              adress: doc.get('adress'),
              name: doc.get('name'),
              phone: int.parse(doc.get('phone')),
              tool: doc.get('tool'),
              picture: doc.get('picture'),
              idPosition: doc.get('idPosition'),
              isManager: doc.get('isManager'),
              isClient: doc.get('isClient'),
              isDeliver: doc.get('isDeliver'),
              token: doc.get('token')
              //createdAt: doc.get('createdAt')
              );
        }).toList();
      },
    );
  }

  Future<void> updateUser(UserModel user) async {
    userCollection.doc(user.idDoc).update(
      {
        'adress': user.adress,
        'name': user.name,
        'phone': user.phone,
        'picture': user.picture,
        'idPosition': user.idPosition,
      },
    );
  }

  ////////////////////////////////////////////////////////////////////////
  Future<Stream<List<UserModel>>> getDeliverss() async {
    print("moguem souop audrey");
    return userCollection.where('isDeliver', isEqualTo: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return UserModel(
              //idUser: data['idUser'],
              idUser: doc.get('idUser'),
              adress: doc.get('adress'),
              name: doc.get('name'),
              phone: int.parse(doc.get('phone')),
              tool: doc.get('tool'),
              picture: doc.get('picture'),
              idPosition: doc.get('idPosition'),
              isManager: doc.get('isManager'),
              isClient: doc.get('isClient'),
              isDeliver: doc.get('isDeliver'),
              token: doc.get('token')
              //createdAt: doc.get('createdAt')
              );
        }).toList();
      },
    );
  }

//retourner un utilisateur grace a son identifiant sous format de userModel correcte
  Future<UserModel> getUserbyId(String idUsersearch) async {
    print('identifianttttttttt $idUsersearch');
    return userCollection
        .where('idUser', isEqualTo: idUsersearch)
        .get()
        .then((value) {
      if (value != null) {
        var res = value.docs.first.data();
        print('le premier resultat de la requete  $res');
        var resmap = Map<String, dynamic>.from(res);
        print('typereeeeeeeee varrrrrrrrrrr $resmap');
        return UserModel(
          //idUser: data['idUser'],
          idUser: resmap['idUser'],
          adress: resmap['adress'],
          name: resmap['name'],
          // phone: int.parse(resmap['phone']),
          phone: resmap['phone'],
          tool: resmap['tool'],
          picture: resmap['picture'],
          idPosition: resmap['idPosition'],
          isManager: resmap['isManager'],
          isClient: resmap['isClient'],
          isDeliver: resmap['isDeliver'],
          token: resmap['token'],
          // createdAt:resmap['createdAt']
        );
      } else
        throw Exception("aucun utilisateur trouve dans la bd");
    });
  }

//add an user correcte
  Future<String> addUser(UserModel user) async {
    var documentRef = await userCollection.add({
      //  'idDoc': userCollection.doc(),
      'idUser': user.idUser,
      'adress': user.adress,
      'name': user.name,
      'phone': user.phone,
      'tool': user.tool,
      'picture': user.picture,
      'idPosition': user.idPosition,
      'isManager': user.isManager,
      'isClient': user.isClient,
      'isDeliver': user.isDeliver,
      'createdAt': user.createdAt,
      'token': user.token
    });

    return documentRef.id;
  }



  //supprimer un utilisateur de la base de donnee
  Future<void> removeUser(String idUser) async {
    return userCollection
        .doc(idUser)
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }
}
