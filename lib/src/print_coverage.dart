// Copyright (c) 2021, I Made Mudita. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

const fileLen = 45;
const percentLen = 9;
const uncoverLen = 19;

void printCoverage(List<String> lines) {
  _print('-', '-', '-', '-', '-', '-');
  _print(
      'File', '% Branch ', '% Funcs ', '% Lines ', 'Uncovered Line #s ', ' ');
  _print('-', '-', '-', '-', '-', '-');
  lines.fold([0, 0, 0, 0, 0, 0, '', '', '', ''], (List<dynamic> data, line) {
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
        final fullFileName = values.last;
        fileName = fullFileName.replaceAll('/', '\\').split('\\').last;
        final dir = fullFileName.replaceAll(fileName, '');
        if (dir != directory) {
          directory = dir;
          _print(
              _formatString(directory, fileLen, ''), ' ', ' ', ' ', ' ', ' ');
        }
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
          if (functions.trim() == '100.00' &&
              lines.trim() == '100.00' &&
              branch.trim() == '100.00') {
            uncoveredLines = '';
            uncoveredBranch = '';
          }
          var uncovered =
              uncoveredLines.isEmpty ? uncoveredBranch : uncoveredLines;
          uncovered = _formatString(uncovered, uncoverLen, '...');
          final file = _formatString(' $fileName', fileLen, '');
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
  _print('-', '-', '-', '-', '-', '-');
}

String _formatPercent(int hit, int found) {
  if (found == 0) {
    return '100.00 ';
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
  print('${file.padRight(fileLen, filler)}|'
      '${branch.padLeft(percentLen, filler)}|'
      '${function.padLeft(percentLen, filler)}|'
      '${lines.padLeft(percentLen, filler)}|'
      '${uncovered.padLeft(uncoverLen, filler)}|');
}
