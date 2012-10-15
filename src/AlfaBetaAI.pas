unit AlfaBetaAI;

interface

uses
  Windows,          // GetTickCount : Used to check the duration of the calculations
  TwixtComponents;  // TBoard       : Used to calculate the next best move

const
  MAX_SEARCHDEPTH = 18;   // Maximum search depth for the a-b algorithm
  SCORE_PATH      = 5;
  SCORE_LENGTH    = 5;

type
  // MoveList; contains the next best possible moves
  TMove = record
    node : TPoint;
    value: Integer;
  end;

  TMoveList = array of TMove;

  // AlfabetaAI; calculates the next nest possible move
  TAlfaBetaAI = class( TObject )
    constructor Create();
    destructor Destroy(); override;
    procedure SetBoard( const board: TBoard );
    procedure CalculateMoveList( var movelist: TMoveList );
    function CalculateValue(): Integer;
    function CalculateLength( point: TPoint ): TPoint;
    function BestMove( time: Integer ): TPoint;
  private
    m_board     : TBoard;   // The internal board; used to calculate the next best move
    m_starttime,            // The starttime of the calculations
    m_lasttime  : Int64;    // The last duration of the calculations (in ms)
    m_depth,
    m_maxtime,
    m_timecount : Integer;
    m_timeout   : Boolean;
    function AlfaBeta( depth: Integer; alpha, beta: Integer ): Integer;
  published
    property CalculationTime: Int64 read m_lasttime;
    property Depth: Integer read m_depth;
  end;

implementation

uses
  Dialogs, SysUtils;

{
  Construct a new Twixt Artificial Intelligence
}
constructor TAlfaBetaAI.Create;
begin
  inherited;
  m_board := nil;
end;

{
  Free the memory
}
destructor TAlfaBetaAI.Destroy;
begin
  if Assigned( m_board ) then
    m_board.Destroy();
  inherited;
end;

{
  Set the board with the current layout of the game
}
procedure TAlfaBetaAI.SetBoard(const board: TBoard);
begin
  if Assigned( m_board ) then
    m_board.Destroy();
  m_board := board;
end;

{
  Calculate the next best possible moves for the current player. This is a
  subselection of all the available moves, for speed-up purposes!
}
procedure TAlfaBetaAI.CalculateMoveList( var movelist: TMoveList );
var
  x , y,
  x1, y1,
  i,  j,
  size : Integer;
  player  : TPlayer;
  blocked : Boolean;
  point, p: TPoint;
begin
  // Check all nodes within the bounds of the current player
  player := m_board.CurrentPlayer;
  SetLength( movelist, 0 );
  for y := LUTDomain[player, 0].y to LUTDomain[player, 1].y do
    for x := LUTDomain[player, 0].x to LUTDomain[player, 1].x do
      if ( m_board.GetNode( x, y ).Owner = player ) then
        for i := 0 to 7 do
        begin
          x1 := x + LUTNode[i].x;
          y1 := y + LUTNode[i].y;
          if (( x1 >= LUTDomain[ player, 0].x )  AND
              ( y1 >= LUTDomain[ player, 0].y )  AND
              ( x1 <= LUTDomain[ player, 1].x )  AND
              ( y1 <= LUTDomain[ player, 1].y )) then
            if ( m_board.GetNode( x1, y1 ).Owner = TPNone ) then
            begin
              // Add the node to the movelist if it is still available
              point.x := x;
              point.y := y;
              blocked := false;
              for j := 0 to 8 do
              begin
                p := AddPoint( point, LUTPath[i, j].p );
                if ( m_board.GetNode( p.x, p.y ).Lines[ LUTPath[i, j].d ] ) then
                begin
                  blocked := True;
                  break;
                end;
              end;

              if ( blocked = false ) then
              begin
                size := Length( movelist );
                SetLength( movelist, size + 1 );
                movelist[size].node := CreatePoint( x1, y1 );
              end;
            end;
        end;

  // Check if there is not empty
  if ( length( movelist ) = 0 ) then
  begin
    size := Length( movelist );
    SetLength( movelist, size + 1 );
    movelist[size].node := CreatePoint( BOARD_SIZE div 2 + Random(2), BOARD_SIZE div 2 + Random(2) );
  end;
end;

{
  Calculate the next best move
}
function TAlfaBetaAI.BestMove( time: Integer ): TPoint;
var
  movelist,
  movelist_temp : TMoveList;
  i, index, max,
  value         : Integer;
