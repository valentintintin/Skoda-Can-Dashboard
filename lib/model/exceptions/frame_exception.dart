class CanFrameCsvWrongException implements Exception {
  final String rawCanFrame;

  CanFrameCsvWrongException(this.rawCanFrame);

  @override
  String toString() {
    return this.runtimeType.toString() + " : " + rawCanFrame;
  }
}

class CanFrameCsvNoIdException extends CanFrameCsvWrongException {
  CanFrameCsvNoIdException(String rawCanFrame) : super(rawCanFrame);
}

class CanFrameCsvTooMuchDataException extends CanFrameCsvWrongException {
  CanFrameCsvTooMuchDataException(String rawCanFrame) : super(rawCanFrame);
}