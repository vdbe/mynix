{ writers, ... }:

let
  pname = "test123";
in
writers.writeDashBin "${pname}" ''
  echo "Test123"
''
