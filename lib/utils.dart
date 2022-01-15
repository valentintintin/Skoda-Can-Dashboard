import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getNewFileName(String fileName) async {
  Directory directory = await getDirectory();
  return directory.path + '/' + fileName + '_' + (directory.listSync(recursive: false).where((element) => element.path.contains(fileName)).length + 1).toString();
}

Future<Directory> getDirectory() async {
  Directory directory = Directory.current;
  
  if (Platform.isLinux) {
    return directory;
  }
  
  return (await getExternalStorageDirectory()) ?? directory;
}

Future<String> getStringFromAssets(String assetKey) async {
  return await rootBundle.loadString(assetKey);
}
