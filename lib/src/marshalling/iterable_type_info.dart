part of '../../marshalling.dart';

class IterableTypeInfo<T extends Iterable, E> extends TypeInfo<T> {
  IterableTypeInfo._internal({T Function() construct, Marshaller marshaller})
      : super._internal(construct: construct, marshaller: marshaller);

  Type get elementType => E;
}
