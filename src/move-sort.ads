with Move.Generator; use Move.Generator;

package Move.Sort with SPARK_Mode => On is

   function Score_Move(M: Move) return Integer with Inline_Always;

   function Sort_Moves (Unsorted : in MoveArray) return MoveArray;

end Move.Sort;
