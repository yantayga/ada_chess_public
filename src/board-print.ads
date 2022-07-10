with Board;
with BitBoard;

package Board.Print with SPARK_Mode => On is

   procedure Print_Board (B : in Board; UseUnicode : in Boolean);

   procedure Print_BitBoard (BB : in BitBoard.BitBoard);

end Board.Print;