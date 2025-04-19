import '../access/abstract.dart';
import 'package:fractal/models/fractal.dart';

import '../db.dart';

mixin StoredFract on Fractal {
  FDBA get db => DBF.main.db;

  String get tableName => '';
}
