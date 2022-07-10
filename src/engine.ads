with Board;
with Move;

package Engine with SPARK_Mode => Off is

   protected type WorkFlag is
      procedure Enable;
      procedure Disable;
      function IsWorking return Boolean;
   private
      Flag: Boolean := True;
   end WorkFlag;

   GlobalWorkFlag: WorkFlag;

   function Search (B : in Board.Board; MaxDepth : in Integer) return Move.Move;

end Engine;
