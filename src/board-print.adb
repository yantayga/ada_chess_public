with Ada.Text_IO;
with Ada.Wide_Text_IO;

with BitBoard;
use BitBoard;

package body Board.Print with SPARK_Mode => On is

   procedure Print_Board (B : in Board; UseUnicode : in Boolean) is
      pragma Wide_Character_Encoding (UTF8);
      PiecesUImages : constant array (Side'Range, Piece'Range) of Wide_Character := (('♙', '♘', '♗', '♖', '♕', '♔'), ('♟', '♞', '♝', '♜', '♛', '♚'));
      SI : SquareIndex;
      Found : Boolean;
      EnPassantCoords : SquareCoords;
   begin
      Ada.Text_IO.Put_Line ("");
      for Row in SideIndex'Range loop
         for Col in SideIndex'Range loop
            SI := Coords_To_SquareIndex ((Row, Col));
            if Col = SideIndex'First then
               Ada.Text_IO.Put (" " & SideIndex'Image (8 - Row));
            end if;
            Found := False;
            LoopForBitBoards :
            for Sd in Side'Range loop
               for Pc in Piece'Range loop
                  if Get_BitBoard_BitAt (B.BitBoards (Sd, Pc), SI) then
                     Found := True;
                     if UseUnicode then
                        Ada.Wide_Text_IO.Put (" " & PiecesUImages (Sd, Pc) & " ");
                     else
                        Ada.Text_IO.Put (" " & PiecesAImages (Sd, Pc) & " ");
                     end if;
                     exit LoopForBitBoards;
                  end if;
               end loop;
            end loop LoopForBitBoards;
            if not Found then
               Ada.Text_IO.Put (" . ");
            end if;
         end loop;
         Ada.Text_IO.Put_Line ("");
      end loop;

      Ada.Text_IO.Put_Line ("    a  b  c  d  e  f  g  h");

      Ada.Text_IO.Put_Line ("   Side :  " & (if B.CurrentSide = White then "w" else "b"));

      Ada.Text_IO.Put ("   Castling :  ");
      if B.Castling (White).King then
         Ada.Text_IO.Put ("K");
      end if;
      if B.Castling (White).Queen then
         Ada.Text_IO.Put ("Q");
      end if;
      if B.Castling (Black).King then
         Ada.Text_IO.Put ("k");
      end if;
      if B.Castling (Black).Queen then
         Ada.Text_IO.Put ("q");
      end if;
      Ada.Text_IO.New_Line;

      EnPassantCoords := SquareIndex_To_Coords (B.EnPassant);
      Ada.Text_IO.Put ("   EnPassant : ");
      if B.EnPassantExists then
         Ada.Text_IO.Put (Character'Val (Character'Pos ('a') + EnPassantCoords.Col));
         Ada.Text_IO.Put (Character'Val (Character'Pos ('1') + 7 - EnPassantCoords.Row));
         Ada.Text_IO.Put_Line ("");
      else
         Ada.Text_IO.Put_Line ("-");
      end if;
   end Print_Board;

   procedure Print_BitBoard (BB : in BitBoard.BitBoard) is
      SI : SquareIndex;
   begin
      for Row in SideIndex'Range loop
         for Col in SideIndex'Range loop
            SI := Coords_To_SquareIndex ((Row, Col));
            if Col = SideIndex'First then
               Ada.Text_IO.Put (" " & SideIndex'Image (8 - Row));
            end if;
            if Get_BitBoard_BitAt (BB, SI) then
               Ada.Text_IO.Put (" 1");
            else
               Ada.Text_IO.Put (" 0");
            end if;
         end loop;
         Ada.Text_IO.Put_Line ("");
      end loop;

      Ada.Text_IO.Put_Line ("    a b c d e f g h");
   end Print_BitBoard;

end Board.Print;
