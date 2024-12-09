int get unixSeconds => (DateTime.now()).millisecondsSinceEpoch ~/ 1000;

extension IfOb on Object {
  T? ifIs<T>() {
    if (this is T) return this as T;
    return null;
  }
}

extension DateTimeExt on DateTime {
  int get unixSeconds => millisecondsSinceEpoch ~/ 1000;
}

formatFName(String title) => title
    .replaceAll(RegExp(r"\s+\b|\b\s"), "_")
    .replaceAll(
      RegExp('[^A-Za-z0-9_.-]'),
      '',
    )
    .toLowerCase();
