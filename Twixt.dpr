program Twixt;

uses
  Forms,
  FormMain in 'src\FormMain.pas' {MainForm},
  TwixtComponents in 'src\TwixtComponents.pas',
  AlfaBetaAI in 'src\AlfaBetaAI.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Twixt';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
