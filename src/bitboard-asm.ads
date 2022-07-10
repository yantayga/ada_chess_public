package BitBoard.ASM with SPARK_Mode => On is

   pragma Pure;

   function Get_BitBoard_LSB_Index (BB : in BitBoard) return SquareIndex with Inline_Always, Pure_Function,
      Pre => BB /= 0;

   function Get_BitBoard_Bits_Count (BB : in BitBoard) return SquareIndex with Inline_Always, Pure_Function;

end BitBoard.ASM;