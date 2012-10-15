unit TwixtComponents;

interface

uses
  StdCtrls, // TLabel          : The label to update when swapping the player
  ExtCtrls, // TPanel          : The panel to update when swapping the player
  Graphics, // TColor          : Specify a color for the nodes and paths
  Messages, // TMessages       : Intercept windows messages
  Controls, // TGraphicControl : Create a component with a canvas
  SysUtils, // IntToStr        : Convert Int to String
  Dialogs;  // ShowMessage     : Show error messages when necessary

const
  BOARD_SIZE = 24;      // The number of nodes on 1 line of the playfield
  NODE_SIZE  = 7;       // The size of the node in pixels
  PATH_SIZE  = 2;       // The width of the paths in pixels
  COLOR_P1   = clBlue;  // The color of player 1
  COLOR_P2   = clRed;   // The color of player 2
  COLOR_NONE = $dadada; // The color of an empty node

type
  // Forward declarations
  TGUIBoard = class;

  // Enumeration type that represents a player ( or owner of a node or line )
  TPlayer = (
    TPNone,             // No one owns this node
    TPPlayer1,          // Player1 owns this node
    TPPlayer2           // Player2 owns this node
  );

  // Point; used to store the (relative) coordinates of a node
  TPoint = record
    x,                  // X-coordinate
    y: Smallint;        // Y-coordinate
  end;

  // Path; used to store information about a twixt path
  TPath = record
    p1,                 // 1st coordinate
    p2 : TPoint;        // 2nd coordinate
  end;

  // TLutPath; used to store the (relative) coordinates to blocking path lines
  TLUTPath = record
    p: TPoint;          // Point
    d: SmallInt;        // Direction
  end;

  // Node; used to store information about a twixt node
  TNode = record
    Owner : TPlayer;                // Owner of the node
    Marked: Boolean;                // Special tag that is used to recursively search the playfield
    Lines : array[0..7] of Boolean; // Is there a line to another node in a specific direction
  end;
  PNode = ^TNode;

  // Board; used to store information about the playfield and it's nodes
  TBoard = class( TObject )
    constructor Create();
    procedure Clear();
    function Clone(): TBoard;
    function DoMove( const point: TPoint ): Integer;
    procedure UndoMove( const point: TPoint );
    procedure SwapPlayer();
    procedure SetSubject( const subject: TGUIBoard );
    function GetNode( x, y: Integer ): PNode;
  private
    m_nodes         : array[1..BOARD_SIZE, 1..BOARD_SIZE] of TNode;
    m_currentPlayer : TPlayer;
    m_subject       : TGUIBoard;
  published
    property CurrentPlayer: TPlayer read m_currentPlayer write m_currentPlayer;
  end;

  // The graphical component that represents a twixt node
  TGUINode = class(TGraphicControl)
  private
    m_mousehover: boolean;
    m_color     : TColor;
    m_point     : TPoint;
    property OnClick;
    property Color: TColor read m_color write m_color;
    property Point: TPoint read m_point write m_point;
    constructor Create(); reintroduce;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint(); override;
  end;

  // The graphical component that represents the twixt playfield
  TGUIBoard = class(TCustomPanel)
    constructor Create(); reintroduce;
    destructor  Destroy(); override;
    function  GetBoard(): TBoard;
    procedure Clear();
    procedure DoMove( const point: TPoint );
    procedure UndoLastMove();
    procedure AddPath( const path: TPath );
    procedure RemovePath( const point: TPoint );
    procedure SetNodeColor( const point: TPoint; const player: TPlayer );
    procedure SwapPlayer();
    procedure UpdatePlayerInfo();
    class function GetPlayerColor(const player: TPlayer): TColor;
  protected
    procedure Resize(); override;
    procedure Paint(); override;
  private
    m_nodes: array[1..BOARD_SIZE, 1..BOARD_SIZE] of TGUINode;
    m_paths: array of TPath;
    m_panelCurPlayer: TPanel;
    m_labelCurPlayer: TLabel;
    m_listboxMoves  : TListBox;
    m_board: TBoard;
    procedure ChangePlayerPanel( const pnl: TPanel );
    procedure ChangePlayerLabel( const lbl: TLabel );
    procedure NodeClicked( Sender: TObject );
  published
    property Anchors;
    property CurrentPlayerSwatch: TPanel read m_panelCurPlayer write ChangePlayerPanel;
    property CurrentPlayerText  : TLabel read m_labelCurPlayer write ChangePlayerLabel;
    property HistoryListbox     : TListbox read m_listboxMoves write m_listboxMoves;
  end;

  // Forward declarations
  function CreatePoint( x, y: SmallInt ): TPoint;
  function AddPoint   ( p1, p2: TPoint ): TPoint;
  function CreatePath ( p1, p2: TPoint ): TPath;