begin
  // Calculate the initial movelist
  CalculateMoveList( movelist );

  // Log the start time and start the calculations
  m_depth     := 1;
  m_timecount := 0;
  m_maxtime   := time;
  m_timeout   := false;
  m_starttime := GetTickCount();
  while ( m_depth <= MAX_SEARCHDEPTH ) do
  begin
    // Check if the maximum time has been exceeded
    if ( m_timeout ) then
      break;

    // Initialize
    SetLength( movelist_temp, 0 );
    max := -10000;
    for i:= 0 to Length( movelist ) -1 do
    begin
      // Do a move and calculate it's a-b value
      m_board.DoMove( movelist[i].node );
      value := -AlfaBeta( 1, -10000, -max );
      m_board.UndoMove( movelist[i].node );

      // Check if the maximum time has been exceeded
      if ( m_timeout ) then
        break;

      // Add the move to the correct position in the sorted temporary movelist
      index := Length( movelist_temp );
      SetLength( movelist_temp, index + 1 );
      while (( index > 0 ) AND ( value > movelist_temp[index-1].value )) do
      begin
        movelist_temp[ index ] := movelist_temp[ index-1 ];
        Dec( index );
      end;
      movelist_temp[ index ].node  := movelist[i].node;
      movelist_temp[ index ].value := value;

      // Set a new maximum if necessary
      if ( value > max ) then
        max := value;
    end;

    // Set the temporary movelist as new movelist for the next iteration
    if Length( movelist_temp ) > 0 then
      movelist := Copy( movelist_temp );
    Inc( m_depth );
  end;
  Dec( m_depth );

  // Log the calculation time
  m_lasttime := GetTickCount - m_starttime;

  // Return the result
  Result := movelist[0].node;
end;

{
  Perform the alfa-beta algorithm to determine the value of the current board
}
function TAlfaBetaAI.AlfaBeta( depth, alpha, beta: Integer ): Integer;
var
  movelist: TMoveList;
  i, value: Integer;
begin
  // Check if the maximum time is expired
  Inc( m_timecount );
  if (( (m_timecount and 255) = 0 ) AND
      (GetTickCount() - m_starttime >= m_maxtime )) then
    m_timeout := true

  // Check if the maximum depth has been reached
  else if ( depth >= m_depth ) then
  begin
    Result := CalculateValue();
    exit;
  end

  // Calculate the next best move at the current depth
  else
  begin
    CalculateMoveList( movelist );

    for i:= 0 to Length( movelist ) -1 do
    begin
      // Do a move and calculate it's a-b value
      m_board.DoMove( movelist[i].node );
      value := -AlfaBeta( depth +1, -beta, -alpha );
      m_board.UndoMove( movelist[i].node );

      // Check if the maximum time is expired
      if ( m_timeout ) then
      begin
        Result := alpha;
        exit;
      end

      // Check if the current value is higher than the current alpha
      else if ( value > alpha ) then
      begin
        alpha := value;
        // Check if the new alpha is higher than the beta
        if ( alpha >= beta ) then
        begin
          Result := alpha;
          exit;
        end;
      end;
    end;
  end;
  Result := alpha;
end;

{
  Calculate the value of nodes and paths of the current player
}
function TAlfaBetaAI.CalculateValue: Integer;
var
  max_size, x, y, i: Integer;
  node: PNode;
  movelist: TMoveList;
  point: TPoint;
begin
  max_size := 0;

  // Unmark all nodes owned by the player
  SetLength( movelist, 0 );
  for y := 1 to BOARD_SIZE do
    for x := 1 to BOARD_SIZE do
    begin
      // Set node to unmarked
      node := m_board.GetNode( x, y );
      if ( node.Owner = m_board.CurrentPlayer ) then
      begin
        // Add node to nodelist
        node.Marked := False;
        i := Length(movelist);
        SetLength( movelist, i +1 );
        movelist[i].node := CreatePoint(x, y);
      end;
    end;

  // Visit recursively and find the longest path
  for i := 0 to Length( movelist )-1 do
  begin
    point := CalculateLength( movelist[i].node );
    if ( point.y - point.x ) > max_size then
      max_size := point.y - point.x;
  end;

  // Return the result
  Result := -max_size;
end;

{
  Calculate the points farthest away from eachother and returns the 2 maxima
  that are relevant to the current player
}
function TAlfaBetaAI.CalculateLength( point: TPoint ): TPoint;
var
  min, max, i: Integer;
  node: PNode;
  next_point: TPoint;
begin
  // Copy the current point to max and min
  if ( m_board.CurrentPlayer = TPPlayer1 ) then
    min := point.y
  else
    min := point.x;
  max := min;

  // Search around the current node
  node := m_board.GetNode( point.x, point.y );
  if ( node.Marked = False ) then
  begin
    node.Marked := True;

    // Look in all 8 directions
    for i := 0 to 7 do
      if ( node.Lines[i] ) then
      begin
        next_point := CalculateLength( AddPoint( point, LUTNode[i] ) );
        if next_point.x < min then
          min := next_point.x;
        if next_point.y > max then
          max := next_point.y;
      end;
  end;
  Result := CreatePoint( min, max );
end;

end.
