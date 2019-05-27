import 'dart:io';

import 'package:path/path.dart' as _path;
import 'package:args/args.dart';
import 'package:yaml/yaml.dart' as yaml;

// Experimental
void main(List<String> args) {
  var argParser = ArgParser();
  argParser.addFlag('camelize',
      defaultsTo: true, help: 'Allows caramelization of property names');
  argParser.addFlag('help',
      defaultsTo: false, help: 'Displays help information');
  ArgResults argResults;
  void usage() {
    print('Usage: yaml2podo [options] path/to/json/objects.yaml');
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
    print('Missing json objects prototype file name');
    exit(0);
  }

  var camelize = argResults['camelize'] as bool;
  var inputFileName = argResults.rest[0];
  var inputFile = File(inputFileName);
  var data = inputFile.readAsStringSync();
  var source = yaml.loadYaml(data);
  var generator = PrototypingGenerator(source as Map, camelize: camelize);
  var lines = generator.generate();
  var dirName = _path.dirname(inputFileName);
  var outputFileName = _path.basenameWithoutExtension(inputFileName);
  outputFileName = _path.join(dirName, outputFileName + '.dart');
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

class PrototypingGenerator {
  bool _camelize;

  Map<String, _TypeInfo> _classes;

  _TypeInfo _dynamicType;

  Map<String, _TypeInfo> _primitiveTypes;

  Map _source;

  Map<String, _TypeInfo> _types;

  PrototypingGenerator(Map source, {bool camelize = false}) {
    if (source == null) {
      throw ArgumentError.notNull('source');
    }

    _camelize = camelize;
    _source = source;
  }

  List<String> generate() {
    _reset();
    for (var key in _source.keys) {
      var name = key.toString();
      var class_ = _parseTypeName(name);
      if (class_.typeArgs.isNotEmpty) {
        throw StateError('Generic types are not supported: ${class_.typeArgs}');
      }

      if (_classes.containsKey(class_.fullName)) {
        throw StateError('Duplicate type name: ${class_.fullName}');
      }

      if (class_.kind != _TypeKind.object) {
        throw StateError('Unable to generate class: ${class_.fullName}');
      }

      _classes[class_.fullName] = class_;
      var props = _source[key] as Map;
      if (props == null) {
        throw StateError(
            'Object type declaration must contain properties: ${class_}');
      }

      _parseProps(class_, props);
    }

    for (var class_ in _classes.values) {
      for (var prop in class_.props.values) {
        var propType = prop.type;
        void walkTypes(_TypeInfo type) {
          if (_types.containsKey(type.fullName)) {
            return;
          }

          for (var typeArg in type.typeArgs) {
            walkTypes(typeArg);
          }

          switch (type.kind) {
            case _TypeKind.iterable:
            case _TypeKind.list:
            case _TypeKind.map:
              _types[type.fullName] = type;
              break;
            case _TypeKind.object:
              if (!_classes.containsKey(type.fullName)) {
                throw StateError('Unknown type: ${type}');
              }

              break;
            default:
              break;
          }
        }

        switch (propType.kind) {
          case _TypeKind.bottom:
            break;
          case _TypeKind.iterable:
          case _TypeKind.list:
          case _TypeKind.map:
            walkTypes(propType);
            break;
          case _TypeKind.object:
            if (!_classes.containsKey(propType.fullName)) {
              throw StateError('Unknown property type: ${propType}');
            }

            break;
          case _TypeKind.primitive:
            break;
          default:
            throw StateError('Unsupported property type: ${propType}');
        }
      }
    }

    var accessors = Set<String>();
    var classes = _classes.values.toList();
    classes.sort((e1, e2) => e1.fullName.compareTo(e2.fullName));
    var lines = <String>[];
    lines.add(
        '// Generated by the \'yaml2podo\' tool, https://pub.dev/packages/marshalling');
    lines.add('');
    lines.add('import \'package:marshalling/json_serializer.dart\';');
    lines.add('');
    lines.add('final json = JsonSerializer()');
    for (var class_ in classes) {
      var className = class_.fullName;
      lines.add('  ..addType(() => ${className}())');
      for (var prop in class_.props.values) {
        accessors.add(prop.name);
      }
    }

    for (var type in _types.values) {
      var typeName = type.fullName;
      var typeArgs = type.typeArgs;
      switch (type.kind) {
        case _TypeKind.iterable:
        case _TypeKind.list:
          var typeArg0 = typeArgs[0].fullName;
          lines.add(
              '  ..addIterableType<${typeName}, ${typeArg0}>(() => <${typeArg0}>[])');
          break;
        case _TypeKind.map:
          var typeArg0 = typeArgs[0].fullName;
          var typeArg1 = typeArgs[1].fullName;
          lines.add(
              '  ..addMapType<${typeName}, ${typeArg0}, ${typeArg1}>(() => <${typeArg0}, ${typeArg1}>{})');
          break;
        default:
          throw StateError('Internal error');
          break;
      }
    }

    for (var name in accessors.toList()..sort()) {
      lines.add(
          '  ..addAccessor(\'${name}\', (o) => o.${name}, (o, v) => o.${name} = v)');
    }

    for (var class_ in classes) {
      var className = class_.fullName;
      for (var prop in class_.props.values) {
        var propName = prop.name;
        var propType = prop.type.fullName;
        var alias = '';
        if (prop.alias != null) {
          alias = ', alias: \'${prop.alias}\'';
        }

        lines.add(
            '  ..addProperty<${className}, ${propType}>(\'${propName}\'${alias})');
      }
    }

    lines.last = lines.last + ';';
    lines.add('');
    for (var class_ in classes) {
      var className = class_.fullName;
      lines.add('class ${className} {');
      for (var prop in class_.props.values) {
        var propTypeName = prop.type.fullName;
        var propName = prop.name;
        lines.add('  ${propTypeName} ${propName};');
      }

      lines.add('');
      lines.add('  ${className}();');
      lines.add('');
      lines.add('  factory ${className}.fromJson(Map map) {');
      lines.add('    return json.unmarshal<${className}>(map);');
      lines.add('  }');
      lines.add('');
      lines.add('  Map<String, dynamic> toJson() {');
      lines.add('    return json.marshal(this) as Map<String, dynamic>;');
      lines.add('  }');
      lines.add('}');
      lines.add('');
    }

    return lines;
  }

  void _analyzeType(_TypeInfo type) {
    var typeArgs = type.typeArgs;
    for (var typeArg in typeArgs) {
      _analyzeType(typeArg);
    }

    void checkTypeArgsCount(List<_TypeInfo> args) {
      if (typeArgs.isEmpty) {
        typeArgs.addAll(args);
        return;
      }

      if (typeArgs.length != args.length) {
        throw StateError('Wrong number of type arguments: $type');
      }
    }

    _TypeKind kind;
    switch (type.simpleName) {
      case 'dynamic':
        checkTypeArgsCount([]);
        kind = _TypeKind.bottom;
        break;
      case 'bool':
      case 'DateTime':
      case 'double':
      case 'int':
      case 'num':
      case 'String':
        checkTypeArgsCount([]);
        kind = _TypeKind.primitive;
        break;
      case 'Iterable':
        checkTypeArgsCount([_dynamicType]);
        kind = _TypeKind.iterable;
        break;
      case 'List':
        checkTypeArgsCount([_dynamicType]);
        kind = _TypeKind.list;
        break;
      case 'Map':
        checkTypeArgsCount([_primitiveTypes['String'], _dynamicType]);
        kind = _TypeKind.map;
        break;
      default:
        if (typeArgs.isEmpty) {
          kind = _TypeKind.object;
        } else {
          kind = _TypeKind.unknown;
        }
    }

    type.kind = kind;
  }

  void _checkValidIdentifier(String name) {
    void error(int offset) {
      throw FormatException('Invalid identifier', name, offset);
    }

    var c = name.codeUnitAt(0);
    if (!(alpha(c) || c == 95)) {
      error(0);
    }

    for (var i = 1; i < name.length; i++) {
      var c = name.codeUnitAt(i);
      if (!(alphanum(c) || c == 95)) {
        error(i);
      }
    }
  }

  _TypeInfo _createDynmaicType() {
    var result = _TypeInfo();
    result.fullName = "dynamic";
    result.kind = _TypeKind.bottom;
    result.simpleName = "dynamic";
    return result;
  }

  _TypeInfo _createPrimitiveType(String name) {
    var result = _TypeInfo();
    result.fullName = name;
    result.kind = _TypeKind.primitive;
    result.simpleName = name;
    return result;
  }

  void _parseProps(_TypeInfo type, Map data) {
    var props = <String, _PropInfo>{};
    for (var key in data.keys) {
      var nameParts = key.toString().trim().split('.');
      var name = nameParts[0].trim();
      _checkValidIdentifier(name);
      var alias = name;
      if (nameParts.length > 1) {
        alias = nameParts[1].trim();
        _checkValidIdentifier(alias);
      }

      if (_camelize && name.contains('_')) {
        var camelizedName = camelize(name, lower: true);
        if (name != camelizedName) {
          name = camelizedName;
        }
      }

      if (alias == name) {
        alias = null;
      }

      var typeName = data[key].toString();
      var type = _parseTypeName(typeName);
      var prop = _PropInfo();
      prop.alias = alias;
      prop.name = name;
      prop.type = type;
      props[name] = prop;
    }

    type.props.addAll(props);
  }

  _TypeInfo _parseTypeName(String name) {
    var parser = _TypeParser();
    var type = parser.parse(name);
    _analyzeType(type);
    return type;
  }

  void _reset() {
    _dynamicType = _createDynmaicType();
    _classes = {};
    _types = {};
    _primitiveTypes = {};
    var names = ['bool', 'DateTime', 'double', 'int', 'num', 'String'];
    for (var name in names) {
      _primitiveTypes[name] = _createPrimitiveType(name);
    }
  }
}

class _PropInfo {
  String alias;
  String name;
  _TypeInfo type;

  @override
  String toString() => '$type $name';
}

class _Token {
  _TokenKind kind;
  int start;
  String text;

  @override
  String toString() => text;
}

enum _TokenKind { close, comma, eof, ident, open }

class _TypeInfo {
  String fullName;
  _TypeKind kind;
  Map<String, _PropInfo> props = {};
  String simpleName;
  List<_TypeInfo> typeArgs = [];

  @override
  String toString() => '$fullName';
}

enum _TypeKind { bottom, iterable, list, map, object, primitive, unknown }

class _TypeParser {
  String _source;

  _Token _token;

  List<_Token> _tokens;

  int _pos;

  _TypeInfo parse(String source) {
    _source = source;
    var tokenizer = _TypeTokenizer();
    _tokens = tokenizer.tokenize(source);
    _reset();

    return _parseType();
  }

  void _match(_TokenKind kind) {
    if (_token.kind == kind) {
      _nextToken();
      return;
    }

    throw FormatException('Invalid type', _source, _token.start);
  }

  _Token _nextToken() {
    if (_pos + 1 < _tokens.length) {
      _token = _tokens[++_pos];
    }

    return _token;
  }

  List<_TypeInfo> _parseArgs() {
    var result = <_TypeInfo>[];
    var type = _parseType();
    result.add(type);
    while (true) {
      if (_token.kind != _TokenKind.comma) {
        break;
      }

      _nextToken();
      var type = _parseType();
      result.add(type);
    }

    return result;
  }

  _TypeInfo _parseType() {
    var simpleName = _token.text;
    _match(_TokenKind.ident);
    var args = <_TypeInfo>[];
    if (_token.kind == _TokenKind.open) {
      _nextToken();
      args = _parseArgs();
      _match(_TokenKind.close);
    }

    var result = _TypeInfo();
    result.simpleName = simpleName;
    result.fullName = simpleName;
    if (args.isNotEmpty) {
      var sb = StringBuffer();
      sb.write(simpleName);
      sb.write('<');
      sb.write(args.join(', '));
      sb.write('>');
      result.fullName = sb.toString();
    }

    result.typeArgs.addAll(args);
    return result;
  }

  void _reset() {
    _pos = 0;
    _token = _tokens[0];
  }
}

class _TypeTokenizer {
  static const _eof = 0;

  int _ch;

  int _pos;

  String _source;

  List<_Token> tokenize(String source) {
    _source = source;
    var tokens = <_Token>[];
    _reset();
    while (true) {
      _white();
      String text;
      _TokenKind kind;
      if (_ch == _eof) {
        kind = _TokenKind.eof;
        text = '';
        break;
      }

      var start = _pos;
      switch (_ch) {
        case 44:
          text = ',';
          kind = _TokenKind.comma;
          _nextCh();
          break;
        case 60:
          text = '<';
          kind = _TokenKind.open;
          _nextCh();
          break;
        case 62:
          text = '>';
          kind = _TokenKind.close;
          _nextCh();
          break;
        default:
          if (alpha(_ch)) {
            var length = 1;
            _nextCh();
            while (alphanum(_ch)) {
              length++;
              _nextCh();
            }

            text = source.substring(start, start + length);
            kind = _TokenKind.ident;
          } else {
            throw FormatException('Invalid type', source, start);
          }
      }

      var token = _Token();
      token.kind = kind;
      token.start = start;
      token.text = text;
      tokens.add(token);
    }

    return tokens;
  }

  int _nextCh() {
    if (_pos + 1 < _source.length) {
      _ch = _source.codeUnitAt(++_pos);
    } else {
      _ch = _eof;
    }

    return _ch;
  }

  void _reset() {
    _pos = 0;
    _ch = _eof;
    if (_source.isNotEmpty) {
      _ch = _source.codeUnitAt(0);
    }
  }

  void _white() {
    while (true) {
      if (_ch == 32) {
        _nextCh();
      } else {
        break;
      }
    }
  }
}
