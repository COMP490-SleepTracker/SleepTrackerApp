import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';

/// An abstract class that defines the interface for a store.
/// Accessed synchronously, must be initialized before use.
abstract class IStore<T> extends ChangeNotifier
{
  /// Returns the value associated with the given key.
  T? getValue(String key);

  /// Sets the value associated with the given key.
  void setValue(String key, T value);

  /// Removes the value associated with the given key.
  void removeValue(String key);

  /// Removes all values from the store.
  void clear();

  /// Returns true if the store contains a value associated with the given key.
  bool containsKey(String key);

  /// Returns a list of all keys in the store.
  List<String> getKeys();
}

/// An abstract class that defines the interface for a store, accessed asynchronously.
/// Accessed asynchronously, does not need to be initialized before use.
abstract class AsyncIStore<T> extends ChangeNotifier
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

abstract class LocalStore<T> extends IStore<T>
{
  /// Returns the path to the store.
  Future<String> get path;

  @override
  T? getValue(String key)
  {
    _load();
    return _values[key];
  }

  @override
  void setValue(String key, T value)
  {
    _values[key] = value;
    _save();
  }

  @override
  void removeValue(String key)
  {
    _values.remove(key);
    _save();
  }

  @override
  void clear()
  {
    _values.clear();
    _save();
  }

  @override
  bool containsKey(String key)
  {
    return _values.containsKey(key);
  }

  @override
  List<String> getKeys()
  {
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
    File file = File(await path);
    String contents = json.encode(_values);
    file.writeAsStringSync(contents);
    notifyListeners();
  }

  Future<void> init()
  {
    return _load();
  }

  /// Dictionary of values.
  Map<String, T> _values = {};
}

/// A store that uses the local file system to persist data.
abstract class AsyncLocalStore<T> extends AsyncIStore<T>
{
  /// Returns the path to the store.
  Future<String> get path;

  bool _isInitialized = false;

  @override
  Future<T?> getValue(String key) async
  {
    if (!_isInitialized)
    {
      await _load();
      _isInitialized = true;
    }
    return _values[key];
  }

  @override
  Future<void> setValue(String key, T value) async
  {
    if(!_isInitialized)
    {
      await _load();
      _isInitialized = true;
    }

    _values[key] = value;
    await _save();
  }

  @override
  Future<void> removeValue(String key) async
  {
    if(!_isInitialized)
    {
      await _load();
      _isInitialized = true;
    }

    _values.remove(key);
    await _save();
  }

  @override
  Future<void> clear() async
  {
    if(!_isInitialized)
    {
      await _load();
      _isInitialized = true;
    }
    _values.clear();
    await _save();
  }

  @override
  Future<bool> containsKey(String key) async
  {
    if(!_isInitialized)
    {
      await _load();
      _isInitialized = true;
    }
    return _values.containsKey(key);
  }

  @override
  Future<List<String>> getKeys() async
  {
    if(!_isInitialized)
    {
      await _load();
      _isInitialized = true;
    }
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