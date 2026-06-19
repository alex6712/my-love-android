class ApiError implements Exception {
  final String code;
  final String? detail;

  ApiError(this.code, [this.detail]);

  @override
  String toString() => detail ?? code;
}
