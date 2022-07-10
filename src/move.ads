with Board; use Board;
with BitBoard;

package Move with SPARK_Mode => On is

   pragma Pure;

   type MoveKind is (PromotionCapture, Promotion, Capture, EnPassantCapture, DoublePush, Castling, Quiet);

   type Move is record
      SrcPiece : FullPiece;
      Src : BitBoard.SquareIndex;
      DstPiece : FullPiece;
      Dst : BitBoard.SquareIndex;
      Kind : MoveKind;
      PromotedPiece : Piece;
   end record;
   pragma Pack (Move);

   function Get_UCI (M : in Move) return String;

   function Parse_UCI (S : in String) return Move;

end Move;
