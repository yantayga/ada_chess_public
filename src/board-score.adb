with BitBoard; use BitBoard;

package body Board.Score with SPARK_Mode => On is

   function Evaluate (B : in Board; Sd : in Side) return Integer is
      Score : Integer := 0;
      BB : BitBoard.BitBoard;
      SI : SquareIndex;
   begin
      for S in Side'Range loop
         for P in Piece'Range loop
            BB := B.BitBoards (S, P);
            while BB /= 0 loop
               SI := Get_BitBoard_LSB_Index (BB);
               BB := Reset_BitBoard_BitAt (BB, SI);
               Score := Score + PiecesScore (S, P) + (if S = White then PositionalScore (P, SI) else -PositionalScore (P, 63 - SI));
            end loop;
         end loop;
      end loop;

      return (if (Sd = White) then Score else -Score);
   end Evaluate;

end Board.Score;
