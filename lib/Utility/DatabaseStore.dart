
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class IRecord
{
  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
}


/// DatabaseStore is a generic class that can be used to store data in a database remotely.
abstract class DatabaseStore<T extends IRecord>
{
  final firebaseAuth = FirebaseAuth.instance;


  /// Gets the path to the database.
  String get databasePath;
  
  /// Gets a reference to the database.
  DatabaseReference get database => FirebaseDatabase.instance.ref().child(databasePath);

  /// Creates a new record of type [T].
  T createRecord();

  /// Adds the given data to the database.
  Future<void> addData(T data, { String? key }) async
  {
    if (key == null)
    {
      await database.push().set(data.toJson());
    }
    else
    {
      await database.child(key).set(data.toJson());
    }
  }

  /// Updates an entry in the database, finding it by a key given by the [key] parameter.
  Future<void> updateData(String key, T data) async
  {
    await database.child(key).update(data.toJson());
  }

  /// get a single entry from the database, finding it by a key given by the [key] parameter.
  Future<T?> getData(String key) async
  {
    DataSnapshot e = await database.child(key).get();
    if (e.value == null)
    {
      return null;
    }
    else
    {
      final k = Map<String, dynamic>.from(e.value as Map);
      T record = createRecord();
      record.fromJson(k);
      return record;
    }
  }

  /// get all entries from the database.
  Future<List<T>> getAllData() async
  {
    DataSnapshot e = await database.get();
    if (e.value == null)
    {
      return [];
    }
    else
    {
      Map<dynamic, dynamic> data = e.value! as Map<dynamic, dynamic>;
      List<T> records = [];
      data.forEach((key, value) {
        T record = createRecord();
        record.fromJson(value);
        records.add(record);
      });
      return records;
    }
  }

  /// get all entries from the database that match the given [query].
  Future<List<T>> getDataByQuery(Query query) async
  {
    DataSnapshot e = await query.get();
    if (e.value == null)
    {
      return [];
    }
    else
    {
      Map<dynamic, dynamic> data = e.value! as Map<dynamic, dynamic>;
      List<T> records = [];
      data.forEach((key, value) {
        T record = createRecord();
        // convert the Map<dynamic, dynamic> to a Map<String, dynamic>
        record.fromJson(Map<String, dynamic>.from(value as Map));
        records.add(record);
      });
      return records;
    }
  }

  
}