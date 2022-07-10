with Ada.Strings;  use Ada.Strings;
with Ada.Strings.Bounded;

with BitBoard; use BitBoard;

package body Board.FEN with SPARK_Mode => On is

   function Parse_FEN (FEN : in String) return Board is
      Result : Board;
      SI : SquareIndex;
      P : FullPiece;
      I : Integer;

   begin
      --  Reset board
      Result.AllOccupancies := 0;
      for Sd in Side'Range loop
         Result.Occupancies (Sd) := 0;
         for Pc in Piece'Range loop
            Result.BitBoards (Sd, Pc) := 0;
         end loop;

         Result.Castling (Sd).King := False;
         Result.Castling (Sd).Queen := False;
      end loop;
      Result.EnPassantExists := False;
      Result.HalfMoves := 0;
      Result.Moves := 0;

      --  Read board pieces
      SI := 0;
      I := FEN'First;
      loop
         exit when I not in FEN'Range;

         case FEN (I) is
            --  next line
            when '/' =>
               null;
            --  found free space
            when '1' .. '8' =>
               exit when (SI + (Character'Pos (FEN (I)) - Character'Pos ('0')) > SquareIndex'Last);
               SI := SI + (Character'Pos (FEN (I)) - Character'Pos ('0'));

            --  found piece
            when 'p' | 'n' | 'b' | 'r' | 'k' | 'q' | 'P' | 'N' | 'B' | 'R' | 'K' | 'Q' =>
               P := Character_to_FullPiece (FEN (I));
               Result.BitBoards (P.S, P.P) := Set_BitBoard_BitAt (Result.BitBoards (P.S, P.P), SI);
               exit when SI = SquareIndex'Last;
               SI := SquareIndex'Succ (SI);

            when others =>
               raise Program_Error with "Wrong symbol '" & FEN (I) & "' at " & Integer'Image (I);
         end case;

         I := Integer'Succ (I);
      end loop;

      for Sd in Side'Range loop
         for Pc in Piece'Range loop
            Result.Occupancies (Sd) := Result.Occupancies (Sd) or Result.BitBoards (Sd, Pc);
            Result.AllOccupancies := Result.AllOccupancies or Result.BitBoards (Sd, Pc);
         end loop;
      end loop;

      --  Skip space
      I := Integer'Succ (I);
      if I not in FEN'Range or else FEN (I) /= ' ' then
         raise Program_Error with "No space at " & Integer'Image (I);
      end if;

      I := Integer'Succ (I);
      --  Read current side
      if I not in FEN'Range then
         raise Program_Error with "Unexpected end at " & Integer'Image (I) & " (current side)";
      end if;
      case FEN (I) is
         when 'w' =>
            Result.CurrentSide := White;
         when 'b' =>
            Result.CurrentSide := Black;
         when others =>
            raise Program_Error with "Wrong side symbol " & FEN (I) & "'";
      end case;
      I := Integer'Succ (I);

      --  Skip space
      if I not in FEN'Range or else FEN (I) /= ' ' then
         raise Program_Error with "No space at " & Integer'Image (I) & " (castling)";
      end if;
      I := Integer'Succ (I);

      --  Read castinlg status
      if I not in FEN'Range then
         raise Program_Error with "Unexpected end at " & Integer'Image (I) & " (castling)";
      end if;
      loop
         exit when I not in FEN'Range;
         case FEN (I) is
            when 'K' =>
               Result.Castling (White).King := True;
            when 'Q' =>
               Result.Castling (White).Queen := True;
            when 'k' =>
               Result.Castling (Black).King := True;
            when 'q' =>
               Result.Castling (Black).Queen := True;
            when '-' =>
               null;
            when ' ' =>
               I := Integer'Pred (I);
               exit;

            when others =>
               raise Program_Error with "Wrong castling symbol '" & FEN (I) & "'";
         end case;
         I := Integer'Succ (I);
      end loop;

      --  Skip space
      I := Integer'Succ (I);
      if I not in FEN'Range or else FEN (I) /= ' ' then
         raise Program_Error with "No space at " & Integer'Image (I) & " (en passant)";
      end if;
      I := Integer'Succ (I);

      --  Read en passant status
      if I + 1 not in FEN'Range then
         raise Program_Error with "Unexpected end at " & Integer'Image (I) & " (en passant)";
      end if;
      if FEN (I) in 'a' .. 'h' then
         if FEN (I + 1) in '1' .. '8' then
            Result.EnPassant := Parse_SquareIndex (FEN (I .. I + 1));
            Result.EnPassantExists := True;
         end if;
      end if;

      --  We do not read halfmoves/moves
      return Result;
   end Parse_FEN;

   function Get_Piece_Image (FP : in FullPiece) return String with Inline_Always is
   begin
      return "" & PiecesAImages (FP.S, FP.P);
   end Get_Piece_Image;

   package B_Str is new
      Ada.Strings.Bounded.Generic_Bounded_Length (Max => 80);
   use B_Str;

   function Get_FEN (B : in Board) return String is
      Res : Bounded_String;
      SI, NI : SquareIndex;
      Found : Boolean;

      procedure Get_NIImage is
      begin
         if (NI > 0) then
            Res := Res & SquareIndex'Image (NI)(2);
            NI := 0;
         end if;
      end Get_NIImage;
   begin
      --  Write pieces
      NI := 0;
      for Row in SideIndex'Range loop
         for Col in SideIndex'Range loop
            SI := Coords_To_SquareIndex ((Row, Col));
            if Col = SideIndex'First then
               Get_NIImage;
               if Row > SideIndex'First then
                  Res := Res & "/";
               end if;
            end if;
            Found := False;
            LoopForBitBoards :
            for Sd in Side'Range loop
               for Pc in Piece'Range loop
                  if Get_BitBoard_BitAt (B.BitBoards (Sd, Pc), SI) then
                     Found := True;
                     Get_NIImage;
                     Res := Res & Get_Piece_Image ((Sd, Pc));
                     exit LoopForBitBoards;
                  end if;
               end loop;
            end loop LoopForBitBoards;
            if not Found then
               NI := SquareIndex'Succ (NI);
            end if;
         end loop;
      end loop;
      Get_NIImage;
      Res := Res & " ";

      --  Write side
      Res := Res & (if B.CurrentSide = White then "w" else "b");
      Res := Res & " ";

      --  Write castling

      --  write enpassant status

      return To_String (Res);
   end Get_FEN;

end Board.FEN;