program resGeneration;

uses
  Forms,
  main in 'main.pas' {Fmain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'generationRES';
  Application.CreateForm(TFmain, Fmain);
  Application.Run;
end.
