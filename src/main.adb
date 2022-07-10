with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Real_Time;      use Ada.Real_Time;

with Board;
with Board.Score;
with Board.Print;
with Board.FEN;
with BitBoard;
with BitBoard.Magic;
with Perft;
with UCI;

procedure Main with SPARK_Mode => Off is
   B : Board.Board;
   Results : Perft.TestResult;
   Start_Time, Stop_Time : Ada.Real_Time.Time;
   PerftDuration : Duration;
   MaxDepth : Integer;

   type Number is delta 0.01 digits 18;

   MNodesPerSecond : Number;

begin
   BitBoard.Magic.Initialize;

   if Ada.Command_Line.Argument_Count >= 1 then
      if Ada.Command_Line.Argument (1) = "perft" then
         B := Board.FEN.Parse_FEN ((if Ada.Command_Line.Argument_Count = 3 then Ada.Command_Line.Argument (3) else Board.FEN.StartPosition));

         Board.Print.Print_Board (B, True);
         Ada.Text_IO.Put_Line ("Score : " & Integer'Image (Board.Score.Evaluate (B, B.CurrentSide)));

         MaxDepth := (if Ada.Command_Line.Argument_Count >= 2 then Integer'Value (Ada.Command_Line.Argument (2)) else 4);
         Ada.Text_IO.Put_Line ("Depth : " & Integer'Image (MaxDepth));

         for Depth in 1 .. MaxDepth loop
            Start_Time := Ada.Real_Time.Clock;
            Results := Perft.Test (B, Depth);
            Ada.Text_IO.Put_Line ("Test result for depth " & Integer'Image (Depth) & ": ");
            Ada.Text_IO.Put_Line ("    Nodes :      " & Integer'Image (Results.Nodes));
            Ada.Text_IO.Put_Line ("    Captures :   " & Integer'Image (Results.Captures));
            Ada.Text_IO.Put_Line ("    Castlings :  " & Integer'Image (Results.Castlings));
            Ada.Text_IO.Put_Line ("    Promotions : " & Integer'Image (Results.Promotions));
            Ada.Text_IO.Put_Line ("    Checks :     " & Integer'Image (Results.Checks));
            Ada.Text_IO.Put_Line ("-   ToCheck :    " & Integer'Image (Results.InvalidsToCheck));
            Stop_Time := Ada.Real_Time.Clock;
            PerftDuration := To_Duration (Stop_Time - Start_Time);
            MNodesPerSecond := Number (Results.Nodes) / Number (PerftDuration * 1_000_000);
            Ada.Text_IO.Put_Line ("Time is : :   " & Duration'Image (PerftDuration) & "," & Number'Image (MNodesPerSecond) & " MN/s");
         end loop;
      elsif Ada.Command_Line.Argument (1) = "debug" then
         Ada.Text_IO.Put_Line ("DEBUG!");
         B := Board.FEN.Parse_FEN ("4b1r1/N3bk2/8/5p2/2P1p3/4P2p/3K3q/6q1 w - - 0 39 ");

         Board.Print.Print_Board (B, True);
         Results := Perft.Test (B, 1);
         Ada.Text_IO.Put_Line ("Test result for depth " & Integer'Image (1) & ": ");
         Ada.Text_IO.Put_Line ("    Nodes :      " & Integer'Image (Results.Nodes));
         Ada.Text_IO.Put_Line ("    Captures :   " & Integer'Image (Results.Captures));
         Ada.Text_IO.Put_Line ("    Castlings :  " & Integer'Image (Results.Castlings));
         Ada.Text_IO.Put_Line ("    Promotions : " & Integer'Image (Results.Promotions));
         Ada.Text_IO.Put_Line ("    Checks :     " & Integer'Image (Results.Checks));
         Ada.Text_IO.Put_Line ("-   ToCheck :    " & Integer'Image (Results.InvalidsToCheck));
      else
         Ada.Text_IO.Put_Line ("Unknown switch " & Ada.Command_Line.Argument (1));
      end if;
   else
      UCI.Run;
   end if;
end Main;

