program TetrisMatrix;
uses sysutils; 
const
 BOARD_WIDTH = 10;
 BOARD_HEIGHT = 20;

type
 TGameBoard = array[1..BOARD_HEIGHT, 1..BOARD_WIDTH] of Integer;

var
 GameGrid: TGameBoard;
 Row, Col: Integer;

begin
 Writeln('Initializing Tetris Matrix Architecture...');

for Row := 1 to BOARD_HEIGHT do
begin
 for Col := 1 to BOARD_WIDTH do
 begin
  GameGrid[Row, Col] := 0;
 end;
end;

Writeln('Matrix Basics Complete.');
ReadLn;
end.