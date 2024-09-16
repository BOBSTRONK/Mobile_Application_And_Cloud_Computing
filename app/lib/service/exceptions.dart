class NoConnectionException implements Exception {
  NoConnectionException(this.exception);
  final Exception exception;

  @override
  String toString() {
    return exception.toString();
  }
}

class UnexpectedResponseException implements Exception {
  UnexpectedResponseException(this.msg);
  final String msg;

  @override
  String toString() {
    return msg;
  }
}