const
  LUTDomain: array[TPNone..TPPlayer2, 0..1] of TPoint =
    (((x:-1 ; y:-1 ), (x:-1            ; y:-1            )),
     ((x: 2 ; y: 1 ), (x: BOARD_SIZE-1 ; y: BOARD_SIZE   )),
     ((x: 1 ; y: 2 ), (x: BOARD_SIZE   ; y: BOARD_SIZE -1)));
  LUTNode: array[0..7] of TPoint =
    ((x: 1; y:-2), (x: 2; y:-1), (x: 2; y: 1), (x: 1; y: 2),
     (x:-1; y: 2), (x:-2; y: 1), (x:-2; y:-1), (x:-1; y:-2));
  LUTPath: array[0..7, 0..8] of TLUTPath =
    (((p:(x: 2; y:-1); d: 6), (p:(x: 1; y:-1); d: 7), (p:(x: 2; y:-2); d: 5),
      (p:(x: 1; y:-1); d: 6), (p:(x: 1; y: 0); d: 7), (p:(x: 2; y: 0); d: 6),
      (p:(x: 1; y:-1); d: 5), (p:(x: 1; y: 1); d: 7), (p:(x: 1; y: 0); d: 6)),
     ((p:(x: 1; y: 0); d: 6), (p:(x: 1; y: 0); d: 7), (p:(x: 1; y: 0); d: 0),
      (p:(x: 1; y:-1); d: 4), (p:(x: 1; y:-1); d: 2), (p:(x: 1; y:-1); d: 3),
      (p:(x: 1; y: 1); d: 7), (p:(x: 2; y: 0); d: 6), (p:(x: 2; y: 0); d: 7)),
     ((p:(x: 1; y: 0); d: 5), (p:(x: 1; y: 0); d: 4), (p:(x: 1; y: 0); d: 3),
      (p:(x: 1; y: 1); d: 7), (p:(x: 1; y: 1); d: 1), (p:(x: 1; y: 1); d: 0),
      (p:(x: 1; y:-1); d: 4), (p:(x: 2; y: 0); d: 5), (p:(x: 2; y: 0); d: 4)),
     ((p:(x: 2; y: 1); d: 5), (p:(x: 1; y: 1); d: 4), (p:(x: 2; y: 2); d: 6),
      (p:(x: 1; y: 1); d: 5), (p:(x: 1; y: 0); d: 4), (p:(x: 2; y: 0); d: 5),
      (p:(x: 1; y: 1); d: 6), (p:(x: 1; y:-1); d: 4), (p:(x: 1; y: 0); d: 5)),
     ((p:(x:-2; y: 1); d: 2), (p:(x:-1; y: 1); d: 3), (p:(x:-2; y: 2); d: 1),
      (p:(x:-1; y: 1); d: 2), (p:(x:-1; y: 0); d: 3), (p:(x:-2; y: 0); d: 2),
      (p:(x:-1; y: 1); d: 1), (p:(x:-1; y:-1); d: 3), (p:(x:-1; y: 0); d: 2)),
     ((p:(x:-1; y: 0); d: 2), (p:(x:-1; y: 0); d: 3), (p:(x:-1; y: 0); d: 4),
      (p:(x:-1; y: 1); d: 0), (p:(x:-1; y: 1); d: 6), (p:(x:-1; y: 1); d: 7),
      (p:(x:-1; y:-1); d: 3), (p:(x:-2; y: 0); d: 2), (p:(x:-2; y: 0); d: 3)),
     ((p:(x:-1; y: 0); d: 1), (p:(x:-1; y: 0); d: 0), (p:(x:-1; y: 0); d: 7),
      (p:(x:-1; y:-1); d: 3), (p:(x:-1; y:-1); d: 5), (p:(x:-1; y:-1); d: 4),
      (p:(x:-1; y: 1); d: 0), (p:(x:-2; y: 0); d: 1), (p:(x:-2; y: 0); d: 0)),
     ((p:(x:-2; y:-1); d: 1), (p:(x:-1; y:-1); d: 0), (p:(x:-2; y:-2); d: 2),
      (p:(x:-1; y:-1); d: 1), (p:(x:-1; y: 0); d: 0), (p:(x:-2; y: 0); d: 1),
      (p:(x:-1; y:-1); d: 2), (p:(x:-1; y: 1); d: 0), (p:(x:-1; y: 0); d: 1)));

