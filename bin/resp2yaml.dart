import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as _path;

// Experimental
void main(List<String> args) {
  var argParser = ArgParser();
  argParser.addFlag('help',
      defaultsTo: false, help: 'Displays help information');
  ArgResults argResults;
  void usage() {
    print('Usage: resp2yaml [options] path/to/resposnse.json');
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

  if (argResults.rest.length != 1) {
    usage();
    print('Missing json request data file name');
    exit(0);
  }

  var inputFileName = argResults.rest[0];
  var inputFile = File(inputFileName);
  var data = inputFile.readAsStringSync();
  var source = jsonDecode(data);
  var className = _path.basenameWithoutExtension(inputFileName);
  if (className.contains('_')) {
    className = camelize(className);
  }

  className = className[0].toUpperCase() + className.substring(1);
  var generator = Resp2YamlGenerator(source, className);
  var lines = generator.generate();
  var dirName = _path.dirname(inputFileName);
  var outputFileName = _path.basenameWithoutExtension(inputFileName);
  outputFileName = _path.join(dirName, outputFileName + '.yaml');
  var outputFile = File(outputFileName);
  outputFile.writeAsStringSync(lines.join('\n'));
}

bool alpha(int c) {
  if (c >= 65 && c <= 90 || c >= 97 && c <= 122) {
    return true;
  }

  return false;
}

bool alphanum(int c) {
  if (c >= 48 && c <= 57 || c >= 65 && c <= 90 || c >= 97 && c <= 122) {
    return true;
  }

  return false;
}

String camelize(String string, {bool lower = false}) {
  if (string.isEmpty) {
    return string;
  }

  string = string.toLowerCase();
  var capitlize = true;
  var length = string.length;
  var position = 0;
  var remove = false;
  var sb = new StringBuffer();
  for (var i = 0; i < length; i++) {
    var s = string[i];
    var c = s.codeUnitAt(0);
    if (capitlize && alpha(c)) {
      if (lower && position == 0) {
        sb.write(s);
      } else {
        sb.write(s.toUpperCase());
      }

      capitlize = false;
      remove = true;
      position++;
    } else {
      if (c == 95) {
        if (!remove) {
          sb.write(s);
          remove = true;
        }

        capitlize = true;
      } else {
        if (alphanum(c)) {
          capitlize = false;
          remove = true;
        } else {
          capitlize = true;
          remove = false;
          position = 0;
        }

        sb.write(s);
      }
    }
  }

  return sb.toString();
}

class Resp2YamlGenerator {
  static const String _unknownTypeName = 'Object';

  Map<String, Map<String, Set<String>>> _classes = {};

  String _className;

  dynamic _source;

  Resp2YamlGenerator(dynamic source, String className) {
    _className = className;
    _source = source;
  }

  List<String> generate() {
    _reset();
    if (_source is Map || _source is List) {
      _analyze(_source, [_className]);
    } else {
      throw StateError('Unsupported response type: ${_source.runtimeType}');
    }

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
    var className = _getClassName(path);
    var class_ = _classes[className];
    if (class_ == null) {
      class_ = {};
      _classes[className] = class_;
    }

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

  String _getClassName(List<String> path) {
    var list = <String>[];
    for (var part in path) {
      if (part.contains('_')) {
        part = camelize(part);
      } else {
        part = part[0].toUpperCase() + part.substring(1);
      }

      list.add(part);
    }

    return list.join('');
  }

  String _pathToString(List<String> path) {
    return path.join('.');
  }

  void _reset() {
    //
  }
}
