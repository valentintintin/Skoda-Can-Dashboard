import 'dart:io';

String getNewFileName(String fileName, { String directory = '.' }) {
  return fileName + '_' + (Directory(directory).listSync(recursive: false).where((element) => element.path.contains(fileName)).length + 1).toString();
}