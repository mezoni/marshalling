part of '../../marshalling.dart';

class MapTypeInfo<T extends Map, K extends String, V> extends TypeInfo<T> {
  MapTypeInfo._internal({T Function() construct, Marshaller marshaller})
      : super._internal(construct: construct, marshaller: marshaller);

  Type get keyType => K;

  Type get valueType => V;
}
