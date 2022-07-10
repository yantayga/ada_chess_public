package Move.Make with SPARK_Mode => On is

   pragma Pure;

   function Make_Move_UCI (M : in Move; B : in Board.Board) return Board.Board;

   function Make_Move (M : in Move; B : in Board.Board) return Board.Board;

end Move.Make;