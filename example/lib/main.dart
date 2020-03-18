import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercouch/document.dart';
import 'package:fluttercouch/fluttercouch.dart';
import 'package:fluttercouch/mutable_document.dart';
import 'package:fluttercouch/query/query.dart';
import 'package:scoped_model/scoped_model.dart';

class AppModel extends Model with Fluttercouch {
  Document docExample;
  MutableDocument _doc = MutableDocument();
  Query query;

  AppModel() {
    initPlatformState();
  }

  Future<dynamic> createUser(Map map) async {
    assert(map['_id'] != null);

    assert(map['name'] != null);
    assert(map['token'] != null);
    assert(map['id'] != null);
    assert(map['active'] != null);
    assert(map['email'] != null);
    assert(map['channel'] != null);
    assert(map['createdAt'] != null);
    assert(map['updatedAt'] != null);

    Document doc = await getDocumentWithId(map['_id']);

    if (doc.toMutable().getString('email') != null) {
      MutableDocument mutableDocument = doc.toMutable();

      map.forEach((key, value) {
        if (value is int) {
          mutableDocument.setInt(key, value);
        }
        if (value is String) {
          mutableDocument.setString(key, value);
        }
        if (value is bool) {
          mutableDocument.setBoolean(key, value);
        }
        if (value is double) {
          mutableDocument.setDouble(key, value);
        }
      });
      return await saveDocumentWithId(map['_id'], mutableDocument);
    } else {
      _doc.setString('_id', map['_id']);
      _doc.setString('uid', '001');
      map.forEach((key, value) {
        if (value is int) {
          _doc.setInt(key, value);
        }
        if (value is String) {
          _doc.setString(key, value);
        }
        if (value is bool) {
          _doc.setBoolean(key, value);
        }
        if (value is double) {
          _doc.setDouble(key, value);
        }
      });
      return await saveDocumentWithId(map['_id'], _doc);
    }
  }

  Future<dynamic> createBusiness(Map map) async {
    assert(map['_id'] != null);
    Document doc = await getDocumentWithId(map['_id']);

    assert(map['name'] != null);
    assert(map['active'] != null);
    assert(map['businessCategoryId'] != null);
    assert(map['businessTypeId'] != null);
    assert(map['businessUrl'] != null);
    assert(map['country'] != null);
    assert(map['currency'] != null);
    assert(map['id'] != null);
    assert(map['taxRate'] != null);
    assert(map['timeZone'] != null);
    assert(map['createdAt'] != null);
    assert(map['updatedAt'] != null);
    assert(map['userId'] != null);

    List m = [map];
    doc.toMutable().setList(map['_id'], m);
    return await saveDocumentWithId(map['_id'], doc);
  }

  //create a branch
  Future<dynamic> createBranch(Map map) async {
    assert(map['_id'] != null);
    assert(map['name'] != null);
    assert(map['active'] != null);
    assert(map['businessId'] != null);
    assert(map['mapLatitude'] != null);
    assert(map['mapLongitude'] != null);
    assert(map['id'] != null);
    assert(map['updatedAt'] != null);
    assert(map['createdAt'] != null);
    assert(map['_id'] != null);

    Document doc = await getDocumentWithId(map['_id']);

    List m = [map];

    doc.toMutable().setList(map['_id'], m).setString('uid', '0024');
    return await saveDocumentWithId(map['_id'], doc);
  }

  initPlatformState() async {
    try {
      await initDatabaseWithName("lagrace");

      // todo: enable this sync replication when user has paid.
      setReplicatorEndpoint("ws://enexus.rw:4984/lagrace");
      setReplicatorType("PUSH_AND_PULL");
      setReplicatorBasicAuthentication(<String, String>{
        "username": "Administrator",
        "password": "password"
      });
      setChannel('1');
      setReplicatorContinuous(true);
      initReplicator();
      startReplicator();

      String userId = '001';
      Map mapUser = {
        'active': true,
        '_id': 'user_1',
        'id': userId,
        'channel': 1,
        'name': 'richiezo', //remove any white space from string
        'token': 'token',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'email': 'richie@yegobox.com'
      };

      //create a user
      await createUser(mapUser);

      //create his business
      String businessId = '002';
      Map _mapBusiness = {
        'active': true,
        '_id': 'business_1',
        'businessCategoryId': 1,
        'businessTypeId': 1,
        'businessUrl': '',
        'country': 'Rwanda',
        'currency': 'RWF',
        'id': businessId,
        'name': 'yegobox',
        'taxRate': 18,
        'timeZone': '',
        'userId': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      //create a business
      await createBusiness(_mapBusiness);

      Map _mapBranch = {
        'active': true,
        'name': 'yegobox',
        '_id': 'branch_1',
        'businessId': 002,
        'id': 1,
        'mapLatitude': 0.0,
        'mapLongitude': 0.0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      //create a branch
      await createBranch(_mapBranch);

      // Query query = QueryBuilder.select([SelectResult.all()])
      //     .from("lagrace")
      //     .where(
      //         Expression.property("_id").equalTo(Expression.string("users")));
      // ResultSet resultset = await query.execute();

      // resultset.allResults().forEach((element) {
      //   for (var i = 0; i < element.toList().length; i++) {
      //     element
      //         .toList()[i]['users']
      //         .forEach((element) => {print(element['name'])});
      //   }
      // });

      notifyListeners();
    } on PlatformException {}
  }
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Fluttercouch example application',
        home: ScopedModel<AppModel>(
          model: AppModel(),
          child: Home(),
        ));
  }
}

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Fluttercouch example application'),
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            Text("This is an example app"),
            ScopedModelDescendant<AppModel>(
              builder: (context, child, model) => new Text(
                'Ciao',
                style: Theme.of(context).textTheme.display1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
