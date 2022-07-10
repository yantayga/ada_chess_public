with BitBoard.ASM;

package body BitBoard with SPARK_Mode => On is

   function Set_BitBoard_BitAt (BB : in BitBoard; Index : in SquareIndex) return BitBoard is
   begin
      return BB or Shift_Left (1, Integer (Index));
   end Set_BitBoard_BitAt;

   function Reset_BitBoard_BitAt (BB : in BitBoard; Index : in SquareIndex) return BitBoard is
   begin
      return BB and (not Shift_Left (1, Integer (Index)));
   end Reset_BitBoard_BitAt;

   function Get_BitBoard_BitAt (BB : in BitBoard; Index : in SquareIndex) return Boolean is
   begin
      return (BB and Shift_Left (1, Integer (Index))) /= 0;
   end Get_BitBoard_BitAt;

   function Get_BitBoard_LSB_Index (BB : in BitBoard) return SquareIndex is
   begin
      return ASM.Get_BitBoard_LSB_Index (BB);
   end Get_BitBoard_LSB_Index;

   function Get_BitBoard_Bits_Count (BB : in BitBoard) return SquareIndex is
   begin
      return ASM.Get_BitBoard_Bits_Count (BB);
   end Get_BitBoard_Bits_Count;

   function Coords_To_SquareIndex (Coord : in SquareCoords) return SquareIndex is
   begin
      return SquareIndex (Coord.Row * 8 + Coord.Col);
   end Coords_To_SquareIndex;

   function SquareIndex_To_Coords (Index : in SquareIndex) return SquareCoords is
      Result : SquareCoords;
   begin
      Result.Row := SideIndex (Index / 8);
      Result.Col := SideIndex (Index mod 8);
      return Result;
   end SquareIndex_To_Coords;

   function Character_to_Index (Char : in Character) return SideIndex is
   begin
      if Char in '1' .. '8' then
         return SideIndex (7 + Character'Pos ('1') - Character'Pos (Char));
      end if;

      if Char in 'a' .. 'h' then
         return SideIndex (Character'Pos (Char) - Character'Pos ('a'));
      end if;

      return 0;
   end Character_to_Index;

   function Parse_SquareIndex (S : in String) return SquareIndex is
   begin
      if S'Length < 2 then
         return 0;
      end if;

      return Coords_To_SquareIndex ((Character_to_Index (S (S'First + 1)), Character_to_Index (S (S'First))));
   end Parse_SquareIndex;

end BitBoard;

