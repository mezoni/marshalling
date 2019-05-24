part of '../../marshalling.dart';

class PropertyAccessor {
  final String name;

  final dynamic Function(dynamic) read;

  final void Function(dynamic, dynamic) write;

  PropertyAccessor._internal({this.name, this.read, this.write});
}
