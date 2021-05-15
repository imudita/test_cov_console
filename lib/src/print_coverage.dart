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

class _Data {
  int functionFound = 0;
  int functionHit = 0;
  int linesFound = 0;
  int linesHit = 0;
  int branchFound = 0;
  int branchHit = 0;
  String uncoveredLines = '';
  String uncoveredBranch = '';
  String fileName = '';
  String directory = '';

  _Data(fileName, directory) {
    this.fileName = fileName;
    this.directory = directory;
  }

  void total(_Data data) {
    functionFound += data.functionFound;
    functionHit += data.functionHit;
    linesFound += data.linesFound;
    linesHit += data.linesHit;
    branchFound += data.branchFound;
    branchHit += data.branchHit;
  }
}

void printCoverage(List<String> lines, List<String> files) {
  var idx = 0;
  _print('-', '-', '-', '-', '-', '-');
  _print(
      'File', '% Branch ', '% Funcs ', '% Lines ', 'Uncovered Line #s ', ' ');
  _print('-', '-', '-', '-', '-', '-');
  final result = lines.fold(<_Data>[_Data('', ''), _Data('', '')], (data, line) {
    var data0 = data[0];
    final values = line.split(':');
    switch (values[0]) {
      case 'SF':
        final fullFileName = values.last.replaceAll(_bSlash, _slash);
        for (var i = idx; i < files.length; i++) {
          idx = i;
          if (fullFileName.compareTo(files[i]) < 0) {
            _printDir(files[i], data0.directory, true);
          } else {
            break;
          }
        }
        if ((idx < files.length && fullFileName.compareTo(files[idx]) == 0) ||
            (idx == (files.length - 1) &&
                fullFileName.compareTo(files[idx]) < 0)) {
          idx = idx + 1;
        }
        final result = _printDir(fullFileName, data0.directory, false);
        data0.fileName = result[0];
        data0.directory = result[1];
        break;
      case 'DA':
        if (line.endsWith('0')) {
          data0.uncoveredLines =
              (data0.uncoveredLines != '' ? '${data0.uncoveredLines},' : '') +
                  values[1].split(',')[0];
        }
        break;
      case 'LF':
        data0.linesFound = int.parse(values[1]);
        break;
      case 'LH':
        data0.linesHit = int.parse(values[1]);
        break;
      case 'FNF':
        data0.functionFound = int.parse(values[1]);
        break;
      case 'FNH':
        data0.functionHit = int.parse(values[1]);
        break;
      case 'BRF':
        data0.branchFound = int.parse(values[1]);
        break;
      case 'BRH':
        data0.branchHit = int.parse(values[1]);
        break;
      case 'BRDA':
        if (line.endsWith('0')) {
          data0.uncoveredBranch =
              (data0.uncoveredBranch != '' ? '${data0.uncoveredBranch},' : '') +
                  values[1].split(',')[0];
        }
        break;
      case 'end_of_record':
        {
          data0 = _printFile(data0);
          data[1].total(data0);
          data0 = _Data(data0.fileName, data0.directory);
        }
        break;
    }

    return [data0,data[1]];
  });
  if (idx < files.length) {
    for (var i = idx; i < files.length; i++) {
      _printDir(files[i], result[0].directory, true);
    }
  }
  _print('-', '-', '-', '-', '-', '-');
  result[1].fileName = 'All files with unit testing';
  _printFile(result[1]);
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
    _print(' $fileName', _zero, _zero, _zero, 'no unit testing', ' ');
  }
  return [fileName, directory];
}

_Data _printFile(_Data data0) {
  final functions =
  _formatPercent(data0.functionHit, data0.functionFound);
  final lines = _formatPercent(data0.linesHit, data0.linesFound);
  final branch = _formatPercent(data0.branchHit, data0.branchFound);
  if (functions.trim() == _hundred &&
      lines.trim() == _hundred &&
      branch.trim() == _hundred) {
    data0.uncoveredLines = '';
    data0.uncoveredBranch = '';
  }
  var uncovered = data0.uncoveredLines.isEmpty
      ? data0.uncoveredBranch
      : data0.uncoveredLines;
  uncovered = _formatString(uncovered, _uncoverLen, '...');
  final file = _formatString(' ${data0.fileName}', _fileLen, '');
  _print(file, branch, functions, lines, uncovered, ' ');

  return data0;
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
