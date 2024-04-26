int get unixSeconds => (DateTime.now()).millisecondsSinceEpoch ~/ 1000;

formatFName(String title) => title
    .replaceAll(RegExp(r"\s+\b|\b\s"), "_")
    .replaceAll(
      RegExp('[^A-Za-z0-9_-]'),
      '',
    )
    .toLowerCase();
