part of '../../json_serializer.dart';

class JsonSerializer extends Marshaller {
  @override
  dynamic marshal<T>(T value, {Type type}) {
    if (type == null) {
      type = T;
      if (type == dynamic) {
        type = value.runtimeType;
      }
    }

    return _marshal(value, type);
  }

  @override
  T unmarshal<T>(dynamic value, {Type type}) {
    if (type == null) {
      type = T;
      if (type == dynamic) {
        type = value.runtimeType as Type;
      }
    }

    return _unmarshal(value, type) as T;
  }

  void _errorExpectedValueOfType(Type type) {
    throw StateError('Expected value of type: $type');
  }

  dynamic _marshal(dynamic value, Type type) {
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
          result[key] = marshal(value[key], type: valueType);
        }

        return result;
      } else {
        _errorExpectedValueOfType(Map);
      }
    }

    if (typeInfo is IterableTypeInfo) {
      var elementType = typeInfo.elementType;
      if (value is Iterable) {
        var result = [];
        if (result is List) {
          for (var element in value) {
            result.add(marshal(element, type: elementType));
          }
        } else {
          _errorExpectedValueOfType(List);
        }

        return result;
      } else {
        _errorExpectedValueOfType(Iterable);
      }
    }

    if (value is Map) {
      var result = {};
      for (var key in value.keys) {
        result[key.toString()] = marshal(value[key]);
      }

      return result;
    }

    if (value is Iterable) {
      var result = [];
      for (var element in value) {
        result.add(marshal(element));
      }

      return result;
    }

    if (typeInfo == null) {
      throw StateError('Unable to marshal value of type: ${type}');
    }

    var result = <String, dynamic>{};
    for (var property in typeInfo.properties.values) {
      var name = property.name;
      var alias = property.alias;
      if (alias == null) {
        alias = name;
      }

      var acesssor = accessors[name];
      var val = acesssor.read(value);
      result[alias] = marshal(val, type: property.type);
    }

    return result;
  }

  dynamic _unmarshal(dynamic value, Type type) {
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
            result[key.toString()] = unmarshal(value[key], type: valueType);
          }

          return result;
        } else {
          _errorExpectedValueOfType(Map);
          return null;
        }
      } else {
        _errorExpectedValueOfType(Map);
        return null;
      }
    }

    if (typeInfo is IterableTypeInfo) {
      var elementType = typeInfo.elementType;
      var result = typeInfo.construct();
      if (result is List) {
        if (value is Iterable) {
          for (var element in value) {
            result.add(unmarshal(element, type: elementType));
          }

          return result;
        } else {
          _errorExpectedValueOfType(Iterable);
          return null;
        }
      } else {
        _errorExpectedValueOfType(List);
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
            var val = unmarshal(value[alias], type: property.type);
            accessor.write(result, val);
          }
        }

        return result;
      } else {
        _errorExpectedValueOfType(Map);
        return null;
      }
    }

    if (value is Iterable) {
      var result = [];
      for (var element in value) {
        result.add(unmarshal(element));
      }

      return result;
    }

    if (value is Map) {
      var result = {};
      for (var key in value.keys) {
        result[key] = unmarshal(value[key]);
      }

      return result;
    }

    throw StateError('Unable to unmarshal value of type: $type');
  }
}
