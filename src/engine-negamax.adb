with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Calendar; use Ada.Calendar;

with Board; use Board;
with Board.Score;
with Move.Generator; use Move.Generator;
with Move.Sort; use Move.Sort;
with Move.Make;
with BitBoard.Attack; use BitBoard.Attack;

package body Engine.Negamax with SPARK_Mode => Off is

   subtype Jitter is Integer range -1 .. 1;

   package Random_Select is new Ada.Numerics.Discrete_Random (Jitter);

   G : Random_Select.Generator;

   type NegamaxResult is record
      BestMove : Move.Move;
      Score : Integer;
      Nodes: Integer;
   end record;

   function Quiescence (B : in Board.Board; Alpha, Beta : in Integer; Depth : in Natural; Ply : in Natural) return NegamaxResult is
      BCopy : Board.Board;
      CurrentSide, OppSide : Side;
      LegalMovesCount : Integer := 0;
      NewAlpha : Integer := Alpha;
      NoBestMove : Boolean := True;
      InnerResult, Result : NegamaxResult;
   begin
      Result.Score := Board.Score.Evaluate (B, B.CurrentSide) + Random_Select.Random(G);
      Result.Nodes := 0;
      if not GlobalWorkFlag.IsWorking or else Depth = 0 or else Result.Score >= Beta then
         Result.Nodes := 1;
         return Result;
      end if;

      --  Maybe better move
      if Result.Score > NewAlpha then
         NewAlpha := Result.Score;
      end if;

      CurrentSide := B.CurrentSide;
      OppSide := Opposite_Side (B.CurrentSide);

      for M of Move.Generator.Generate_Moves (B, True) loop
         BCopy := Move.Make.Make_Move (M, B);
         if not Is_King_Under_Check (BCopy, OppSide, CurrentSide) then
            LegalMovesCount := LegalMovesCount + 1;

            InnerResult := Quiescence (BCopy, -Beta, -NewAlpha, Depth - 1, Ply + 1);
            InnerResult.Score := -InnerResult.Score;
            Result.Nodes := Result.Nodes + InnerResult.Nodes;

            if InnerResult.Score >= Beta then
               Result.Score := Beta;
               return Result;
            end if;

            --  Maybe better move
            if InnerResult.Score > NewAlpha or else NoBestMove then
               NewAlpha := InnerResult.Score;
               Result.BestMove := M;
               NoBestMove := False;
            end if;
         end if;
      end loop;

      Result.Score := NewAlpha;
      return Result;
   end;

   function Negamax (B : in Board.Board; Alpha, Beta : in Integer; Depth : in Natural; Ply : in Natural) return NegamaxResult is
      BCopy : Board.Board;
      CurrentSide, OppSide : Side;
      LegalMovesCount : Integer := 0;
      NewAlpha : Integer := Alpha;
      NoBestMove : Boolean := True;
      InnerResult, Result : NegamaxResult;
   begin
      if not GlobalWorkFlag.IsWorking then
         Result.Score := Board.Score.Evaluate (B, B.CurrentSide);
         Result.Nodes := 1;
         return Result;
      end if;

      if Depth = 0 then
         return Quiescence(B, Alpha, Beta, Depth + 10, Ply);
      end if;

      Result.Nodes := 0;
      CurrentSide := B.CurrentSide;
      OppSide := Opposite_Side (B.CurrentSide);

      for M of Move.Generator.Generate_Moves (B, False) loop
         BCopy := Move.Make.Make_Move (M, B);
         if not Is_King_Under_Check (BCopy, OppSide, CurrentSide) then
            LegalMovesCount := LegalMovesCount + 1;

            InnerResult := Negamax (BCopy, -Beta, -NewAlpha, Depth - 1, Ply + 1);
            InnerResult.Score := -InnerResult.Score;
            Result.Nodes := Result.Nodes + InnerResult.Nodes;

            if InnerResult.Score >= Beta then
               if Ply = 0 then
                  Ada.Text_IO.Put_Line (
                     "Score: " & Move.Get_UCI (M) &
                     " (" & Integer'Image(Score_Move(M)) &
                     ") is " & Integer'Image (InnerResult.Score) &
                     " > " & Integer'Image (Beta) &
                     " <= return " &
                       (if NoBestMove then "-" else Move.Get_UCI (Result.BestMove)) &
                     " (" & Integer'Image (InnerResult.Nodes) & " ns)"
               );
               end if;
               Result.Score := Beta;
               return Result;
            end if;

            --  Maybe better move
            if InnerResult.Score > NewAlpha or else NoBestMove then
               NewAlpha := InnerResult.Score;
               Result.BestMove := M;
               NoBestMove := False;
            end if;

            if Ply = 0 then
               Ada.Text_IO.Put_Line ("Score: " & Move.Get_UCI (M) &
                  " (" & Integer'Image(Score_Move(M)) &
                  ") is " & Integer'Image (InnerResult.Score) &
                  " , < " & Move.Get_UCI (Result.BestMove) &
                  " (" & Integer'Image (InnerResult.Nodes) & " ns)"
               );
            end if;
         else
            if Ply = 0 then
               Ada.Text_IO.Put_Line ("Skipped: " & Move.Get_UCI (M));
            end if;
         end if;
      end loop;

      if Ply = 0 then
         Ada.Text_IO.Put_Line ("Generated " & Integer'Image (LegalMovesCount) &
            " moves for depth " & Integer'Image (Depth));
      end if;

      --  Is it chekmate ?
      if LegalMovesCount = 0 then
         if BitBoard.Attack.Is_King_Under_Check (B, OppSide, CurrentSide) then
            Result.Score := -40000 + Ply;
         else
            Result.Score := 0;
         end if;
      else
         Result.Score := NewAlpha;
      end if;

      return Result;
   end Negamax;

   function Search (B : in Board.Board; Depth : in Integer) return Move.Move
   is
      Result : NegamaxResult;
   begin
      Random_Select.Reset (G, Integer(Seconds(Clock)));

      Result := Negamax (B, -50000, +50000, Depth, 0);
      Ada.Text_IO.Put_Line ("Score for best " & Move.Get_UCI (Result.BestMove) &
                            " (" & Integer'Image(Score_Move(Result.BestMove)) &
                            " is " & Integer'Image (Result.Score) &
                            " (" & Integer'Image (Result.Nodes) & " ns)"
      );
      return Result.BestMove;
   end Search;

end Engine.Negamax;