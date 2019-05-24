part of '../../marshalling.dart';

class TypeInfo<T> {
  final T Function() construct;

  final Marshaller marshaller;

  Map<String, PropertyInfo> _properties = {};  

  TypeInfo._internal({this.construct, this.marshaller});

  Map<String, PropertyInfo> get properties => UnmodifiableMapView(_properties);  

  Type get type => T;
}
