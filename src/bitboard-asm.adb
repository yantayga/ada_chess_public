with Interfaces;
with System.Machine_Code;

package body BitBoard.ASM is

   --  int ffsll (long long int i);
   --  function ffsll (A : Interfaces.C.unsigned_long) return Interfaces.C.int
   --   with Import => True, Convention => C, External_Name => "ffsll";

   function Get_BitBoard_LSB_Index (BB : in BitBoard) return SquareIndex is
      Result : Interfaces.Unsigned_64;
   begin
      if BB = 0 then
         raise Program_Error with "No LSB for zero BitBoard";
      end if;

      --  Bit count https ://en.wikipedia.org/wiki/Find_first_set
      --  ASM inlining : https ://docs.adacore.com/gnat_ugn-docs/html/gnat_ugn/gnat_ugn/inline_assembler.html
      System.Machine_Code.Asm (
         "TZCNT %%rax, %%rax",
         Outputs => Interfaces.Unsigned_64'Asm_Output ("=a", Result),
         Inputs  => Interfaces.Unsigned_64'Asm_Input ("a", Interfaces.Unsigned_64 (BB))
         );
      return SquareIndex (Result);
      --  return SquareIndex (ffsll (Interfaces.C.unsigned_long (BB)));
   end Get_BitBoard_LSB_Index;

   function Get_BitBoard_Bits_Count (BB : in BitBoard) return SquareIndex is
      Result : Interfaces.Unsigned_64;
   begin
      --  Bit count https ://en.wikipedia.org/wiki/Find_first_set
      --  ASM inlining : https ://docs.adacore.com/gnat_ugn-docs/html/gnat_ugn/gnat_ugn/inline_assembler.html
      System.Machine_Code.Asm (
         "POPCNT %%rax, %%rax",
         Outputs => Interfaces.Unsigned_64'Asm_Output ("=a", Result),
         Inputs  => Interfaces.Unsigned_64'Asm_Input ("a", Interfaces.Unsigned_64 (BB))
         );
      return SquareIndex (Result);
      --  return Integer (ffsll (Interfaces.C.unsigned_long (BB)));
   end Get_BitBoard_Bits_Count;

end BitBoard.ASM;