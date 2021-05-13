import 'dart:io';

const fileLen = 45;
const percentLen = 9;
const uncoverLen = 19;

Future<void> main(List<String> args) async {
  if (args.length == 0) {
    return;
  }
  final lcovFile = args[0];
  final lines = await File(lcovFile).readAsLines();

  _print('-', '-', '-', '-', '-', '-');
  _print(
      'File', '% Branch ', '% Funcs ', '% Lines ', 'Uncovered Line #s ', ' ');
  _print('-', '-', '-', '-', '-', '-');
  lines.fold([0, 0, 0, 0, 0, 0, '', '', '', ''], (List<dynamic> data, line) {
    var functionFound = data[0];
    var functionHit = data[1];
    var linesFound = data[2];
    var linesHit = data[3];
    var branchFound = data[4];
    var branchHit = data[5];
    String uncoveredLines = data[6];
    String uncoveredBranch = data[7];
    String fileName = data[8];
    String directory = data[9];
    final values = line.split(':');
    switch (values[0]) {
      case 'SF':
        final fullFileName = values.last;
        fileName = fullFileName.split('\\').last;
        final dir = fullFileName.replaceAll(fileName, '');
        if (dir != directory) {
          directory = dir;
          _print(_formatString(directory, fileLen, ''), ' ', ' ', ' ', ' ', ' ');
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

String _formatPercent(hit, found) {
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

void _print(file, branch, function, lines, uncovered, filler) {
  print('${file.padRight(fileLen, filler)}|'
      '${branch.padLeft(percentLen, filler)}|'
      '${function.padLeft(percentLen, filler)}|'
      '${lines.padLeft(percentLen, filler)}|'
      '${uncovered.padLeft(uncoverLen, filler)}|');
}
