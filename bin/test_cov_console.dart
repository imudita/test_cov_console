// Copyright (c) 2021, I Made Mudita. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:test_cov_console/test_cov_console.dart';

/// Generate coverage test report from lcov.info file to console.
///
/// If not given a lcov.info file, 'coverage/lcov.info' will be used.
///
/// Usage:
/// ```text
/// <lcov.info file>
/// ```
Future main(List<String> args) async {
  final slash = Platform.isWindows ? '\\' : '/';
  String lcovFile = 'coverage${slash}lcov.info';
  if (args.isNotEmpty) {
    lcovFile = args[0];
  }

  final lines = await File(lcovFile).readAsLines();

  printCoverage(lines);
}