implementation

{
  Create a TPoint from two integers
}
function CreatePoint( x, y: SmallInt ): TPoint;
var
  point: TPoint;
begin
  point.x := x;
  point.y := y;
  Result := point;
end;

{
  Add two TPoints and return the sum
}
function AddPoint( p1, p2: TPoint ): TPoint;
var
  point: TPoint;
begin
  point.x := p1.x + p2.x;
  point.y := p1.y + p2.y;
  Result := point;
end;

{
  Create a TPath from two integers
}
function CreatePath( p1, p2: TPoint ): TPath;
var
  path: TPath;
begin
  path.p1 := p1;
  path.p2 := p2;
  Result := path;
end;

{
********************************************************************************
* TBoard: An internal structure to store a twixt playfield                     *
********************************************************************************
}

{
  Create a new board
}
constructor TBoard.Create;
begin
  m_subject       := nil;
  m_currentPlayer := TPPlayer1;
  Clear();
end;

{
  Return a clone of the current board
}
function TBoard.Clone: TBoard;
var
  board: TBoard;
  x, y: Integer;
begin
  // Copy all content
  board := TBoard.Create();
  for y := 1 to BOARD_SIZE do
    for x := 1 to BOARD_SIZE do
      board.m_nodes[x, y] := m_nodes[x, y];
  board.CurrentPlayer := CurrentPlayer;
  Result := board;
end;

{
  Clear all nodes
}
procedure TBoard.Clear();
var
  i, x, y: Integer;
begin
  // Clear the nodes on the board
  for y := 1 to BOARD_SIZE do
    for x := 1 to BOARD_SIZE do
    begin
      // Clear the node
      m_nodes[x, y].Owner  := TPNone;
      m_nodes[x, y].Marked := False;
      for i := 0 to 7 do
        m_nodes[x, y].Lines[i] := False;

      // Clear the GUI node
      if Assigned( m_subject ) then
        m_subject.SetNodeColor( CreatePoint(x, y), TPNone );
    end;

  // Reinitialize the board
  m_currentPlayer := TPPlayer1;
end;

{
  Add a node to the board
  Returns the number of paths created, or -1 if invalid move
}
function TBoard.DoMove(const point: TPoint): Integer;
var
  path_count : Integer;
  i, j, x, y : Integer;
  node       : ^TNode;
  p          : TPoint;
  blocked    : Boolean;
