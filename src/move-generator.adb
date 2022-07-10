with BitBoard; use BitBoard;
with BitBoard.Magic; use BitBoard.Magic;
with BitBoard.Attack; use BitBoard.Attack;
with Move.Sort; use Move.Sort;

package body Move.Generator with SPARK_Mode => Off is

   function Find_Piece(B : in Board.Board; S: in Side; SI: SquareIndex) return FullPiece is
      Result: FullPiece;
   begin
      Result.S := S;
      for P in Piece'Range loop
         if Get_BitBoard_BitAt (B.BitBoards (S, P), SI) then
            Result.P := Pawn;
            exit;
         end if;
      end loop;
      return Result;
   end Find_Piece;

   Maximum_Moves_Generated_For_Piece : constant Integer := 100;
   Empty : constant MoveArray := (1 .. 0 => <>);

   function Generate_Pawn_Moves (B : in Board.Board; AttacksOnly : in Boolean) return MoveArray is
      BBSrc, BBDst : BitBoard.BitBoard;
      M : Move;
      OppSide : Side;
      Result : MoveArray (0 .. Maximum_Moves_Generated_For_Piece);
      I : Integer := 0;

      procedure Check_Promotion_And_Add (IsCapture : in Boolean) with Inline is
         ValidPromotions : constant array (Integer range <>) of Piece := (Knight, Bishop, Rook, Queen);
      begin
         if (B.CurrentSide = White and then M.Dst <= Index (h8))
               or else (B.CurrentSide = Black and then M.Dst >= Index (a1))
         then
            M.Kind := (if IsCapture then PromotionCapture else Promotion);
            for Ps of ValidPromotions loop
               M.PromotedPiece := Ps;
               Result (I) := M;
               I := I + 1;
            end loop;
         else
            M.Kind := (if IsCapture then Capture else Quiet);
            Result (I) := M;
            I := I + 1;
         end if;
      end Check_Promotion_And_Add;
   begin
      BBSrc := B.BitBoards (B.CurrentSide, Pawn);
      OppSide := Opposite_Side (B.CurrentSide);

      M.SrcPiece.P := Pawn;
      M.SrcPiece.S := B.CurrentSide;

      while BBSrc /= 0 loop
         M.Src := Get_BitBoard_LSB_Index (BBSrc);
         BBSrc := Reset_BitBoard_BitAt (BBSrc, M.Src);
         BBDst := PawnAttacks (B.CurrentSide, M.Src);

         --  Generate pawn attacks
         while BBDst /= 0 loop
            M.Dst := Get_BitBoard_LSB_Index (BBDst);
            BBDst := Reset_BitBoard_BitAt (BBDst, M.Dst);

            if not Get_BitBoard_BitAt (B.Occupancies (B.CurrentSide), M.Dst)
               and then (Get_BitBoard_BitAt (B.Occupancies (OppSide), M.Dst)
                  or else (B.EnPassantExists and then B.EnPassant = M.Dst))
            then
               M.DstPiece := Find_Piece(B, OppSide, M.Dst);
               Check_Promotion_And_Add (True);
            end if;
         end loop;

         if not AttacksOnly then
            --  Generate pawn quiet moves
            M.Dst := M.Src + (if B.CurrentSide = White then -8 else 8);
            if not Get_BitBoard_BitAt (B.AllOccupancies, M.Dst) then
               Check_Promotion_And_Add (False);
            end if;

            if (B.CurrentSide = White and then M.Src >= 48)
               or else (B.CurrentSide = Black and then M.Src <= 15)
            then
               M.Dst := M.Src + (if B.CurrentSide = White then -8 else 8);
               if not Get_BitBoard_BitAt (B.AllOccupancies, M.Dst) then
                  M.Dst := M.Dst + (if B.CurrentSide = White then -8 else 8);
                  if not Get_BitBoard_BitAt (B.AllOccupancies, M.Dst) then
                     M.Kind := DoublePush;
                     Result (I) := M;
                     I := I + 1;
                  end if;
               end if;
            end if;
         end if;
      end loop;
      if I > 0 then
         return Result (0 .. I - 1);
      else
         return Empty;
      end if;
   end Generate_Pawn_Moves;

   function Generate_Knight_Moves (B : in Board.Board; AttacksOnly : in Boolean) return MoveArray is
      BBSrc, BBDst : BitBoard.BitBoard;
      M : Move;
      OppSide : Side;
      Result : MoveArray (0 .. Maximum_Moves_Generated_For_Piece);
      I : Integer := 0;
   begin
      BBSrc := B.BitBoards (B.CurrentSide, Knight);
      OppSide := Opposite_Side (B.CurrentSide);

      M.SrcPiece.P := Knight;
      M.SrcPiece.S := B.CurrentSide;

      while BBSrc /= 0 loop
         M.Src := Get_BitBoard_LSB_Index (BBSrc);
         BBSrc := Reset_BitBoard_BitAt (BBSrc, M.Src);
         BBDst := KnightMoves (M.Src);

         while BBDst /= 0 loop
            M.Dst := Get_BitBoard_LSB_Index (BBDst);
            BBDst := Reset_BitBoard_BitAt (BBDst, M.Dst);

            if not Get_BitBoard_BitAt (B.Occupancies (B.CurrentSide), M.Dst) then
               M.Kind := (if Get_BitBoard_BitAt (B.Occupancies (OppSide), M.Dst) then Capture else Quiet);
               if M.Kind = Capture then
                  M.DstPiece := Find_Piece(B, OppSide, M.Dst);
               end if;
               if not AttacksOnly or else M.Kind = Capture then
                  Result (I) := M;
                  I := I + 1;
               end if;
            end if;
         end loop;
      end loop;
      if I > 0 then
         return Result (0 .. I - 1);
      else
         return Empty;
      end if;
   end Generate_Knight_Moves;

   function Generate_King_Moves (B : in Board.Board; AttacksOnly : in Boolean) return MoveArray is
      BBSrc, BBDst : BitBoard.BitBoard;
      M : Move;
      OppSide : Side;
      Result : MoveArray (0 .. Maximum_Moves_Generated_For_Piece);
      I : Integer := 0;
   begin
      BBSrc := B.BitBoards (B.CurrentSide, King);
      OppSide := Opposite_Side (B.CurrentSide);

      M.SrcPiece.P := King;
      M.SrcPiece.S := B.CurrentSide;

      while BBSrc /= 0 loop
         M.Src := Get_BitBoard_LSB_Index (BBSrc);
         BBSrc := Reset_BitBoard_BitAt (BBSrc, M.Src);

         BBDst := KingMoves (M.Src);

         --  Generate usal moves
         while BBDst /= 0 loop
            M.Dst := Get_BitBoard_LSB_Index (BBDst);
            BBDst := Reset_BitBoard_BitAt (BBDst, M.Dst);

            if not Get_BitBoard_BitAt (B.Occupancies (B.CurrentSide), M.Dst) then
               M.Kind := (if Get_BitBoard_BitAt (B.Occupancies (OppSide), M.Dst) then Capture else Quiet);
               if M.Kind = Capture then
                  M.DstPiece := Find_Piece(B, OppSide, M.Dst);
               end if;
               if not AttacksOnly or else M.Kind = Capture then
                  Result (I) := M;
                  I := I + 1;
               end if;
            end if;
         end loop;

         --  Generate castling
         if B.Castling (B.CurrentSide).King
               and then not Is_Square_Attacked (B, M.Src, OppSide, B.CurrentSide)
               and then not Get_BitBoard_BitAt (B.AllOccupancies, M.Src + 1)
               and then not Is_Square_Attacked (B, M.Src + 1, OppSide, B.CurrentSide)
               and then not Get_BitBoard_BitAt (B.AllOccupancies, M.Src + 2)
         then
            M.Dst := M.Src + 2;
            M.Kind := Castling;
            Result (I) := M;
            I := I + 1;
         end if;
         if B.Castling (B.CurrentSide).Queen
               and then not Is_Square_Attacked (B, M.Src, OppSide, B.CurrentSide)
               and then not Get_BitBoard_BitAt (B.AllOccupancies, M.Src - 1)
               and then not Is_Square_Attacked (B, M.Src - 1, OppSide, B.CurrentSide)
               and then not Get_BitBoard_BitAt (B.AllOccupancies, M.Src - 2)
               and then not Is_Square_Attacked (B, M.Src - 2, OppSide, B.CurrentSide)
               and then not Get_BitBoard_BitAt (B.AllOccupancies, M.Src - 3)
         then
            M.Dst := M.Src - 2;
            M.Kind := Castling;
            Result (I) := M;
            I := I + 1;
         end if;
      end loop;
      if I > 0 then
         return Result (0 .. I - 1);
      else
         return Empty;
      end if;
   end Generate_King_Moves;

   type AttackGeneratorFn is access function (Src : BitBoard.SquareIndex; Occupancies : in BitBoard.BitBoard) return BitBoard.BitBoard;
   type AttackGeneratorFnArray is array (Positive range <>) of AttackGeneratorFn;

   function Generate_Slider_Moves (B : in Board.Board; P : in Piece; AttacksOnly : in Boolean; Generators : in AttackGeneratorFnArray) return MoveArray is
      BBSrc, BBDst : BitBoard.BitBoard;
      M : Move;
      OppSide : Side;
      Result : MoveArray (0 .. Maximum_Moves_Generated_For_Piece);
      I : Integer := 0;
   begin
      BBSrc := B.BitBoards (B.CurrentSide, P);
      OppSide := Opposite_Side (B.CurrentSide);

      M.SrcPiece.P := P;
      M.SrcPiece.S := B.CurrentSide;

      while BBSrc /= 0 loop
         M.Src := Get_BitBoard_LSB_Index (BBSrc);
         BBSrc := Reset_BitBoard_BitAt (BBSrc, M.Src);

         for FnIndex in Generators'Range loop
            --  Get attacks and remove allies
            BBDst := Generators (FnIndex)(M.Src, B.AllOccupancies) and not B.Occupancies (B.CurrentSide);

            while BBDst /= 0 loop
               M.Dst := Get_BitBoard_LSB_Index (BBDst);
               BBDst := Reset_BitBoard_BitAt (BBDst, M.Dst);

               M.Kind := (if Get_BitBoard_BitAt (B.Occupancies (OppSide), M.Dst) then Capture else Quiet);
               if M.Kind = Capture then
                  M.DstPiece := Find_Piece(B, OppSide, M.Dst);
               end if;
               if not AttacksOnly or else M.Kind = Capture then
                  Result (I) := M;
                  I := I + 1;
               end if;
            end loop;
         end loop;
      end loop;
      if I > 0 then
         return Result (0 .. I - 1);
      else
         return Empty;
      end if;
   end Generate_Slider_Moves;

   function Generate_Moves (B : in Board.Board; AttacksOnly : in Boolean) return MoveArray is
   begin
      return Sort_Moves(
         Generate_Pawn_Moves (B, AttacksOnly) &
         Generate_Knight_Moves (B, AttacksOnly) &
         Generate_King_Moves (B, AttacksOnly) &
         Generate_Slider_Moves (B, Bishop, AttacksOnly, (1 => Get_Bishop_Attacks'Access)) &
         Generate_Slider_Moves (B, Rook, AttacksOnly, (1 => Get_Rook_Attacks'Access)) &
         Generate_Slider_Moves (B, Queen, AttacksOnly, (1 => Get_Bishop_Attacks'Access, 2 => Get_Rook_Attacks'Access))
      );
   end Generate_Moves;

end Move.Generator;
