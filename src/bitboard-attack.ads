with Board; use Board;
with BitBoard.Magic; use BitBoard.Magic;

package BitBoard.Attack with SPARK_Mode => On is

   function Get_Bishop_Attacks (Src : SquareIndex; Occupancies : in BitBoard) return BitBoard with
      Global => (Input  => (BishopMasks, BishopRelevantBits, BishopMagicNumbers));

   function Get_Rook_Attacks (Src : SquareIndex; Occupancies : in BitBoard) return BitBoard with
      Global => (Input  => (RookMasks, RookRelevantBits, RookMagicNumbers));

   function Is_Square_Attacked (B : in Board.Board; SI : in SquareIndex; From : in Side; To : in Side) return Boolean;

   function Is_King_Under_Check (B : in Board.Board; From : in Side; To : in Side) return Boolean with Inline;

end BitBoard.Attack;