program TetrisSkeleton;

uses crt;

const
  BOARD_WIDTH = 10;
  BOARD_HEIGHT = 20;
  MAX_SCORES = 10;

type
  TShape = array[1..4, 1..4] of Integer;
  TBoard = array[1..BOARD_HEIGHT, 1..BOARD_WIDTH] of Integer;
  TPiece = record
    Shape: TShape;
    Row, Col: Integer;
  end;
  THighScore = record
    Name: string[20];
    Score: Integer;
  end;
  THighScoreList = array[1..MAX_SCORES] of THighScore;

var
  Board: TBoard;
  Piece: TPiece;
  HighScores: THighScoreList;
  GameRunning: Boolean;
  Paused: Boolean;
  Score: Integer;
  PlayerName: string;
  Key: Char;
  i, j: Integer;

procedure InitBoard(var Board: TBoard);
begin
  for i := 1 to BOARD_HEIGHT do
    for j := 1 to BOARD_WIDTH do
      Board[i, j] := 0;
end;

procedure ClearShape(var Shape: TShape);
begin
  for i := 1 to 4 do
    for j := 1 to 4 do
      Shape[i, j] := 0;
end;

procedure SpawnPiece(var Piece: TPiece);
var
  ShapeType: Integer;
begin
  Piece.Row := 1;
  Piece.Col := 4;
  ClearShape(Piece.Shape);

  ShapeType := Random(7);

  case ShapeType of
    0:
      begin
        Piece.Shape[1, 1] := 1;
        Piece.Shape[1, 2] := 1;
        Piece.Shape[1, 3] := 1;
        Piece.Shape[1, 4] := 1;
      end;
    1:
      begin
        Piece.Shape[1, 1] := 1;
        Piece.Shape[1, 2] := 1;
        Piece.Shape[2, 1] := 1;
        Piece.Shape[2, 2] := 1;
      end;
    2:
      begin
        Piece.Shape[1, 1] := 1;
        Piece.Shape[2, 1] := 1;
        Piece.Shape[3, 1] := 1;
        Piece.Shape[3, 2] := 1;
      end;
    3:
      begin
        Piece.Shape[1, 2] := 1;
        Piece.Shape[2, 2] := 1;
        Piece.Shape[3, 1] := 1;
        Piece.Shape[3, 2] := 1;
      end;
    4:
      begin
        Piece.Shape[1, 1] := 1;
        Piece.Shape[1, 2] := 1;
        Piece.Shape[2, 2] := 1;
        Piece.Shape[2, 3] := 1;
      end;
    5:
      begin
        Piece.Shape[1, 2] := 1;
        Piece.Shape[2, 1] := 1;
        Piece.Shape[2, 2] := 1;
        Piece.Shape[3, 1] := 1;
      end;
    6:
      begin
        Piece.Shape[1, 1] := 1;
        Piece.Shape[2, 1] := 1;
        Piece.Shape[2, 2] := 1;
        Piece.Shape[3, 2] := 1;
      end;
  end;
end;

function CanPlace(const Board: TBoard; const Shape: TShape; Row, Col: Integer): Boolean;
var
  r, c: Integer;
begin
  CanPlace := True;

  for r := 1 to 4 do
    for c := 1 to 4 do
      if Shape[r, c] = 1 then
      begin
        if (Row + r - 1 < 1) or
           (Row + r - 1 > BOARD_HEIGHT) or
           (Col + c - 1 < 1) or
           (Col + c - 1 > BOARD_WIDTH) then
        begin
          CanPlace := False;
          Exit;
        end;

        if Board[Row + r - 1, Col + c - 1] <> 0 then
        begin
          CanPlace := False;
          Exit;
        end;
      end;
end;

function CanMove(const Board: TBoard; const Piece: TPiece; DeltaRow, DeltaCol: Integer): Boolean;
begin
  CanMove := CanPlace(Board, Piece.Shape, Piece.Row + DeltaRow, Piece.Col + DeltaCol);
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

procedure DrawBoard(const Board: TBoard; const Piece: TPiece; Score: Integer; Paused: Boolean);
var
  r, c, pr, pc: Integer;
  IsPieceCell: Boolean;
