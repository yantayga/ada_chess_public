with BitBoard;

package Board with SPARK_Mode => On, Pure is

   type Side is (White, Black);

   type Piece is (Pawn, Knight, Bishop, Rook, Queen, King);

   PiecesAImages : constant array (Side'Range, Piece'Range) of Character := (('P', 'N', 'B', 'R', 'Q', 'K'), ('p', 'n', 'b', 'r', 'q', 'k'));

   type FullPiece is record
      S : Side;
      P : Piece;
   end record;
   pragma Pack (FullPiece);

   function Character_to_FullPiece (Char : Character) return FullPiece;

   function Opposite_Side (S : in Side) return Side with Inline_Always;

   type CastlingStatus is record
      King :  Boolean;
      Queen : Boolean;
   end record;
   pragma Pack (CastlingStatus);

   type BitBoardKit is array (Side'Range, Piece'Range) of BitBoard.BitBoard;

   type BothOccupancies is array (Side'Range) of BitBoard.BitBoard;

   type BothCastlingStatus is array (Side'Range) of CastlingStatus;
   pragma Pack (BothCastlingStatus);

   type Board is record
      --  Boards itself
      BitBoards : BitBoardKit;
      Occupancies : BothOccupancies;
      AllOccupancies : BitBoard.BitBoard;
      --  Current move is
      CurrentSide : Side;
      --  Castling status
      Castling : BothCastlingStatus;
      --  En passant status
      EnPassantExists : Boolean;
      EnPassant : BitBoard.SquareIndex;
      --  Halfmove clock
      HalfMoves : Natural;
      --  Fullmove number
      Moves : Natural;
   end record;
   pragma Pack (Board);

end Board;