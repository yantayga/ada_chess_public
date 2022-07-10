package Board.FEN with SPARK_Mode => On is

   StartPosition : constant String :=  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 ";

   function Parse_FEN (FEN : in String) return Board;

   function Get_FEN (B : in Board) return String;

end Board.FEN;