begin
  node := @m_nodes[ point.x ][ point.y ];
  // Check if the node is available
  if node.Owner = TPNone then
  begin
    // Check if the node is in the domain for the current player
    if (( point.x < LUTDomain[ m_currentPlayer, 0].x ) OR
        ( point.y < LUTDomain[ m_currentPlayer, 0].y ) OR
        ( point.x > LUTDomain[ m_currentPlayer, 1].x ) OR
        ( point.y > LUTDomain[ m_currentPlayer, 1].y )) then
    begin
      Result := -1;
      exit;
    end;
    // Take ownership of the node and add it to the GUI
    node.Owner := m_currentPlayer;
    if Assigned( m_subject ) then
      m_subject.SetNodeColor( point, m_currentPlayer );
    // Check if the new node connects to other nodes
    path_count := 0;
    for i := 0 to 7 do
    begin
      x := point.x + LUTNode[i].x;
      y := point.y + LUTNode[i].y;
      // Check if the new coordinate isn't out of bounds
      if (( x >= 1 ) AND ( x <= BOARD_SIZE ) AND
          ( y >= 1 ) AND ( y <= BOARD_SIZE )) then
          // Check if the next node is also owned by the current player
          if m_nodes[ x, y ].Owner = m_currentPlayer then
          begin
            // Check if the new path is blocked by another path
            blocked := false;
            for j := 0 to 8 do
            begin
              p := AddPoint( point, LUTPath[i, j].p );
              if ( m_nodes[ p.x, p.y ].Lines[ LUTPath[i, j].d ] ) then
              begin
                blocked := True;
                break;
              end;
            end;
            // If the path isn't blocked then create a new path
            if ( blocked = false ) then
            begin
              m_nodes[ point.x, point.y ].Lines[i] := True;
              m_nodes[ x, y ].Lines[(i + 4) mod 8] := True;
              if Assigned( m_subject ) then
                m_subject.AddPath( CreatePath( point, CreatePoint( x, y )));
              Inc( path_count );
            end;
          end;
    end;
    // Change the current player
    SwapPlayer();
    Result := path_count;
  end
  else
    Result := -1;
end;

{
  Remove a node from the board
}
procedure TBoard.UndoMove(const point: TPoint);
var
  node, node2: ^TNode;
  i: Integer;
begin
  node := @m_nodes[ point.x ][ point.y ];
  node.Owner := TPNone;

  // Remove paths to other lines
  for i := 0 to 7 do
    if node.Lines[ i ] = True then
    begin
      node.Lines[ i ] := False;
      node2 := @m_nodes[ point.x + LUTNode[ i ].x, point.y + LUTNode[ i ].y  ];
      node2.Lines[ (i + 4) mod 8 ] := false;
    end;

  // Update the GUI
  if Assigned( m_subject ) then
  begin
    m_subject.SetNodeColor( point, TPNone );
    m_subject.RemovePath( point );
  end;
end;

{
  Swap the current player
}
procedure TBoard.SwapPlayer();
begin
  // Change the current player
  case m_currentPlayer of
    TPPlayer1:
      m_currentPlayer := TPPlayer2;
    TPPlayer2:
      m_currentPlayer := TPPlayer1;
    else
      raise Exception.Create( '[TBoard.SwapPlayer] Invalid current player' );
  end;

  // Update gui information if necessary
  if Assigned( m_subject ) then
    m_subject.UpdatePlayerInfo();
end;

{
  Set the subject, that will be updated of changes on the board
}
procedure TBoard.SetSubject(const subject: TGUIBoard);
begin
  m_subject := subject;
end;

function TBoard.GetNode(x, y: Integer): PNode;
begin
  Result := @m_nodes[ x, y ];
end;

{
********************************************************************************
* TGUINode: Graphical User Interface Component to display a twixt node         *
********************************************************************************
}

{
  Detect if the mouse is over this component
}
procedure TGUINode.CMMouseEnter(var Msg: TMessage);
begin
  m_mousehover := true;
  Invalidate;
end;

{
  Detect if this mouse has left the component
}
procedure TGUINode.CMMouseLeave(var Msg: TMessage);
begin
  m_mousehover := false;
  Invalidate;
end;

{
  Construct a new twixt node.
}
constructor TGUINode.Create();
begin
  inherited Create( nil );
  Width  := NODE_SIZE;
  Height := NODE_SIZE;
  Color  := COLOR_NONE;
  m_mousehover := false;
end;

