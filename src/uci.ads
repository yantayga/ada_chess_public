with Move;

package UCI with SPARK_Mode => Off is

   task type UCITask is
      entry StartCommunicate(S : String);
      entry SearchFinished(M : Move.Move);
   end;

   procedure Run;

end UCI;
