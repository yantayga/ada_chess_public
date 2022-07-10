with BitBoard; use BitBoard;

package body Move.Make with SPARK_Mode => On is

   function Make_Move_UCI (M : in Move; B : in Board.Board) return Board.Board is
      MCopy : Move;
      IsCapture : Boolean := False;
      OppSide : Side;
   begin
      MCopy := M;
      for S in Side'Range loop
         OppSide := Opposite_Side (S);
         for P in Piece'Range loop
            if Get_BitBoard_BitAt (B.BitBoards (S, P), MCopy.Src) then
               MCopy.SrcPiece.S := S;
               MCopy.SrcPiece.P := P;
            end if;
            if Get_BitBoard_BitAt (B.BitBoards (OppSide, P), MCopy.Dst) then
               IsCapture := True;
            end if;
         end loop;
      end loop;

      if IsCapture then
         if MCopy.SrcPiece.P = Pawn and then (MCopy.Dst in Index (a8) .. Index (h8) | Index (a1) .. Index (h1)) then
            MCopy.Kind := PromotionCapture;
         else
            MCopy.Kind := Capture;
         end if;
      else
         if MCopy.SrcPiece.P = King then
            if abs (MCopy.Dst - MCopy.Src) = 2 then
               MCopy.Kind := Castling;
            end if;
         end if;
         if MCopy.SrcPiece.P = Pawn then
            if MCopy.SrcPiece.P = Pawn and then (MCopy.Dst in Index (a8) .. Index (h8) | Index (a1) .. Index (h1)) then
               MCopy.Kind := Promotion;
            elsif abs (MCopy.Dst - MCopy.Src) = 16 then
               MCopy.Kind := DoublePush;
            elsif abs (MCopy.Dst - MCopy.Src) in 7 | 9 then
               MCopy.Kind := EnPassantCapture;
            elsif abs (MCopy.Dst - MCopy.Src) in 7 | 9 then
               MCopy.Kind := EnPassantCapture;
            else
               MCopy.Kind := Quiet;
            end if;
         end if;
      end if;

      return Make_Move (MCopy, B);
   end Make_Move_UCI;

   function Make_Move (M : in Move; B : in Board.Board) return Board.Board is
      OppSide : Side;
      AdditionalSrc, AdditionalDst : SquareIndex;
      Result : Board.Board;

      procedure Set_BitBoard_At (What : in Piece; Which : in Side; Where : in SquareIndex) with Inline is
      begin
         Result.BitBoards (Which, What) := Set_BitBoard_BitAt (Result.BitBoards (Which, What), Where);
         Result.Occupancies (Which) := Set_BitBoard_BitAt (Result.Occupancies (Which), Where);
      end Set_BitBoard_At;

      procedure Reset_BitBoard_At (What : in Piece; Which : in Side; Where : in SquareIndex) with Inline is
      begin
         Result.BitBoards (Which, What) := Reset_BitBoard_BitAt (Result.BitBoards (Which, What), Where);
         Result.Occupancies (Which) := Reset_BitBoard_BitAt (Result.Occupancies (Which), Where);
      end Reset_BitBoard_At;

      procedure Find_And_Remove_Enemy with Inline is
      begin
         --  Find enemy and remove it
         for P in Piece'Range loop
            if Get_BitBoard_BitAt (Result.BitBoards (OppSide, P), M.Dst) then
               --  Get from
               Reset_BitBoard_At (P, OppSide, M.Dst);
               exit;
            end if;
         end loop;
      end Find_And_Remove_Enemy;
   begin
      Result := B;
      Reset_BitBoard_At (M.SrcPiece.P, Result.CurrentSide, M.Src);

      OppSide := Opposite_Side (Result.CurrentSide);
      Result.EnPassantExists := False;

      case M.Kind is
         when Quiet =>
            Set_BitBoard_At (M.SrcPiece.P, Result.CurrentSide, M.Dst);
         when Capture =>
            Set_BitBoard_At (M.SrcPiece.P, Result.CurrentSide, M.Dst);
            Find_And_Remove_Enemy;
         when EnPassantCapture =>
            Set_BitBoard_At (M.SrcPiece.P, Result.CurrentSide, M.Dst);
            --  Calculate where is the pawn
            AdditionalSrc := M.Dst + (if Result.CurrentSide = White then 8 else -8);
            --  Remove enemy --  it could Result. only pawn
            Reset_BitBoard_At (Pawn, OppSide, AdditionalSrc);
         when Promotion =>
            Set_BitBoard_At (M.PromotedPiece, Result.CurrentSide, M.Dst);
         when PromotionCapture =>
            Set_BitBoard_At (M.PromotedPiece, Result.CurrentSide, M.Dst);
            Find_And_Remove_Enemy;
         when DoublePush =>
            Set_BitBoard_At (M.SrcPiece.P, Result.CurrentSide, M.Dst);
            Result.EnPassantExists := True;
            Result.EnPassant := M.Dst + (if Result.CurrentSide = White then 8 else -8);
         when Castling =>
            Set_BitBoard_At (M.SrcPiece.P, Result.CurrentSide, M.Dst);
            --  Calculate where is the rook
            if Result.CurrentSide = White then
               AdditionalSrc := (if M.Dst = Index (g1) then Index (h1) else Index (a1));
               AdditionalDst := (if M.Dst = Index (g1) then Index (f1) else Index (d1));
            else
               AdditionalSrc := (if M.Dst = Index (g8) then Index (h8) else Index (a8));
               AdditionalDst := (if M.Dst = Index (g8) then Index (f8) else Index (d8));
            end if;
            --  Move rook
            Reset_BitBoard_At (Rook, Result.CurrentSide, AdditionalSrc);
            Set_BitBoard_At (Rook, Result.CurrentSide, AdditionalDst);
      end case;

      --  Update occupancies
      Result.AllOccupancies := Result.Occupancies (White) or Result.Occupancies (Black);

      Result.Castling (Black).Queen := Result.Castling (Black).Queen and then M.Dst /= Index (a8);
      Result.Castling (Black).King  := Result.Castling (Black).King  and then M.Dst /= Index (h8);
      Result.Castling (White).Queen := Result.Castling (White).Queen and then M.Dst /= Index (a1);
      Result.Castling (White).King  := Result.Castling (White).King  and then M.Dst /= Index (h1);
      --  Update castling status
      if M.SrcPiece.P = King then
         Result.Castling (B.CurrentSide) := (False, False);
      elsif M.SrcPiece.P = Rook then
         Result.Castling (B.CurrentSide).Queen :=
            Result.Castling (B.CurrentSide).Queen
            and then (M.Src /= (if Result.CurrentSide = White then Index (a1) else Index (a8)));
         Result.Castling (B.CurrentSide).King  :=
            Result.Castling (B.CurrentSide).King
            and then (M.Src /= (if Result.CurrentSide = White then Index (h1) else Index (h8)));
      end if;

      Result.CurrentSide := OppSide;

      return Result;
   end Make_Move;

end Move.Make;