unit Fan03;        // Choix de la direction de prise

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Fan02, StdCtrls, ExtCtrls, Buttons;

type
  TForm2 = class(TForm)
    BtAv: TButton;
    BtAr: TButton;
    procedure BtAvClick(Sender: TObject);
    procedure BtArClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.BtAvClick(Sender: TObject);
begin
   cbc := 1;
   dir := pjeu.drav;
   nbp := pjeu.nbav;
end;

procedure TForm2.BtArClick(Sender: TObject);
begin
  cbc := 2;
  dir := pjeu.drar;
  nbp := pjeu.nbar;
end;

end.
