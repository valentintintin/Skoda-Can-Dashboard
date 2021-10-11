class FrameWrongException implements Exception {
}

class FrameWrongLengthException implements Exception {
}

class FrameDataMissingForLengthException implements Exception {
}

class CanFrameCsvWrongException implements Exception {
  final String rawCanFrame;

  CanFrameCsvWrongException(this.rawCanFrame);

  @override
  String toString() {
    return this.runtimeType.toString() + " : " + rawCanFrame;
  }
}

class CanFrameNoIdException extends CanFrameCsvWrongException {
  CanFrameNoIdException(String rawCanFrame) : super(rawCanFrame);
}

class CanFrameTooMuchDataException extends CanFrameCsvWrongException {
  CanFrameTooMuchDataException(String rawCanFrame) : super(rawCanFrame);
}