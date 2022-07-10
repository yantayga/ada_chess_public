with Ada.Containers.Generic_Array_Sort;
with Board.Score; use Board.Score;

package body Move.Sort with SPARK_Mode => On is

   function Score_Move(M: Move) return Integer is
   begin
      if M.Kind in PromotionCapture | Capture | EnPassantCapture then
         return PiecesScore(White, M.DstPiece.P) * 1_000_000 / PiecesScore(White, M.SrcPiece.P);
      else
         return PiecesScore(White, M.SrcPiece.P);
      end if;
   end;

   function "<" (L, R : Move) return Boolean is
   begin
      return Score_Move(L) > Score_Move(R);
   end "<";

   procedure Sort is new Ada.Containers.Generic_Array_Sort (Natural, Move, MoveArray);

   function Sort_Moves (Unsorted : in MoveArray) return MoveArray is
      Sorted: MoveArray := Unsorted;
   begin
      Sort(Sorted);
      return Sorted;
   end Sort_Moves;

end Move.Sort;