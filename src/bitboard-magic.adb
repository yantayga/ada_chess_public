with BitBoard; use BitBoard;

--  https ://www.chessprogramming.org/Magic_BitBoards
--  https ://www.chessprogramming.org/Looking_for_Magics

package body BitBoard.Magic with SPARK_Mode => On is

   procedure Loop2_Diag_From_To_And_Set (Coords : in SquareCoords; DR, DC : in Boolean; F, T : in SideIndex; Block : in BitBoard; Result : in out BitBoard) is
      Row, Col : SideIndex := 0;
   begin
      if Coords.Row = (if DR then SideIndex'Last else SideIndex'First)
         or Coords.Col = (if DC then SideIndex'Last else SideIndex'First)
      then
         return;
      end if;
      Row := (if DR then SideIndex'Succ (Coords.Row) else SideIndex'Pred (Coords.Row));
      Col := (if DC then SideIndex'Succ (Coords.Col) else SideIndex'Pred (Coords.Col));
      while Row in F .. T and Col in F .. T loop
         Result := Set_BitBoard_BitAt (Result, Coords_To_SquareIndex ((Row, Col)));

         exit when Get_BitBoard_BitAt (Block, Coords_To_SquareIndex ((Row, Col)));

         exit when Row = (if DR then SideIndex'Last else SideIndex'First) or else Col = (if DC then SideIndex'Last else SideIndex'First);

         Row := (if DR then SideIndex'Succ (Row) else SideIndex'Pred (Row));
         Col := (if DC then SideIndex'Succ (Col) else SideIndex'Pred (Col));
      end loop;
   end Loop2_Diag_From_To_And_Set;

   function Mask_Bishop_Attacks (SI : in SquareIndex) return BitBoard is
      Result : BitBoard := 0;
      Coords : SquareCoords;
   begin
      Coords := SquareIndex_To_Coords (SI);

      Loop2_Diag_From_To_And_Set (Coords, True, True, 1, 6, 0, Result);
      Loop2_Diag_From_To_And_Set (Coords, False, True, 1, 6, 0, Result);
      Loop2_Diag_From_To_And_Set (Coords, True, False, 1, 6, 0, Result);
      Loop2_Diag_From_To_And_Set (Coords, False, False, 1, 6, 0, Result);

      return Result;
   end Mask_Bishop_Attacks;

   procedure Loop_Coord (Coords : in SquareCoords; DR : in Boolean; InRow : in Boolean; F, T : in SideIndex; Block : in BitBoard; Result : in out BitBoard) is
      I : SideIndex := 0;
      SI : SquareIndex;
   begin
      if (if InRow then Coords.Col else Coords.Row) = (if DR then SideIndex'Last else SideIndex'First) then
         return;
      end if;
      if InRow then
         I := (if DR then SideIndex'Succ (Coords.Col) else SideIndex'Pred (Coords.Col));
      else
         I := (if DR then SideIndex'Succ (Coords.Row) else SideIndex'Pred (Coords.Row));
      end if;
      while I in F .. T loop
         SI := (if InRow then Coords_To_SquareIndex ((Coords.Row, I)) else Coords_To_SquareIndex ((I, Coords.Col)));

         Result := Set_BitBoard_BitAt (Result, SI);
         exit when Get_BitBoard_BitAt (Block, SI);

         exit when I = (if DR then SideIndex'Last else SideIndex'First);
         I := (if DR then SideIndex'Succ (I) else SideIndex'Pred (I));
      end loop;
   end Loop_Coord;

   function MaskRookAttacks (SI : in SquareIndex) return BitBoard is
      Result : BitBoard := 0;
      Coords : SquareCoords;
   begin
      Coords := SquareIndex_To_Coords (SI);

      Loop_Coord (Coords, True, True, 1, 6, 0, Result);
      Loop_Coord (Coords, False, True, 1, 6, 0, Result);
      Loop_Coord (Coords, True, False, 1, 6, 0, Result);
      Loop_Coord (Coords, False, False, 1, 6, 0, Result);

      return Result;
   end MaskRookAttacks;

   function Set_Occupancy (Index : in Integer; Bits : in SquareIndex; Mask : in BitBoard) return BitBoard is
      Result : BitBoard := 0;
      M : BitBoard := Mask;
      SI : SquareIndex;
   begin
      for I in 0 .. Bits - 1 loop
         exit when M = 0;

         SI := Get_BitBoard_LSB_Index (M);
         M := Reset_BitBoard_BitAt (M, SI);

         if (BitBoard (Index) and Set_BitBoard_BitAt (0, I)) /= 0 then
            Result := Set_BitBoard_BitAt (Result, SI);
         end if;
      end loop;

      return Result;
   end Set_Occupancy;

   function Bishop_Attacks_On_The_Fly (SI : in SquareIndex; Block : in BitBoard) return BitBoard is
      Result : BitBoard := 0;
      Coords : SquareCoords;
   begin
      Coords := SquareIndex_To_Coords (SI);

      Loop2_Diag_From_To_And_Set (Coords, True, True, 0, 7, Block, Result);
      Loop2_Diag_From_To_And_Set (Coords, False, True, 0, 7, Block, Result);
      Loop2_Diag_From_To_And_Set (Coords, True, False, 0, 7, Block, Result);
      Loop2_Diag_From_To_And_Set (Coords, False, False, 0, 7, Block, Result);

      return Result;
   end Bishop_Attacks_On_The_Fly;

   function Rook_Attacks_On_The_Fly (SI : in SquareIndex; Block : in BitBoard) return BitBoard is
      Result : BitBoard := 0;
      Coords : SquareCoords;
   begin
      Coords := SquareIndex_To_Coords (SI);

      Loop_Coord (Coords, True, True, 0, 7, Block, Result);
      Loop_Coord (Coords, False, True, 0, 7, Block, Result);
      Loop_Coord (Coords, True, False, 0, 7, Block, Result);
      Loop_Coord (Coords, False, False, 0, 7, Block, Result);

      return Result;
   end Rook_Attacks_On_The_Fly;

   procedure Init_Bishop_Attacks is
      MI : BishopMagicIndex;
      Occ : BitBoard;
      RBC : SquareIndex;
      IndexCount : BitBoard;
   begin
      for SI in SquareIndex'Range loop
         BishopMasks (SI) := Mask_Bishop_Attacks (SI);

         RBC := Get_BitBoard_Bits_Count (BishopMasks (SI));
         IndexCount := Set_BitBoard_BitAt (0, RBC);
         for I in 0 .. IndexCount - 1 loop
            Occ := Set_Occupancy (Integer (I), RBC, BishopMasks (SI));
            MI := BishopMagicIndex (Shift_Right (Occ * BishopMagicNumbers (SI), 64 - BishopRelevantBits (SI)));
            BishopAttacks (SI, MI) := Bishop_Attacks_On_The_Fly (SI, Occ);
         end loop;
      end loop;
   end Init_Bishop_Attacks;

   procedure Init_Rook_Attacks is
      MI : RookMagicIndex;
      Occ : BitBoard;
      RBC : SquareIndex;
      IndexCount : BitBoard;
   begin
      for SI in SquareIndex'Range loop
         RookMasks (SI) := MaskRookAttacks (SI);

         RBC := Get_BitBoard_Bits_Count (RookMasks (SI));
         IndexCount := Set_BitBoard_BitAt (0, RBC);
         for I in 0 .. IndexCount - 1 loop
            Occ := Set_Occupancy (Integer (I), RBC, RookMasks (SI));
            MI := RookMagicIndex (Shift_Right (Occ * RookMagicNumbers (SI), 64 - RookRelevantBits (SI)));
            RookAttacks (SI, MI) := Rook_Attacks_On_The_Fly (SI, Occ);
         end loop;
      end loop;
   end Init_Rook_Attacks;

   procedure Check_And_Set_Left (Src : in BitBoard; Index : in Integer; Mask : in BitBoard; Target : in out BitBoard) with Inline_Always is
      Res : BitBoard;
   begin
      Res := Shift_Left (Src, Index);
      if (Res and Mask) = Res then
         Target := Target or Res;
      end if;
   end Check_And_Set_Left;

   procedure Check_And_Set_Right (Src : in BitBoard; Index : in Integer; Mask : in BitBoard; Target : in out BitBoard) with Inline_Always is
      Res : BitBoard;
   begin
      Res := Shift_Right (Src, Index);
      if (Res and Mask) = Res then
         Target := Target or Res;
      end if;
   end Check_And_Set_Right;

   procedure Initialize_Pawn_Attacks is
      BBStart : BitBoard;
   begin
      for SI in SquareIndex'Range loop
         PawnAttacks (Black, SI) := 0;
         PawnAttacks (White, SI) := 0;
         BBStart := Set_BitBoard_BitAt (0, SI);

         Check_And_Set_Left (BBStart, 7, NotHCol, PawnAttacks (Black, SI));
         Check_And_Set_Left (BBStart, 9, NotACol, PawnAttacks (Black, SI));

         Check_And_Set_Right (BBStart, 7, NotACol, PawnAttacks (White, SI));
         Check_And_Set_Right (BBStart, 9, NotHCol, PawnAttacks (White, SI));
      end loop;
   end Initialize_Pawn_Attacks;

   procedure Initialize_King_Moves is
      BBStart : BitBoard;
   begin
      for SI in SquareIndex'Range loop
         KingMoves (SI) := 0;
         BBStart := Set_BitBoard_BitAt (0, SI);

         Check_And_Set_Left (BBStart, 1, NotACol, KingMoves (SI));
         Check_And_Set_Left (BBStart, 7, NotHCol, KingMoves (SI));
         KingMoves (SI) := KingMoves (SI) or Shift_Left (BBStart, 8);
         Check_And_Set_Left (BBStart, 9, NotACol, KingMoves (SI));
         Check_And_Set_Right (BBStart, 1, NotHCol, KingMoves (SI));
         Check_And_Set_Right (BBStart, 7, NotACol, KingMoves (SI));
         KingMoves (SI) := KingMoves (SI) or Shift_Right (BBStart, 8);
         Check_And_Set_Right (BBStart, 9, NotHCol, KingMoves (SI));
      end loop;
   end Initialize_King_Moves;


   procedure Initialize_Knight_Moves is
      BBStart : BitBoard;
   begin
      for SI in SquareIndex'Range loop
         KnightMoves (SI) := 0;
         BBStart := Set_BitBoard_BitAt (0, SI);

         Check_And_Set_Left (BBStart, 17, NotACol, KnightMoves (SI));
         Check_And_Set_Left (BBStart, 15, NotHCol, KnightMoves (SI));
         Check_And_Set_Left (BBStart, 10, NotABCol, KnightMoves (SI));
         Check_And_Set_Left (BBStart, 6, NotGHCol, KnightMoves (SI));
         Check_And_Set_Right (BBStart, 17, NotHCol, KnightMoves (SI));
         Check_And_Set_Right (BBStart, 15, NotACol, KnightMoves (SI));
         Check_And_Set_Right (BBStart, 10, NotGHCol, KnightMoves (SI));
         Check_And_Set_Right (BBStart, 6, NotABCol, KnightMoves (SI));
      end loop;
   end Initialize_Knight_Moves;

   procedure Initialize is
   begin
      Initialize_Pawn_Attacks;
      Initialize_King_Moves;
      Initialize_Knight_Moves;
      Init_Bishop_Attacks;
      Init_Rook_Attacks;
   end Initialize;

end BitBoard.Magic;