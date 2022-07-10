package body BitBoard.Attack with SPARK_Mode => On is

   function Get_Bishop_Attacks (Src : SquareIndex; Occupancies : in BitBoard) return BitBoard is
      MI : BishopMagicIndex;
   begin
      MI := BishopMagicIndex (Shift_Right ((Occupancies and BishopMasks (Src)) * BishopMagicNumbers (Src), 64 - BishopRelevantBits (Src)));

      return BishopAttacks (Src, MI);
   end Get_Bishop_Attacks;

   function Get_Rook_Attacks (Src : SquareIndex; Occupancies : in BitBoard) return BitBoard is
      MI : RookMagicIndex;
   begin
      MI := RookMagicIndex (Shift_Right ((Occupancies and RookMasks (Src)) * RookMagicNumbers (Src), 64 - RookRelevantBits (Src)));

      return RookAttacks (Src, MI);
   end Get_Rook_Attacks;

   function Is_Square_Attacked (B : in Board.Board; SI : in SquareIndex; From : in Side; To : in Side) return Boolean is
   begin
      if (PawnAttacks (To, SI) and B.BitBoards (From, Pawn)) /= 0 then
         return True;
      end if;

      if (KnightMoves (SI) and B.BitBoards (From, Knight)) /= 0 then
         return True;
      end if;

      if (KingMoves (SI) and B.BitBoards (From, King)) /= 0 then
         return True;
      end if;

      if (Get_Bishop_Attacks (SI, B.AllOccupancies) and B.BitBoards (From, Bishop)) /= 0 then
         return True;
      end if;

      if (Get_Rook_Attacks (SI, B.AllOccupancies) and B.BitBoards (From, Rook)) /= 0 then
         return True;
      end if;

      if ((Get_Bishop_Attacks (SI, B.AllOccupancies) or Get_Rook_Attacks (SI, B.AllOccupancies)) and B.BitBoards (From, Queen)) /= 0 then
         return True;
      end if;

      return False;
   end Is_Square_Attacked;

   function Is_King_Under_Check (B : in Board.Board; From : in Side; To : in Side) return Boolean is
      SI : SquareIndex;
   begin
      if B.BitBoards (To, King) /= 0 then
         SI := Get_BitBoard_LSB_Index (B.BitBoards (To, King));
         return Is_Square_Attacked (B, SI, From, To);
      end if;
      return False;
   end Is_King_Under_Check;

end BitBoard.Attack;
