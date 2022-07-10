with Board; use Board;
with Move;
with Move.Generator;
with Move.Make;
with BitBoard.Attack;

--  https ://www.chessprogramming.org/Perft
--  https ://www.chessprogramming.org/Perft_Results

--  TODO :
--  "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1 "; --  perft does not match at level 4
--  "rnbqkb1r/pp1p1pPp/8/2p1pP2/1P1P4/3P3P/P1P1P3/RNBQKBNR w KQkq e6 0 1";
--  "r2q1rk1/ppp2ppp/2n1bn2/2b1p3/3pP3/3P1NPP/PPP1NPB1/R1BQ1RK1 b - - 0 9 ";
--  "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 9 "; --  perft does not match at level 3
--  "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1 "; --  perft does not match at level 3
--  "r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1  "; --  perft does not match at level 3
--  "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8  "; --  perft does not match at level 3


package body Perft with SPARK_Mode => On is

   function Test (B : in Board.Board; Depth : in Integer) return TestResult is
      Result, ResultInner : TestResult := (0, 0, 0, 0, 0, 0);
      BCopy : Board.Board;
      CurrentSide, OppSide : Side;
   begin
      if Depth = 0 then
         return (1, 0, 0, 0, 0, 0);
      end if;

      CurrentSide := B.CurrentSide;
      OppSide := Opposite_Side (B.CurrentSide);

      for M of Move.Generator.Generate_Moves (B, False) loop
         BCopy := Move.Make.Make_Move (M, B);
         if not BitBoard.Attack.Is_King_Under_Check (BCopy, OppSide, CurrentSide) then
            ResultInner := Test (BCopy, Depth - 1);

            Result.Nodes := Result.Nodes + ResultInner.Nodes;

            Result.Captures := Result.Captures + ResultInner.Captures;
            if Depth = 1 and then M.Kind in Move.Capture | Move.EnPassantCapture | Move.PromotionCapture then
               Result.Captures := Result.Captures + 1;
            end if;

            Result.Castlings := Result.Castlings + ResultInner.Castlings;
            if Depth = 1 and then M.Kind in Move.Castling then
               Result.Castlings := Result.Castlings + 1;
            end if;

            Result.Promotions := Result.Promotions + ResultInner.Promotions;
            if Depth = 1 and then M.Kind in Move.Promotion | Move.PromotionCapture then
               Result.Promotions := Result.Promotions + 1;
            end if;

            Result.Checks := Result.Checks + ResultInner.Checks;
            if Depth = 1 and then BitBoard.Attack.Is_King_Under_Check (BCopy, CurrentSide, OppSide) then
               Result.Checks := Result.Checks + 1;
            end if;
         else
            Result.InvalidsToCheck := Result.InvalidsToCheck + 1;
         end if;
      end loop;
      return Result;
   end Test;

end Perft;