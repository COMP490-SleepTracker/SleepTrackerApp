import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';

/// An abstract class that defines the interface for a store.
abstract class IStore<T> extends ChangeNotifier
{
  /// Returns the value associated with the given key.
  Future<T?> getValue(String key);

  /// Sets the value associated with the given key.
  Future<void> setValue(String key, T value);

  /// Removes the value associated with the given key.
  Future<void> removeValue(String key);

  /// Removes all values from the store.
  Future<void> clear();

  /// Returns true if the store contains a value associated with the given key.
  Future<bool> containsKey(String key);

  /// Returns a list of all keys in the store.
  Future<List<String>> getKeys();
}

/// A store that uses the local file system to persist data.
abstract class LocalStore<T> extends IStore<T>
{
  /// Returns the path to the store.
  Future<String> get path;

  LocalStore()
  {
    _load();
  }

  @override
  Future<T?> getValue(String key) async
  {
    await _load();
    return _values[key];
  }

  @override
  Future<void> setValue(String key, T value) async
  {
    await _load();
    _values[key] = value;
    await _save();
  }

  @override
  Future<void> removeValue(String key) async
  {
    await _load();
    _values.remove(key);
    await _save();
  }

  @override
  Future<void> clear() async
  {
    await _load();
    _values.clear();
    await _save();
  }

  @override
  Future<bool> containsKey(String key) async
  {
    await _load();
    return _values.containsKey(key);
  }

  @override
  Future<List<String>> getKeys() async
  {
    await _load();
    return _values.keys.toList();
  }

  /// Loads the values from the file system. We store the values in a JSON file.
  Future<void> _load() async
  {
    String fileStorePath = await path;
    File file = File(fileStorePath);

    if (await file.exists())
    {
      String contents = await file.readAsString();
      _values = Map<String, T>.from(json.decode(contents));
    }
    else
    {
      _values = {};
    } 
  }

  /// Saves the values to the file system. We store the values in a JSON file.
  Future<void> _save() async
  {
    String fileStorePath = await path;
    File file = File(fileStorePath);
    String contents = json.encode(_values);
    await file.writeAsString(contents);
    notifyListeners();
  }

  /// Dictionary of values.
  Map<String, T> _values = {};
}