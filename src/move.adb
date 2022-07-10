with BitBoard; use BitBoard;

package body Move with SPARK_Mode => On is

   function Get_UCI (M : in Move) return String is
      SrcCs, DstCs : SquareCoords;
   begin
      SrcCs := SquareIndex_To_Coords (M.Src);
      DstCs := SquareIndex_To_Coords (M.Dst);

      if M.SrcPiece.P = Pawn and then DstCs.Row in 0 | 7 then
         return Character'Val (Character'Pos ('a') + SrcCs.Col) & Character'Val (Character'Pos ('1') + 7 - SrcCs.Row)
            & Character'Val (Character'Pos ('a') + DstCs.Col) & Character'Val (Character'Pos ('1') + 7 - DstCs.Row)
            & PiecesAImages (Black, M.PromotedPiece);
      else
         return Character'Val (Character'Pos ('a') + SrcCs.Col) & Character'Val (Character'Pos ('1') + 7 - SrcCs.Row)
            & Character'Val (Character'Pos ('a') + DstCs.Col) & Character'Val (Character'Pos ('1') + 7 - DstCs.Row);
      end if;
   end Get_UCI;

   function Parse_UCI (S : in String) return Move is
      M : Move;
   begin
      if S'Length < 4 then
         raise Program_Error with "Wrong uci move '" & S & "'";
      end if;

      if S (S'First) in 'a' .. 'h' and then S (S'First + 1) in '1' .. '8' then
         M.Src :=  Parse_SquareIndex (S (S'First) & S (S'First + 1));
      end if;

      if S (S'First + 2) in 'a' .. 'h' and then S (S'First + 3) in '1' .. '8' then
         M.Dst := Parse_SquareIndex (S (S'First + 2) & S (S'First + 3));
      end if;

      if S'Length >= 5 then
         M.PromotedPiece := Character_to_FullPiece (S (S'First + 4)).P;
      else
         M.PromotedPiece := Pawn;
      end if;

      M.SrcPiece.S := White;
      M.SrcPiece.P := Pawn;
      M.Kind := Quiet;

      return M;
   end Parse_UCI;

end Move;