{
  Paint the twixt node.
}
procedure TGUINode.Paint;
begin
  inherited;
  // Draw an ellipse
  with Canvas do
  begin
    // See if the mouse is on this node
    if ( m_mousehover ) then
      Brush.Color := clBlack
    else
      Brush.Color := m_color;
    Ellipse( 0, 0, Width, Height );
  end;
end;

{
********************************************************************************
* TGUIBoard: Graphical User Interface Component to display a twixt playfield   *
********************************************************************************
}

{
  Create a BOARD_SIZE x BOARD_SIZE twixt-board.
}
constructor TGUIBoard.Create();
var
  x, y: Integer;
begin
  inherited Create(nil);

  // Set a default appearance
  Width  := 500;
  Height := 500;
  ShowHint := true;
  BevelInner := bvLowered;

  // Create all nodes
  for y := 1 to BOARD_SIZE do
    for x := 1 to BOARD_SIZE do
    begin
      // Do not create the corners of the playfield
      if not (((x = 1)          AND ((y = 1) OR (y = BOARD_SIZE)))  OR
              ((x = BOARD_SIZE) AND ((y = 1) OR (y = BOARD_SIZE)))) then
      begin
        // Create a new node with NODE_SIZE x NODE_SIZE dimensions
        m_nodes[x, y] := TGUINode.Create();
        with m_nodes[x, y] do
        begin
          Parent  := self;
          Point   := CreatePoint( x, y );
          OnClick := NodeClicked;
          Hint    := char(ord('A') + (x - 1)) + IntToStr(y);
        end;
      end;
    end;

  // Create the board to manage the twixt playfield
  m_board := TBoard.Create();
  m_board.SetSubject( self );
  SetLength( m_paths, 0 );

  // Position the nodes at the correct position
  UpdatePlayerInfo();
  Resize();
end;

{
  Free the memory.
}
destructor TGUIBoard.Destroy;
var
  x, y: Integer;
begin
  // Destroy all nodes
  for y := 1 to BOARD_SIZE do
    for x := 1 to BOARD_SIZE do
      if Assigned( m_nodes[x, y] ) then
        m_nodes[x, y].Destroy;
  m_board.Destroy();
  inherited;
end;

{
  Clear the entire playfield
}
procedure TGUIBoard.Clear;
begin
  // Clear all internal nodes
  m_board.Clear();
  SetLength( m_paths, 0 );
  Invalidate;

  // Clear history
  if Assigned( m_listboxMoves ) then
    m_listboxMoves.Clear();

  // Reset the current player
  UpdatePlayerInfo();
end;

{
  Code to execute when a node has been clicked
}
procedure TGUIBoard.NodeClicked(Sender: TObject);
var
  point: TPoint;
begin
  point := TGUINode(Sender).Point;
  DoMove( point );
end;

{
  Try to let the current player obtain the node at the given point. Gives a
  message dialog if the point is unavailable to the player.
}
procedure TGUIBoard.DoMove( const point: TPoint );
var
  path_count, i: Integer;
  msg: String;
