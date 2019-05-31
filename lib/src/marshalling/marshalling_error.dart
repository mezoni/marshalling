part of '../../marshalling.dart';

class MarshallingError {
  final String message;

  MarshallingError(this.message);

  @override
  String toString() {
    if (message == null) {
      return 'Marshalling error';
    }

    return 'Marshalling error: $message';
  }
}
