with Ada.Text_IO;
with BitBoard; use BitBoard;
with Move.Sort; use Move.Sort;

package body Move.Print with SPARK_Mode => On is

   procedure Print_Move (M : in Move; Comment : in String := "") is
      Coords : SquareCoords;
   begin
      Ada.Text_IO.Put (PiecesAImages (M.SrcPiece.S, M.SrcPiece.P));
      Coords := SquareIndex_To_Coords (M.Src);
      Ada.Text_IO.Put (Character'Val (Character'Pos ('a') + Coords.Col));
      Ada.Text_IO.Put (Character'Val (Character'Pos ('1') + 7 - Coords.Row));
      Ada.Text_IO.Put (if M.Kind in Capture | EnPassantCapture | PromotionCapture
                       then ":" else "-");
      Coords := SquareIndex_To_Coords (M.Dst);
      Ada.Text_IO.Put (Character'Val (Character'Pos ('a') + Coords.Col));
      Ada.Text_IO.Put (Character'Val (Character'Pos ('1') + 7 - Coords.Row));

      case M.Kind is
         when Quiet =>
            null;
         when Capture =>
            Ada.Text_IO.Put ("(takes " & PiecesAImages (M.DstPiece.S, M.PromotedPiece) & ")");
         when Promotion =>
            Ada.Text_IO.Put (PiecesAImages (M.SrcPiece.S, M.PromotedPiece));
         when PromotionCapture =>
            Ada.Text_IO.Put (PiecesAImages (M.SrcPiece.S, M.PromotedPiece));
            Ada.Text_IO.Put ("(takes " & PiecesAImages (M.DstPiece.S, M.PromotedPiece) & ")");
         when Castling =>
            Ada.Text_IO.Put (" (castling)");
         when EnPassantCapture =>
            Ada.Text_IO.Put (" (en passant ");
            Ada.Text_IO.Put (Character'Val (Character'Pos ('a') + Coords.Col));
            Ada.Text_IO.Put (
               Character'Val (Character'Pos ('1') + 7 - Coords.Row +
                  (if M.SrcPiece.S = White then 1 else -1))
            );
            Ada.Text_IO.Put (") (takes " & PiecesAImages (M.DstPiece.S, M.PromotedPiece) & ")");
         when DoublePush =>
            Ada.Text_IO.Put (" (double push)");
      end case;
      Ada.Text_IO.Put_Line (" SCORE: " & Integer'Image(Score_Move(M)) & " KIND :" & MoveKind'Image (M.Kind) & " " & Comment);
   end Print_Move;

end Move.Print;