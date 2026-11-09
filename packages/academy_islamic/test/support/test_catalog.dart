import 'dart:convert';
import 'dart:io';

import 'package:academy_islamic/academy_islamic.dart';

/// The real bundled corpus, read from disk for pure Dart tests.
AzkarCatalog loadTestCatalog() => AzkarCatalog.fromJson(
  jsonDecode(File('assets/azkar/azkar.json').readAsStringSync())
      as Map<String, dynamic>,
);
