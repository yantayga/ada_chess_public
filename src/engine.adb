with Engine.Negamax;

package body Engine with SPARK_Mode => Off is

   protected body WorkFlag is
      procedure Enable is 
      begin
         Flag := True;
      end;

      procedure Disable is
      begin
         Flag := False;
      end;

      function IsWorking return Boolean is (Flag);
   end WorkFlag;

   function Search (B : in Board.Board; MaxDepth : in Integer) return Move.Move is
   begin
      return Engine.Negamax.Search (B, MaxDepth);
   end Search;

end Engine;
