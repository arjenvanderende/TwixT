unit FormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, StdCtrls, ComCtrls, Mask, StrUtils,
  TwixtComponents, AlfaBetaAI;

type
  TMainForm = class(TForm)
    PanelOptions    : TPanel;
    PanelCurPlayer  : TPanel;
    GroupCurPlayer  : TGroupBox;
    GroupMoves      : TGroupBox;
    GroupAI         : TGroupBox;
    ListBoxHistory  : TListBox;
    ButtonAdd       : TButton;
    ButtonUndo      : TButton;
    ButtonHint      : TButton;
    ButtonClear     : TButton;
    ButtonSwapPlayer: TButton;
    LabelCurPlayer  : TLabel;
    LabelMaxTime    : TLabel;
    EditInput       : TMaskEdit;
    StatusBar: TStatusBar;
    MaxTimeEdit: TMaskEdit;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSwapPlayerClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonUndoClick(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure EditInputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ButtonHintClick(Sender: TObject);
  private
    m_TwixtBoard : TGUIBoard;
    m_TwixtAI    : TAlfaBetaAI;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{
  Create the form and the playfield
}
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Show hints throughout the application
  Application.ShowHint := true;

  // Create the twixtboard
  m_TwixtBoard        := TGUIBoard.Create();
  m_TwixtBoard.Left   := 25;
  m_TwixtBoard.Top    := 25;
  m_TwixtBoard.Width  := 480;
  m_TwixtBoard.Height := 480;
  m_TwixtBoard.Parent := MainForm;

  // Couple the twixtboard to the currentplayer components
  m_TwixtBoard.Anchors := [akTop, akLeft, akRight, akBottom];
  m_TwixtBoard.CurrentPlayerSwatch := PanelCurPlayer;
  m_TwixtBoard.CurrentPlayerText   := LabelCurPlayer;
  m_TwixtBoard.HistoryListbox      := ListBoxHistory;

  // Initialize the artificial intelligence
  m_TwixtAI := TAlfaBetaAI.Create();
  Randomize;
end;

{
  Free the memory
}
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  m_TwixtAI.Destroy();
  m_TwixtBoard.Destroy();
end;

{
  Add the node-coordinate in the inputfield to the playfield
}
procedure TMainForm.ButtonAddClick(Sender: TObject);
var
  x, y: String;
  point: TPoint;
begin
  // Copy the x and y coordinate and check if they are not empty
  x := Trim( LeftStr( EditInput.Text, 1 ));
  y := Trim( MidStr ( EditInput.Text, 3, 2));
  if (( x = '' ) OR ( y = '' )) then
    MessageDlg( 'Invalid Move:' + #13#10 + 'The coordinate has not been fully entered!', mtError, [mbOk], 0)
  else
  begin
    // Convert the text to a twixt node coordinate
    point.x := ord( x[1] ) - (ord( 'A' ) - 1);
    point.y := StrToInt( y );
    m_TwixtBoard.DoMove( point );
  end;
  EditInput.Text := '';
end;

{
  Undo the last move
}
procedure TMainForm.ButtonUndoClick(Sender: TObject);
begin
  m_TwixtBoard.UndoLastMove();
end;

{
  Clear the playfield
}
procedure TMainForm.ButtonClearClick(Sender: TObject);
begin
  m_TwixtBoard.Clear();
end;

{
  Swap the current player
}
procedure TMainForm.ButtonSwapPlayerClick(Sender: TObject);
begin
  m_TwixtBoard.SwapPlayer();
end;

{
  Let the artificial intelligence calculate the next best move
}
procedure TMainForm.ButtonHintClick(Sender: TObject);
var
  time: String;
begin
  // Check if a valid time has been entered
  time := Trim( MaxTimeEdit.Text );
  if ( time = '') then
  begin
    StatusBar.Panels.Items[0].Text := 'Invalid max. time';
    Beep;
  end
  else
  begin
    // Display information in statusbar
    StatusBar.Panels.Items[0].Text := 'Thinking';
    Application.ProcessMessages();

    // Calculate the next best move
    m_TwixtAI.SetBoard( m_TwixtBoard.GetBoard() );
    m_TwixtBoard.DoMove( m_TwixtAI.BestMove( StrToInt( time )));

{
    point := m_TwixtAI.CalculateLength( CreatePoint( 5, 5 ) );
    ShowMessage( IntToStr( point.y - point.x ) );

    m_TwixtAI.SetBoard( m_TwixtBoard.GetBoard() );
}
    // Display calculation information in statusbar
    StatusBar.Panels.Items[0].Text := 'Ready';
    StatusBar.Panels.Items[1].Text := 'Time: ' + FloatToStr( m_TwixtAI.CalculationTime / 1000 ) + ' ms';
    StatusBar.Panels.Items[2].Text := 'Depth: ' +IntToStr( m_TwixtAI.Depth );
  end;
end;

{
  If return is pressed while editting the editfield, call the add-button click
  procedure, so the entered value is processed
}
procedure TMainForm.EditInputKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( Key = VK_RETURN ) then
    ButtonAdd.Click();
end;

end.
