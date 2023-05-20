{ writers, test123, ... }:

let
  pname = "testabc";
in
writers.writeDashBin "${pname}" ''
  cat ${test123}/bin/test123
''
