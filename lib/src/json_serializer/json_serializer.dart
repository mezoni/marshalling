part of '../../json_serializer.dart';

class JsonSerializer extends Marshaller {
  bool _debug = false;

  void debug() {
    _debug = true;
  }

  @override
  dynamic marshal<T>(T value, {Type type}) {
    if (type == null) {
      type = T;
      if (type == dynamic) {
        type = value.runtimeType;
      }
    }

    var path = const <String>[];
    if (_debug) {
      path = ['${type}'];
    }

    return _marshal(value, type, path);
  }

  @override
  T unmarshal<T>(dynamic value, {Type type}) {
    if (type == null) {
      type = T;
      if (type == dynamic) {
        type = value.runtimeType as Type;
      }
    }

    var path = const <String>[];
    if (_debug) {
      path = ['${type}'];
    }

    return _unmarshal(value, type, path) as T;
  }

  void _error(String message, List<String> path) {
    var p = _pathToString(path);
    if (p.isNotEmpty) {
      message += ': ${p}';
    }

    throw MarshallingError(message);
  }

  void _errorExpectedValueOfType(Type type, List<String> path) {
    _error('Expected value of type \'$type\'', path);
  }

  List<String> _makePath(List<String> path, {String key, int index}) {
    if (!_debug) {
      return path;
    }

    var result = path.toList();
    if (key != null) {
      result.add(key);
    }

    if (index != null) {
      if (result.isNotEmpty) {
        result.last += '[$index]';
      } else {
        result.add('[$index]');
      }
    }

    return result;
  }

  dynamic _marshal(dynamic value, Type type, List<String> path) {
    if (value == null) {
      return value;
    }

    if (value is bool) {
      return value;
    }

    if (value is double) {
      if (type == String) {
        return value.toString();
      }

      return value;
    }

    if (value is int) {
      if (type == String) {
        return value.toString();
      }

      return value;
    }

    if (value is String) {
      if (type == int) {
        return int.parse(value);
      }

      if (type == double) {
        return double.parse(value);
      }

      return value;
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    var typeInfo = types[type];
    if (typeInfo is MapTypeInfo) {
      var valueType = typeInfo.valueType;
      if (value is Map) {
        var result = {};
        for (var key in value.keys) {
          result[key] = _marshal(
              value[key], valueType, _makePath(path, key: key.toString()));
        }

        return result;
      } else {
        _errorExpectedValueOfType(Map, path);
      }
    }

    if (typeInfo is IterableTypeInfo) {
      var elementType = typeInfo.elementType;
      if (value is Iterable) {
        var result = [];
        if (result is List) {
          var index = 0;
          for (var element in value) {
            result.add(_marshal(
                element, elementType, _makePath(path, index: index++)));
          }
        } else {
          _errorExpectedValueOfType(List, path);
        }

        return result;
      } else {
        _errorExpectedValueOfType(Iterable, path);
      }
    }

    if (value is Map) {
      var result = {};
      for (var key in value.keys) {
        var k = key.toString();
        var v = value[key];
        var t = v.runtimeType as Type;
        result[k] = _marshal(v, t, _makePath(path, key: k));
      }

      return result;
    }

    if (value is Iterable) {
      var result = [];
      var index = 0;
      for (var element in value) {
        var t = element.runtimeType as Type;
        result.add(_marshal(element, t, _makePath(path, index: index++)));
      }

      return result;
    }

    if (typeInfo == null) {
      _error('Unable to marshal value of type \'$type\'', path);
      return null;
    }

    var result = <String, dynamic>{};
    for (var property in typeInfo.properties.values) {
      var name = property.name;
      var alias = property.alias;
      if (alias == null) {
        alias = name;
      }

      var acesssor = accessors[name];
      var v = acesssor.read(value);
      result[alias] = _marshal(v, property.type, _makePath(path, key: alias));
    }

    return result;
  }

  String _pathToString(List<String> path) {
    return path.join('.');
  }

  dynamic _unmarshal(dynamic value, Type type, List<String> path) {
    if (value == null) {
      return value;
    }

    if (value is String) {
      if (type == DateTime) {
        return DateTime.parse(value);
      }

      if (type == int) {
        return int.parse(value);
      }

      if (type == double) {
        return double.parse(value);
      }

      return value;
    }

    if (value is int) {
      if (type == double) {
        return value.toDouble();
      }

      if (type == String) {
        return value.toString();
      }

      return value;
    }

    if (value is double) {
      if (type == String) {
        return value.toString();
      }

      return value;
    }

    if (value is bool) {
      return value;
    }

    if (value is DateTime) {
      return value;
    }

    var typeInfo = types[type];
    if (typeInfo is MapTypeInfo) {
      var valueType = typeInfo.valueType;
      var result = typeInfo.construct();
      if (result is Map) {
        if (value is Map) {
          for (var key in value.keys) {
            var k = key.toString();
            result[k] =
                _unmarshal(value[key], valueType, _makePath(path, key: k));
          }

          return result;
        } else {
          _errorExpectedValueOfType(Map, path);
          return null;
        }
      } else {
        _errorExpectedValueOfType(Map, path);
        return null;
      }
    }

    if (typeInfo is IterableTypeInfo) {
      var elementType = typeInfo.elementType;
      var result = typeInfo.construct();
      if (result is List) {
        if (value is Iterable) {
          var index = 0;
          for (var element in value) {
            result.add(_unmarshal(
                element, elementType, _makePath(path, index: index++)));
          }

          return result;
        } else {
          _errorExpectedValueOfType(Iterable, path);
          return null;
        }
      } else {
        _errorExpectedValueOfType(List, path);
        return null;
      }
    }

    if (typeInfo != null) {
      if (value is Map) {
        var result = typeInfo.construct();
        for (var property in typeInfo.properties.values) {
          var name = property.name;
          var alias = property.alias;
          if (alias == null) {
            alias = name;
          }

          if (value.containsKey(alias)) {
            var accessor = accessors[name];
            var val = _unmarshal(
                value[alias], property.type, _makePath(path, key: alias));
            try {
              accessor.write(result, val);
            } catch (e) {
              var t = value[alias].runtimeType;
              _error('Unable to write value of type \'${t}\'',
                  _makePath(path, key: alias));
            }
          }
        }

        return result;
      } else {
        _errorExpectedValueOfType(Map, path);
        return null;
      }
    }

    if (value is Iterable) {
      var result = [];
      var index = 0;
      for (var element in value) {
        var t = element.runtimeType as Type;
        result.add(_unmarshal(element, t, _makePath(path, index: index++)));
      }

      return result;
    }

    if (value is Map) {
      var result = {};
      for (var key in value.keys) {
        var v = value[key];
        var t = v.runtimeType as Type;
        result[key] = _unmarshal(v, t, _makePath(path, key: key.toString()));
      }

      return result;
    }

    _error('Expected value of type \'$type\'', path);
    return null;
  }
}
