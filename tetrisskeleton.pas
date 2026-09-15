program TetrisSkeleton;

uses crt;

const
  BOARD_WIDTH = 10;
  BOARD_HEIGHT = 20;

type
  TBoard = array[1..BOARD_HEIGHT, 1..BOARD_WIDTH] of Integer;
  TPiece = record
    Shape: array[1..4, 1..4] of Integer;
    Row, Col: Integer;
  end;

var
  Board: TBoard;
  Piece: TPiece;
  i, j: Integer;
  Key: Char;
  GameRunning: Boolean;
  PiecesPlaced: Integer;
  Score: Integer;

procedure InitBoard(var Board: TBoard);
begin
  for i := 1 to BOARD_HEIGHT do
    for j := 1 to BOARD_WIDTH do
      Board[i, j] := 0;
end;

procedure SpawnPiece(var Piece: TPiece);
var
  ShapeType: Integer;
begin
  Piece.Row := 1;
  Piece.Col := 4;

  for i := 1 to 4 do
    for j := 1 to 4 do
      Piece.Shape[i, j] := 0;

  ShapeType := Random(2);

  if ShapeType = 0 then
  begin
    Piece.Shape[1, 1] := 1;
    Piece.Shape[1, 2] := 1;
    Piece.Shape[1, 3] := 1;
    Piece.Shape[1, 4] := 1;
  end
  else
  begin
    Piece.Shape[1, 1] := 1;
    Piece.Shape[1, 2] := 1;
    Piece.Shape[2, 1] := 1;
    Piece.Shape[2, 2] := 1;
  end;
end;

function CanMove(const Board: TBoard; const Piece: TPiece; DeltaRow, DeltaCol: Integer): Boolean;
var
  r, c: Integer;
begin
  CanMove := True;

  for r := 1 to 4 do
    for c := 1 to 4 do
      if Piece.Shape[r, c] = 1 then
      begin
        if (Piece.Row + r - 1 + DeltaRow < 1) or
           (Piece.Row + r - 1 + DeltaRow > BOARD_HEIGHT) or
           (Piece.Col + c - 1 + DeltaCol < 1) or
           (Piece.Col + c - 1 + DeltaCol > BOARD_WIDTH) then
        begin
          CanMove := False;
          Exit;
        end;

        if Board[Piece.Row + r - 1 + DeltaRow, Piece.Col + c - 1 + DeltaCol] <> 0 then
        begin
          CanMove := False;
          Exit;
        end;
      end;
end;

procedure LockPiece(var Board: TBoard; const Piece: TPiece);
var
  r, c: Integer;
begin
  for r := 1 to 4 do
    for c := 1 to 4 do
      if Piece.Shape[r, c] = 1 then
        Board[Piece.Row + r - 1, Piece.Col + c - 1] := 1;
end;

function IsRowFull(const Board: TBoard; Row: Integer): Boolean;
var
  c: Integer;
begin
  IsRowFull := True;
  for c := 1 to BOARD_WIDTH do
    if Board[Row, c] = 0 then
    begin
      IsRowFull := False;
      Exit;
    end;
end;

procedure ClearFullRows(var Board: TBoard; var Score: Integer);
var
  row, col, targetRow: Integer;
  Cleared: Integer;
begin
  Cleared := 0;

  for row := BOARD_HEIGHT downto 1 do
    if IsRowFull(Board, row) then
    begin
      Inc(Cleared);
      for targetRow := row downto 2 do
        for col := 1 to BOARD_WIDTH do
          Board[targetRow, col] := Board[targetRow - 1, col];

      for col := 1 to BOARD_WIDTH do
        Board[1, col] := 0;
    end;

  if Cleared > 0 then
    Score := Score + Cleared * 100;
end;

procedure DrawBoard(const Board: TBoard; const Piece: TPiece);
var
  r, c, pr, pc: Integer;
  IsPieceCell: Boolean;
begin
  for r := 1 to BOARD_HEIGHT do
  begin
    for c := 1 to BOARD_WIDTH do
    begin
      IsPieceCell := False;

      for pr := 1 to 4 do
        for pc := 1 to 4 do
          if (Piece.Shape[pr, pc] = 1) and
             (Piece.Row + pr - 1 = r) and
             (Piece.Col + pc - 1 = c) then
            IsPieceCell := True;

      if Board[r, c] <> 0 then
        Write('#')
      else if IsPieceCell then
        Write('#')
      else
        Write('.');
    end;
    Writeln;
  end;
  Writeln;
end;

procedure MovePieceDown(var Board: TBoard; var Piece: TPiece);
begin
  if CanMove(Board, Piece, 1, 0) then
    Piece.Row := Piece.Row + 1;
end;

procedure MovePieceLeft(var Board: TBoard; var Piece: TPiece);
begin
  if CanMove(Board, Piece, 0, -1) then
    Piece.Col := Piece.Col - 1;
end;

procedure MovePieceRight(var Board: TBoard; var Piece: TPiece);
begin
  if CanMove(Board, Piece, 0, 1) then
    Piece.Col := Piece.Col + 1;
end;

procedure RotatePiece(var Piece: TPiece);
var
  NewShape: array[1..4, 1..4] of Integer;
  r, c: Integer;
begin
  for r := 1 to 4 do
    for c := 1 to 4 do
      NewShape[r, c] := 0;

  for r := 1 to 4 do
    for c := 1 to 4 do
      if Piece.Shape[r, c] = 1 then
        NewShape[c, 5 - r] := 1;

  Piece.Shape := NewShape;
end;

begin
  InitBoard(Board);
  GameRunning := True;
  PiecesPlaced := 0;
  Score := 0;

  Writeln('Controls:');
  Writeln('  A / D  - move left / right');
  Writeln('  W      - rotate piece');
  Writeln('  Q      - quit');
  Writeln;
  while GameRunning and (PiecesPlaced < 3) do
  begin
    Inc(PiecesPlaced);
    SpawnPiece(Piece);

    if not CanMove(Board, Piece, 0, 0) then
    begin
      GameRunning := False;
      Break;
    end;

    while CanMove(Board, Piece, 1, 0) do
    begin
      if KeyPressed then
      begin
        Key := ReadKey;
        case Key of
          'a', 'A': MovePieceLeft(Board, Piece);
          'd', 'D': MovePieceRight(Board, Piece);
          'w', 'W': RotatePiece(Piece);
          'q', 'Q':
            begin
              GameRunning := False;
              Break;
            end;
        end;
      end;

      if not GameRunning then
        Break;

      if CanMove(Board, Piece, 1, 0) then
        MovePieceDown(Board, Piece);

      ClrScr;
      DrawBoard(Board, Piece);
      Delay(150);
    end;

    if not GameRunning then
      Break;

    LockPiece(Board, Piece);
    ClearFullRows(Board, Score);

    ClrScr;
    DrawBoard(Board, Piece);
    Writeln('Piece locked in place.');
    Writeln('Score: ', Score);
  end;

  if GameRunning then
    Writeln('Demo finished.')
  else
    Writeln('Game over.');

  Writeln('Final score: ', Score);

  ReadLn;
end.