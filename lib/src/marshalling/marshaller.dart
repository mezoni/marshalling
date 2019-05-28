part of '../../marshalling.dart';

abstract class Marshaller {
  Map<Type, TypeInfo> _types = {};

  Set<Type> _primitiveTypes = Set<Type>();

  Map<String, PropertyAccessor> _accessors = {};

  Marshaller() {
    _primitiveTypes.add(bool);
    _primitiveTypes.add(DateTime);
    _primitiveTypes.add(double);
    _primitiveTypes.add(int);
    _primitiveTypes.add(num);
    _primitiveTypes.add(String);
    addType<Object>(() => Object());
  }

  Map<String, PropertyAccessor> get accessors =>
      UnmodifiableMapView(_accessors);

  Map<Type, TypeInfo> get types => UnmodifiableMapView(_types);

  PropertyAccessor addAccessor(String name, dynamic Function(dynamic) read,
      void Function(dynamic, dynamic) write) {
    if (name == null) {
      throw ArgumentError.notNull('name');
    }

    if (read == null) {
      throw ArgumentError.notNull('read');
    }

    if (write == null) {
      throw ArgumentError.notNull('write');
    }

    if (_accessors.containsKey(name)) {
      throw StateError('Property accessor "$name" already registered');
    }

    var accessor =
        PropertyAccessor._internal(name: name, read: read, write: write);
    _accessors[name] = accessor;
    return accessor;
  }

  MapTypeInfo<T, K, V> addMapType<T extends Map, K extends String, V>(
      T Function() construct) {
    if (construct == null) {
      throw ArgumentError.notNull('construct');
    }

    _checkTypeNotRegistered(T);
    if (!isPrimitiveType(V)) {
      _checkTypeRegistered(V);
    }

    var typeInfo =
        MapTypeInfo<T, K, V>._internal(construct: construct, marshaller: this);
    _types[T] = typeInfo;
    return typeInfo;
  }

  IterableTypeInfo<T, E> addIterableType<T extends Iterable, E>(
      T Function() construct) {
    if (construct == null) {
      throw ArgumentError.notNull('construct');
    }

    _checkTypeNotRegistered(T);
    if (!isPrimitiveType(E)) {
      _checkTypeRegistered(E);
    }

    var typeInfo = IterableTypeInfo<T, E>._internal(
        construct: construct, marshaller: this);
    _types[T] = typeInfo;
    return typeInfo;
  }

  PropertyInfo<P> addProperty<T, P>(String name, {String alias}) {
    if (name == null) {
      throw ArgumentError.notNull('name');
    }

    if (!isPrimitiveType(P)) {
      _checkTypeRegistered(P);
    }

    var typeInfo = _findType(T);
    var properties = typeInfo._properties;
    if (properties.containsKey(name)) {
      throw StateError('Property "$name" already registered for type $T');
    }

    if (!_accessors.containsKey(name)) {
      throw StateError('Property accessor "$name" is not registered');
    }

    var property =
        PropertyInfo<P>._internal(alias: alias, name: name, owner: typeInfo);
    properties[name] = property;
    return property;
  }

  TypeInfo<T> addType<T>(T Function() construct) {
    if (construct == null) {
      throw ArgumentError.notNull('construct');
    }

    if (isPrimitiveType(T)) {
      throw StateError('Primitive types are not supported');
    }

    if (T == dynamic) {
      throw StateError('Dynamic type not supported');
    }

    _checkTypeNotRegistered(T);
    var typeInfo =
        TypeInfo<T>._internal(construct: construct, marshaller: this);
    _types[T] = typeInfo;
    return typeInfo;
  }

  bool isPrimitiveType(Type type) {
    if (type == null) {
      throw ArgumentError.notNull('type');
    }

    return _primitiveTypes.contains(type);
  }

  dynamic marshal<T>(T value, {Type type});

  T unmarshal<T>(dynamic value, {Type type});

  void _checkTypeNotRegistered(Type type) {
    if (_types.containsKey(type)) {
      _errorTypeNotRegistered(type);
    }
  }

  void _checkTypeRegistered(Type type) {
    if (!_types.containsKey(type)) {
      throw StateError('Type $type is not registered');
    }
  }

  void _errorTypeNotRegistered(Type type) {
    throw StateError('Type $type is not registered');
  }

  TypeInfo _findType(Type type) {
    var result = _types[type];
    if (result == null) {
      _errorTypeNotRegistered(type);
    }

    return result;
  }
}
