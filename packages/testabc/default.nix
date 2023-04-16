{ writers, test123, ... }:

let
  name = "testabc";
in
writers.writeDashBin name ''
  cat ${test123}/bin/test123
''
