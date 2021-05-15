// Copyright (c) 2021, I Made Mudita. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

const _fileLen = 45;
const _percentLen = 9;
const _uncoverLen = 19;
const _hundred = '100.00';
const _zero = '0.00 ';
const _dart = 'dart';
const _slash = '/';
const _bSlash = '\\';

void printCoverage(List<String> lines, List<String> files) {
  var idx = 0;
  _print('-', '-', '-', '-', '-', '-');
  _print(
      'File', '% Branch ', '% Funcs ', '% Lines ', 'Uncovered Line #s ', ' ');
  _print('-', '-', '-', '-', '-', '-');
  final result = lines.fold([0, 0, 0, 0, 0, 0, '', '', '', ''],
      (List<dynamic> data, line) {
    int functionFound = data[0];
    int functionHit = data[1];
    int linesFound = data[2];
    int linesHit = data[3];
    int branchFound = data[4];
    int branchHit = data[5];
    String uncoveredLines = data[6];
    String uncoveredBranch = data[7];
    String fileName = data[8];
    String directory = data[9];
    final values = line.split(':');
    switch (values[0]) {
      case 'SF':
        final fullFileName = values.last.replaceAll(_bSlash, _slash);
        for (var i = idx; i < files.length; i++) {
          idx = i;
          if (fullFileName.compareTo(files[i]) < 0) {
            _printDir(files[i], directory, true);
          } else {
            break;
          }
        }
        if ((idx < files.length && fullFileName.compareTo(files[idx]) == 0) ||
            (idx == (files.length - 1) &&
                fullFileName.compareTo(files[idx]) < 0)) {
          idx = idx + 1;
        }
        final result = _printDir(fullFileName, directory, false);
        fileName = result[0];
        directory = result[1];
        break;
      case 'DA':
        if (line.endsWith('0')) {
          uncoveredLines = (uncoveredLines != '' ? '$uncoveredLines,' : '') +
              values[1].split(',')[0];
        }
        break;
      case 'LF':
        linesFound = int.parse(values[1]);
        break;
      case 'LH':
        linesHit = int.parse(values[1]);
        break;
      case 'FNF':
        functionFound = int.parse(values[1]);
        break;
      case 'FNH':
        functionHit = int.parse(values[1]);
        break;
      case 'BRF':
        branchFound = int.parse(values[1]);
        break;
      case 'BRH':
        branchHit = int.parse(values[1]);
        break;
      case 'BRDA':
        if (line.endsWith('0')) {
          uncoveredBranch = (uncoveredBranch != '' ? '$uncoveredBranch,' : '') +
              values[1].split(',')[0];
        }
        break;
      case 'end_of_record':
        {
          final functions = _formatPercent(functionHit, functionFound);
          final lines = _formatPercent(linesHit, linesFound);
          final branch = _formatPercent(branchHit, branchFound);
          if (functions.trim() == _hundred &&
              lines.trim() == _hundred &&
              branch.trim() == _hundred) {
            uncoveredLines = '';
            uncoveredBranch = '';
          }
          var uncovered =
              uncoveredLines.isEmpty ? uncoveredBranch : uncoveredLines;
          uncovered = _formatString(uncovered, _uncoverLen, '...');
          final file = _formatString(' $fileName', _fileLen, '');
          _print(file, branch, functions, lines, uncovered, ' ');
          linesFound = 0;
          linesHit = 0;
          functionHit = 0;
          functionFound = 0;
          branchHit = 0;
          branchFound = 0;
          uncoveredLines = '';
          uncoveredBranch = '';
        }
        break;
    }

    return [
      functionFound,
      functionHit,
      linesFound,
      linesHit,
      branchFound,
      branchHit,
      uncoveredLines,
      uncoveredBranch,
      fileName,
      directory,
    ];
  });
  if (idx < files.length) {
    for (var i = idx; i < files.length; i++) {
      _printDir(files[i], result[9], true);
    }
  }
  _print('-', '-', '-', '-', '-', '-');
}

List<String> _printDir(String fullFileName, String directory, bool printFile) {
  final fileName = fullFileName.split(_slash).last;
  final dir = fullFileName.replaceAll(fileName, '');
  if (dir != directory) {
    directory = dir;
    _print(_formatString(directory, _fileLen, ''), ' ', ' ', ' ', ' ', ' ');
  }
  if (printFile) {
    _print(' $fileName', _zero, _zero, _zero, ' All', ' ');
  }
  return [fileName, directory];
}

String _formatPercent(int hit, int found) {
  if (found == 0) {
    return '$_hundred ';
  }
  return '${(hit / found * 100).toStringAsFixed(2)} ';
}

String _formatString(String input, int length, String more) {
  return input.length <= length
      ? input
      : '$more${input.substring(input.length - length + more.length)}';
}

void _print(String file, String branch, String function, String lines,
    String uncovered, String filler) {
  print('${file.padRight(_fileLen, filler)}|'
      '${branch.padLeft(_percentLen, filler)}|'
      '${function.padLeft(_percentLen, filler)}|'
      '${lines.padLeft(_percentLen, filler)}|'
      '${uncovered.padLeft(_uncoverLen, filler)}|');
}

Future<List<String>> getFiles(String path) async {
  final dir = Directory(path);
  final files = await dir.list(recursive: true).toList();
  final List<String> list = [];
  files.forEach((element) {
    final String file = element.uri.toString();
    if (file.split('.').last == _dart) {
      list.add(element.uri.toString());
    }
  });
  return list;
}