begin
  ClrScr;
  Writeln('Tetris Skeleton');
  Writeln('Score: ', Score);
  if Paused then
    Writeln('Status: Paused')
  else
    Writeln('Status: Playing');
  Writeln;

  for r := 1 to BOARD_HEIGHT do
  begin
    Write('|');
    for c := 1 to BOARD_WIDTH do
    begin
      IsPieceCell := False;

      for pr := 1 to 4 do
        for pc := 1 to 4 do
          if (Piece.Shape[pr, pc] = 1) and
             (Piece.Row + pr - 1 = r) and
             (Piece.Col + pc - 1 = c) then
            IsPieceCell := True;

      if (Board[r, c] <> 0) or IsPieceCell then
        Write('[]')
      else
        Write('  ');
    end;
    Writeln('|');
  end;

  Writeln;
  Writeln('Controls: A/D move, W rotate, Q quit');
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

procedure RotatePiece(var Board: TBoard; var Piece: TPiece);
var
  NewShape: TShape;
  TestPiece: TPiece;
  r, c: Integer;
begin
  ClearShape(NewShape);

  for r := 1 to 4 do
    for c := 1 to 4 do
      if Piece.Shape[r, c] = 1 then
        NewShape[c, 5 - r] := 1;

  TestPiece := Piece;
  TestPiece.Shape := NewShape;

  if CanPlace(Board, TestPiece.Shape, TestPiece.Row, TestPiece.Col) then
    Piece := TestPiece;
end;

procedure InitHighScores(var HighScores: THighScoreList);
var
  k: Integer;
begin
  for k := 1 to MAX_SCORES do
  begin
    HighScores[k].Name := '';
    HighScores[k].Score := 0;
  end;
end;

procedure InsertHighScore(var HighScores: THighScoreList; Name: string; Score: Integer);
var
  k, j: Integer;
  NewEntry: THighScore;
begin
  NewEntry.Name := Copy(Name, 1, 20);
  NewEntry.Score := Score;

  k := 1;
  while (k <= MAX_SCORES) and (HighScores[k].Score > 0) and (HighScores[k].Score >= Score) do
    Inc(k);

  if k <= MAX_SCORES then
  begin
    for j := MAX_SCORES downto k + 1 do
      HighScores[j] := HighScores[j - 1];
    HighScores[k] := NewEntry;
  end;
end;

procedure ShowHighScores(const HighScores: THighScoreList);
var
  k: Integer;
begin
  Writeln('Top 10 High Scores');
  Writeln('------------------');
  for k := 1 to MAX_SCORES do
    if HighScores[k].Score > 0 then
      Writeln(k, '. ', HighScores[k].Name, ' - ', HighScores[k].Score);
end;

begin
  Randomize;
  InitHighScores(HighScores);

  ClrScr;
  Writeln('TETRIS SKELETON');
  Writeln('----------------');
  Writeln('A simple terminal Tetris prototype.');
  Writeln;
  Writeln('Controls:');
  Writeln('  A / D  - move left / right');
  Writeln('  W      - rotate');
  Writeln('  P      - pause');
  Writeln('  Q      - quit');
  Writeln;
  Writeln('Press Enter to start...');
  ReadLn;

  InitBoard(Board);
  GameRunning := True;
  Paused := False;
  Score := 0;

  repeat
    SpawnPiece(Piece);

    if not CanPlace(Board, Piece.Shape, Piece.Row, Piece.Col) then
    begin
      GameRunning := False;
      Break;
    end;

    while GameRunning do
    begin
      if KeyPressed then
      begin
        Key := ReadKey;
        case Key of
          'a', 'A': MovePieceLeft(Board, Piece);
          'd', 'D': MovePieceRight(Board, Piece);
          'w', 'W': RotatePiece(Board, Piece);
          'p', 'P': Paused := not Paused;
          'q', 'Q':
            begin
              GameRunning := False;
              Break;
            end;
        end;
      end;

      if not GameRunning then
        Break;

      if Paused then
        Delay(200)
      else if CanMove(Board, Piece, 1, 0) then
        MovePieceDown(Board, Piece)
      else
      begin
        LockPiece(Board, Piece);
        ClearFullRows(Board, Score);
        Break;
      end;

      DrawBoard(Board, Piece, Score, Paused);
      Delay(150);
    end;

    if not GameRunning then
      Break;

    DrawBoard(Board, Piece, Score, Paused);
  until False;

  ClrScr;
  Writeln('Game Over');
  Writeln('---------');
  Writeln('Your score: ', Score);
  Writeln;

  Write('Enter your name for the high score list: ');
  ReadLn(PlayerName);
  if PlayerName = '' then
    PlayerName := 'Player';

  InsertHighScore(HighScores, PlayerName, Score);
  ShowHighScores(HighScores);

  Writeln;
  Writeln('Thanks for playing!');
  ReadLn;
end.