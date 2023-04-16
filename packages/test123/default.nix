{ writers, ... }:

let
  name = "test123";
in
writers.writeDashBin name ''
  echo "Test123"
''
