part of '../../marshalling.dart';

class PropertyInfo<T> {
  final String alias;

  final String name;

  final TypeInfo owner;

  PropertyInfo._internal({this.alias, this.name, this.owner});

  Type get type => T;
}
