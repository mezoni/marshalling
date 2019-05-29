import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as _path;

import '_utils.dart' as _utils;

void main(List<String> args) {
  var argParser = ArgParser();
  argParser.addFlag('help',
      defaultsTo: false, help: 'Displays help information');
  argParser.addOption('out', help: 'Output file name');
  ArgResults argResults;
  void usage() {
    print('Usage: resp2yaml [options] path/to/resposnse.json');
  }

  void error(String message) {
    usage();
    print(message);
    exit(0);
  }

  try {
    argResults = argParser.parse(args);
  } on FormatException {
    usage();
    exit(-1);
  }

  if (argResults['help'] as bool) {
    usage();
    print(argParser.usage);
    exit(0);
  }

  if (argResults.rest.isEmpty) {
    error('Missing json request data file name(s)');
  }

  String outputFullPath;
  var fileNames = argResults.rest;
  if (fileNames.length > 1) {
    outputFullPath = argResults['out'] as String;
    if (outputFullPath == null) {
      error('Missing output file name');
    }
  } else {
    var inputFileName = fileNames[0];
    var outputFileName = _path.basenameWithoutExtension(inputFileName);
    var dirName = _path.dirname(inputFileName);
    outputFullPath = _path.join(dirName, outputFileName + '.yaml');
  }

  var lines = <String>[];
  for (var fileName in fileNames) {
    var inputFile = File(fileName);
    var text = inputFile.readAsStringSync();
    var jsonObject = jsonDecode(text);
    var generator = Resp2YamlGenerator();
    var name = _path.basenameWithoutExtension(fileName);
    lines.add('# ${fileName}');
    var result = generator.generate(jsonObject, [name]);
    lines.addAll(result);
  }

  var outputFile = File(outputFullPath);
  outputFile.writeAsStringSync(lines.join('\n'));
}

class Resp2YamlGenerator {
  static const String _unknownTypeName = 'Object';

  Map<String, Map<String, Set<String>>> _classes = {};

  List<String> generate(dynamic jsonObject, List<String> path) {
    _analyze(jsonObject, path);
    var lines = <String>[];
    for (var className in _classes.keys) {
      lines.add('${className}:');
      var class_ = _classes[className];
      for (var key in class_.keys) {
        var typeUnion = class_[key];
        var typeName = _reduceTypeUnion(typeUnion);
        lines.add('  ${key}: ${typeName}');
      }

      lines.add('');
    }

    return lines;
  }

  String _analyze(dynamic value, List<String> path) {
    if (value is Map) {
      return _analyzeMap(value, path);
    } else if (value is List) {
      return _analyzeList(value, path);
    } else if (value is bool) {
      return 'bool';
    } else if (value is DateTime) {
      return 'DateTime';
    } else if (value is double) {
      return 'double';
    } else if (value is int) {
      return 'int';
    } else if (value is String) {
      var date;
      try {
        date = DateTime.parse(value);
      } on FormatException {
        //
      }

      if (date != null) {
        return 'DateTime';
      }

      return 'String';
    } else if (value == null) {
      return _unknownTypeName;
    } else {
      throw StateError(
          'Unsupported data type: ${value.runtimeType}: ${_pathToString(path)}');
    }
  }

  String _analyzeList(List list, List<String> path) {
    if (list.isEmpty) {
      return 'List<${_unknownTypeName}>';
    }

    var typeUnion = Set<String>();
    for (var element in list) {
      var typeName = _analyze(element, path);
      typeUnion.add(typeName);
    }

    var typeName = _reduceTypeUnion(typeUnion);
    return 'List<${typeName}>';
  }

  String _analyzeMap(Map map, List<String> path) {
    var className = _registerClass(path);
    var class_ = _classes[className];
    for (var key in map.keys) {
      var newkey = key.toString();
      var value = map[key];
      var newPath = path.toList()..add(newkey);
      var typeName = _analyze(value, newPath);
      var typeUnion = class_[newkey];
      if (typeUnion == null) {
        typeUnion = Set<String>();
        class_[newkey] = typeUnion;
      }

      typeUnion.add(typeName);
    }

    return className;
  }

  String _pathToString(List<String> path) {
    return path.join('.');
  }

  String _reduceTypeUnion(Set<String> typeUnion) {
    if (typeUnion.isEmpty) {
      throw StateError('Internal error');
    }

    if (typeUnion.length == 1) {
      return typeUnion.first;
    }

    if (typeUnion.length == 2) {
      if (typeUnion.contains(_unknownTypeName)) {
        return typeUnion.where((e) => e != _unknownTypeName).first;
      }
    }

    return _unknownTypeName;
  }

  String _registerClass(List<String> path) {
    var parts = <String>[];
    for (var part in path) {
      part = _utils.convertToIdentifier(part, '\$');
      part = _utils.makePublicIdentifier(part, 'Anon');
      part = _utils.camelizeIdentifier(part);
      part = _utils.capitalizeIdentifier(part);
      parts.add(part);
    }

    var result = parts.join();
    result = _utils.convertToIdentifier(result, '\$');
    result = _utils.makePublicIdentifier(result, 'Anon');
    result = _utils.camelizeIdentifier(result);
    result = _utils.capitalizeIdentifier(result);
    if (_classes.containsKey(result)) {
      while (true) {
        result += '_';
        if (!_classes.containsKey(result)) {
          break;
        }
      }
    }

    _classes[result] = {};
    return result;
  }
}
