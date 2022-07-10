package body Board with SPARK_Mode => On is

   function Opposite_Side (S : in Side) return Side is
   begin
      return (if S = White then Black else White);
   end Opposite_Side;

   function Character_to_FullPiece (Char : Character) return FullPiece is
   begin
      case Char is
         when 'p' =>
            return (Black, Pawn);
         when 'n' =>
            return (Black, Knight);
         when 'b' =>
            return (Black, Bishop);
         when 'r' =>
            return (Black, Rook);
         when 'k' =>
            return (Black, King);
         when 'q' =>
            return (Black, Queen);
         when 'P' =>
            return (White, Pawn);
         when 'N' =>
            return (White, Knight);
         when 'B' =>
            return (White, Bishop);
         when 'R' =>
            return (White, Rook);
         when 'K' =>
            return (White, King);
         when 'Q' =>
            return (White, Queen);
         when others =>
            raise Program_Error;
      end case;
   end Character_to_FullPiece;

end Board;
