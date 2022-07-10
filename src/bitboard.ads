with Ada.Unchecked_Conversion;

package BitBoard with SPARK_Mode => On, Pure is

   type SideIndex is range 0 .. 7;
   for SideIndex'Size use 3;

   type SquareCoords is record
      Row : SideIndex;
      Col : SideIndex;
   end record;
   pragma Pack (SquareCoords);

   type SquareIndex is range 0 .. 63;
   for SquareIndex'Size use 6;

   type SquareName is (
      a8, b8, c8, d8, e8, f8, g8, h8,
      a7, b7, c7, d7, e7, f7, g7, h7,
      a6, b6, c6, d6, e6, f6, g6, h6,
      a5, b5, c5, d5, e5, f5, g5, h5,
      a4, b4, c4, d4, e4, f4, g4, h4,
      a3, b3, c3, d3, e3, f3, g3, h3,
      a2, b2, c2, d2, e2, f2, g2, h2,
      a1, b1, c1, d1, e1, f1, g1, h1
   );
   for SquareName'Size use SquareIndex'Size;
   function Index is new Ada.Unchecked_Conversion (SquareName, SquareIndex) with Inline_Always;

   type BitBoard is mod 2 ** 64;
   for BitBoard'Size use 64;
   pragma Provide_Shift_Operators (BitBoard);

   function Set_BitBoard_BitAt (BB : in BitBoard; Index : in SquareIndex) return BitBoard with Inline_Always, Pure_Function;

   function Reset_BitBoard_BitAt (BB : in BitBoard; Index : in SquareIndex) return BitBoard with Inline_Always, Pure_Function;

   function Get_BitBoard_BitAt (BB : in BitBoard; Index : in SquareIndex) return Boolean with Inline_Always, Pure_Function;

   function Get_BitBoard_LSB_Index (BB : in BitBoard) return SquareIndex with Inline_Always, Pure_Function,
      Pre => BB /= 0;

   function Get_BitBoard_Bits_Count (BB : in BitBoard) return SquareIndex with Inline_Always, Pure_Function;

   function Coords_To_SquareIndex (Coord : in SquareCoords) return SquareIndex with Inline_Always, Pure_Function;

   function SquareIndex_To_Coords (Index : in SquareIndex) return SquareCoords with Inline_Always, Pure_Function;

   function Parse_SquareIndex (S : in String) return SquareIndex with Inline_Always, Pure_Function;

end BitBoard;