begin
  // Check if the point is at valid position in the board
  if (( point.x >= 1 ) AND ( point.x <= BOARD_SIZE )  AND
      ( point.y >= 1 ) AND ( point.y <= BOARD_SIZE )) then
  begin
    // Send the move to the internal board
    msg := chr( ord('A') + point.x - 1) + IntToStr( point.y );
    path_count := m_board.DoMove( point );

    // Check if the move was valid
    if ( path_count = -1 ) then
      MessageDlg( 'Invalid Move:' + #13#10 + 'The node at coordinate ' + msg + ' is not available!', mtError, [mbOk], 0)
    else
    begin
      // Add the move to the history listbox
      for i := 1 to path_count do
        msg := msg + '*';
      m_listboxMoves.AddItem( msg, m_nodes[ point.x, point.y ] );
    end;
  end
  else
    MessageDlg( 'Invalid Move:' + #13#10 + 'The node at coordinate ['
      + IntToStr( point.x )+ ',' + IntToStr ( point.y )
      + '] is outside the board!', mtError, [mbOk], 0);
end;

{
  Undo the last move
}
procedure TGUIBoard.UndoLastMove();
var
  index: Integer;
  point: TPoint;
begin
  index := m_listboxMoves.Items.Count -1;
  if ( index >= 0 ) then
  begin
    point := TGUINode(m_listboxMoves.Items.Objects[ index ]).m_point;
    m_listboxMoves.Items.Delete( index );
    m_board.UndoMove( point );
    m_board.SwapPlayer();
  end;
end;

{
  Add a new path to be displayed
}
procedure TGUIBoard.AddPath( const path: TPath );
var
  count: Integer;
begin
  count := Length( m_paths );
  SetLength( m_paths, count + 1 );
  m_paths[ count ] := path;
  Invalidate;
end;

{
  Remove the paths surrounding  specific node
}
procedure TGUIBoard.RemovePath( const point: TPoint );
var
  i: Integer;
begin
  // Search from back to front and delete the paths containing the point
  for i := Length( m_paths ) -1 downto 0 do
  begin
    if ((( m_paths[i].p1.x = point.x ) AND ( m_paths[i].p1.y = point.y )) OR
        (( m_paths[i].p2.x = point.x ) AND ( m_paths[i].p2.y = point.y ))) then
      SetLength( m_paths, i )
    else
      break;
  end;

  // Repaint in case of deletion
  Invalidate();
end;

{
  Set the node at the specified point to color of the specified player
}
procedure TGUIBoard.SetNodeColor( const point: TPoint; const player: TPlayer );
begin
  // Check if the node exists
  if Assigned( m_nodes[ point.x, point.y ] ) then
  begin
    m_nodes[ point.x, point.y ].Color := GetPlayerColor( player );
    m_nodes[ point.x, point.y ].Invalidate;
  end;
end;

{
  Swap the current player.
}
procedure TGUIBoard.SwapPlayer();
begin
  m_board.SwapPlayer();
end;

{
  Draw the grid and all visual helpers
}
procedure TGUIBoard.Paint;
var
  node_offset_x, node_offset_y,
  offset_x, offset_y,
  inc_x1, inc_x2,
  inc_y1, inc_y2: double;
  point: TPoint;
  i: Integer;
begin
  inherited;
  // Calculate the offset between nodes
  node_offset_x := Width  / BOARD_SIZE;
  node_offset_y := Height / BOARD_SIZE;
  offset_x := 1.5 * node_offset_x;
  offset_y := 1.5 * node_offset_y;
  inc_x1  := (BOARD_SIZE - 2) * node_offset_x;
  inc_y1  := (BOARD_SIZE - 2) * ( 0.5 * node_offset_y );
  inc_x2  := (BOARD_SIZE - 2) * ( 0.5 * node_offset_x );
  inc_y2  := (BOARD_SIZE - 2) * node_offset_y;
  with Canvas do
  begin
    // Draw the grid help lines
    Pen.Width := 1;
    Pen.Color := clLtGray;
    MoveTo( Round( offset_x ), Round( offset_y ));
    LineTo( Round( offset_x + inc_x1 ), Round( offset_y + inc_y1 ));
    MoveTo( Round( offset_x ), Round( offset_y ));
    LineTo( Round( offset_x + inc_x2 ), Round( offset_y + inc_y2 ));
    MoveTo( Round( Width - offset_x ), Round( offset_y ));
    LineTo( Round( Width - ( offset_x + inc_x1 )), Round( offset_y + inc_y1 ));
    MoveTo( Round( Width - offset_x ), Round( offset_y ));
    LineTo( Round( Width - ( offset_x + inc_x2 )), Round( offset_y + inc_y2 ));
    MoveTo( Round( offset_x ), Round( Height - offset_y ));
    LineTo( Round( offset_x + inc_x1 ), Round( Height - ( offset_y + inc_y1 )));
    MoveTo( Round( offset_x ), Round( Height - offset_y ));
    LineTo( Round( offset_x + inc_x2 ), Round( Height - ( offset_y + inc_y2 )));
    MoveTo( Round( Width - offset_x ), Round( Height - offset_y ));
    LineTo( Round( Width - ( offset_x + inc_x1 )), Round( Height - ( offset_y + inc_y1 )));
    MoveTo( Round( Width - offset_x ), Round( Height - offset_y ));
    LineTo( Round( Width - ( offset_x + inc_x2 )), Round( Height - ( offset_y + inc_y2 )));
    // Draw the border lines
    Pen.Width := 2;
    Pen.Color := COLOR_P1;
    MoveTo( Round( node_offset_x ), Round( node_offset_y ));
    LineTo( Round( Width - node_offset_x ), Round( node_offset_y ));
    Pen.Color := COLOR_P2;
    LineTo( Round( Width - node_offset_x ), Round( Height - node_offset_y ));
    Pen.Color := COLOR_P1;
    LineTo( Round( node_offset_x ), Round( Height - node_offset_y ));
    Pen.Color := COLOR_P2;
    LineTo( Round( node_offset_x ), Round( node_offset_y ));
    // Draw the paths
    Pen.Width := PATH_SIZE;
    for i := 0 to Length( m_paths ) -1 do
    begin
      point := m_paths[i].p1;
      Pen.Color := m_nodes[ point.x, point.y ].Color;
      MoveTo( Round((point.x - 0.5) * node_offset_x), Round((point.y - 0.5) * node_offset_y) );
      point := m_paths[i].p2;
      LineTo( Round((point.x - 0.5) * node_offset_x), Round((point.y - 0.5) * node_offset_y) );
    end;
  end;
end;

{
  Resize the board and reposition all the nodes
}
procedure TGUIBoard.Resize;
var
  x, y: Integer;
  offset_x, offset_y: double;
begin
  inherited;
  // Calculate node offset
  offset_x := ( Width / BOARD_SIZE );
  offset_y := ( Height / BOARD_SIZE );
  // Reset all nodes
  for y := 1 to BOARD_SIZE do
    for x := 1 to BOARD_SIZE do
      if Assigned( m_nodes[x, y] ) then
      begin
        m_nodes[x, y].Left := Round((offset_x - NODE_SIZE) / 2 + offset_x * (x - 1));
        m_nodes[x, y].Top  := Round((offset_y - NODE_SIZE) / 2 + offset_y * (y - 1));
      end;
  // Redraw the board
  Invalidate;
end;

{
  Update the player information
}
procedure TGUIBoard.UpdatePlayerInfo;
begin
  // Update the color swatch
  if Assigned( m_panelCurPlayer ) then
    m_panelCurPlayer.Color := GetPlayerColor( m_board.CurrentPlayer );

  // Update the name of the player
  if Assigned( m_labelCurPlayer ) then
    case m_board.CurrentPlayer of
      TPPlayer1:
        m_labelCurPlayer.Caption := 'Player 1';
      TPPlayer2:
        m_labelCurPlayer.Caption := 'Player 2';
      else
        raise Exception.Create( '[TGUIBoard.UpdatePlayerInfo] Invalid current player' );
    end;
end;

{
  Get the color of the current player/owner
}
class function TGUIBoard.GetPlayerColor(const player: TPlayer): TColor;
begin
  case player of
    TPPlayer1:
      Result := COLOR_P1;
    TPPlayer2:
      Result := COLOR_P2;
    else
      Result := COLOR_NONE;
  end;
end;

{
  Change the player label
}
procedure TGUIBoard.ChangePlayerLabel(const lbl: TLabel);
begin
  m_labelCurPlayer := lbl;
  UpdatePlayerInfo();
end;

{
  Change the player swatch
}
procedure TGUIBoard.ChangePlayerPanel(const pnl: TPanel);
begin
  m_panelCurPlayer := pnl;
  UpdatePlayerInfo();
end;

{
  Return the current internal board
}
function TGUIBoard.GetBoard: TBoard;
begin
  Result := m_board.Clone();
end;

end.
