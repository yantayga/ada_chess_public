with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;
with Ada.Strings.Maps;  use Ada.Strings.Maps;
with Ada.Strings.Fixed;

with Board;
with Board.Print;
with Board.FEN;
with Move.Print;
with Move.Make;
with Engine;

--  function with output global "Text_IO.File_System" is not allowed in SPARK
--  tasks also is not allowed in SPARK?
package body UCI with SPARK_Mode => Off is

   type StringArray is array (0 .. 1024) of Unbounded_String;

   function Split_String_By_Spaces (S : String) return StringArray is
      Result : StringArray;
      F : Positive;
      L : Natural;
      I : Natural := 1;
      N : Integer := 0;

      Whitespace : constant Character_Set :=  To_Set (' ');
   begin

      while I in S'Range loop
         Ada.Strings.Fixed.Find_Token
            (
               Source  => S,
               Set     => Whitespace,
               From    => I,
               Test    => Ada.Strings.Outside,
               First   => F,
               Last    => L
            );

         exit when L = 0 or else N not in Result'Range;

         Result (N) := To_Unbounded_String (S (F .. L));

         N := N + 1;
         I := L + 1;
      end loop;

      return Result;
   end Split_String_By_Spaces;

   task type SearchTask is
      entry StartSearch (B : in Board.Board; MaxDepth : in Integer);
      entry StopEngine;
   end;

   UT : UCITask;
   ST : SearchTask;

   task body SearchTask is
      M: Move.Move;
      BSaved : Board.Board;
      MaxDepthSaved : Integer;
      EF : Engine.WorkFlag;
   begin
      EF.Enable;
      while EF.IsWorking loop
         select
            accept StartSearch (B : in Board.Board; MaxDepth : in Integer) do
               BSaved := B;
               MaxDepthSaved := MaxDepth;
            end StartSearch;
            -- put computations dehors 'accept' to make call async!
            M := Engine.Search(BSaved, MaxDepthSaved);
            Put_Line ("Found best move " & Move.Get_UCI (M));
            UT.SearchFinished(M);
         or
            accept StopEngine do
               EF.Disable;
            end StopEngine;
         or
            terminate;
         end select;
      end loop;
   end;

   task body UCITask is
      B : Board.Board;
      V : StringArray;
      Cmd, Arg1, Arg2 : Unbounded_String;
      M : Move.Move;
   begin
      loop
         select
            accept StartCommunicate(S : String) do
               V := Split_String_By_Spaces (S);
               if V'Length > 0 then
                  Cmd := V (0);
                  if V'Length > 1 then
                     Arg1 := V (1);
                  end if;
                     if V'Length > 2 then
                     Arg2 := V (2);
                  end if;
                  if Cmd = "uci" then
                     Put_Line ("id name Ada Chess");
                     Put_Line ("id author YanTayga");
                     Put_Line ("uciok");
                  elsif Cmd = "isready" then
                     Put_Line ("readyok");
                  elsif Cmd = "position" then
                     if Arg1 = "startpos" then
                        B := Board.FEN.Parse_FEN (Board.FEN.StartPosition);
                        if Arg2 = "moves" then
                           for I in 3 .. V'Length - 1 loop
                              exit when V (I) = "";
                              M := Move.Parse_UCI (To_String (V (I)));
                              B := Move.Make.Make_Move_UCI (M, B);
                           end loop;
                        end if;
                        Board.Print.Print_Board (B, True);
                     elsif Arg1 = "FEN" then
                        if V'Length >= 3 then
                           B := Board.FEN.Parse_FEN (S (14 .. S'Last));
                           Board.Print.Print_Board (B, True);
                        end if;
                     end if;
                  elsif Cmd = "go" then
                     Engine.GlobalWorkFlag.Enable;
                     ST.StartSearch(B, 6);
                  elsif Cmd = "stop" then
                     Engine.GlobalWorkFlag.Disable;
                  elsif Cmd = "quit" then
                     Engine.GlobalWorkFlag.Disable;
                     ST.StopEngine;
                  end if;
               end if;
            end StartCommunicate;
         or
            accept SearchFinished(M : Move.Move) do
               B := Move.Make.Make_Move (M, B);
               Move.Print.Print_Move (M);
               Put_Line ("bestmove " & Move.Get_UCI (M));
            end SearchFinished;
         or
            terminate;
         end select;
      end loop;
   end;

   procedure Run is
      S : Unbounded_String;
   begin
      while not Ada.Text_IO.End_Of_File loop
         Ada.Strings.Unbounded.Text_IO.Get_Line (S);
         UT.StartCommunicate(To_String(S));
      end loop;
   end Run;

end UCI;
