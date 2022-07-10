with Board;

package Perft with SPARK_Mode => On is

   type TestResult is record
      Nodes : Integer;
      Captures : Integer;
      Castlings : Integer;
      Promotions : Integer;
      Checks : Integer;
      InvalidsToCheck : Integer;
   end record;

   function Test (B : in Board.Board; Depth : in Integer) return TestResult;

end Perft;