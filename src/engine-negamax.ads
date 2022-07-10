with Board;
with Move;

package Engine.Negamax with SPARK_Mode => On is

   function Search (B : in Board.Board; Depth : in Integer) return Move.Move;

end Engine.Negamax;