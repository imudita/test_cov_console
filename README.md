# Flutter Console Coverage Test

This small dart tools is used to generate Flutter Coverage Test report to console

## How to install
Add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):
```
dev_dependencies:
  test_cov_console: ^0.0.3
```

## How to run
### run the following command to make sure all flutter library is up-to-date
```
flutter pub get
Running "flutter pub get" in coverage...                            0.5s
```
### run the following command to generate lcov.info on coverage directory
```
flutter test --coverage
00:02 +1: All tests passed!
```
### run the tool to generate report from lcov.info
```
flutter pub run test_cov_console
---------------------------------------------|---------|---------|---------|-------------------|
File                                         |% Branch | % Funcs | % Lines | Uncovered Line #s |
---------------------------------------------|---------|---------|---------|-------------------|
lib\                                         |         |         |         |                   |
 main.dart                                   |  100.00 |  100.00 |   92.59 |                3,4|
---------------------------------------------|---------|---------|---------|-------------------|
