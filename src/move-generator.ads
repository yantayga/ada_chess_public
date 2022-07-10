package Move.Generator with SPARK_Mode => On is

   type MoveArray is array (Natural range <>) of Move;

   function Generate_Moves (B : in Board.Board; AttacksOnly : in Boolean) return MoveArray;

end Move.Generator;
