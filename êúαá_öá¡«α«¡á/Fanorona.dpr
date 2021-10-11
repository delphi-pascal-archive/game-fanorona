program Fanorona;

uses
  Forms,
  Fan01 in 'Fan01.pas' {Form1},
  Fan02 in 'Fan02.pas',
  Fan03 in 'Fan03.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
