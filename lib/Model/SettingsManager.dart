import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sleeptrackerapp/Utility/LocalStore.dart';

/// A store for user settings.
class SettingsManager extends LocalStore<String>
{
  @override
  Future<String> get path
  {
    return getApplicationDocumentsDirectory().then((Directory directory) => '${directory.path}/settings.json');
  }
}