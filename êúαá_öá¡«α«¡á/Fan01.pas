unit Fan01;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons,
  Fan02, Fan03, StdCtrls;

type
  TForm1 = class(TForm)
    Panbt: TPanel;
    SBNouveau: TSpeedButton;
    SBQuitter: TSpeedButton;
    Pnor: TPanel;
    Pnjo: TPanel;
    Opio: TPanel;
    JPio: TPanel;
    Fond: TImage;
    Plan: TImage;
    Ima: TImage;
    Pmess: TPanel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SBQuitterClick(Sender: TObject);
    procedure SBNouveauClick(Sender: TObject);
    procedure PlanMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PrisePion;
    procedure ChoixPrise;
    procedure Suivant;
    procedure BougePion(x,y : integer; dr : byte);
    procedure Deplace(no : byte; x,y : integer);
    procedure JeuOrdi;
    procedure AutrePrise;
    procedure TestFin;
    procedure Efface3;
    procedure EffaceRond;
    procedure PnomClick(Sender: TObject);
    procedure Mess(st : string; tm : byte);
    procedure Timer1Timer(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

uses ShellAPI;

{$R *.dfm}

var
  on1 : boolean = true;
  cl,lg,ocl,olg : integer;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  DoubleBuffered := true;
end;

procedure TForm1.FormActivate(Sender: TObject);
var  i : byte;
begin
  if on1 then
  begin
    chm := ExtractFilePath(Application.ExeName)+'Images\';
    Ouverture;
    on1 := false;
    Form2.Left := Left + 240;
    Form2.Top := Top + 420;
    Fond.Canvas.Brush.Color := $00DCDC78;
    Fond.Canvas.FillRect(Rect(0,0,725,450));
    for i := 1 to 22 do
    begin
      Fond.Canvas.Draw(px1[i],py1[i],PB);
      Fond.Canvas.Draw(px2[i],py2[i],PJ);
    end;
    Fond.Repaint;
    Pnor.Caption := noms[1];
    Pnjo.Caption := noms[2];
    jm := Random(2)+1;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Fermeture;
end;

procedure TForm1.SBQuitterClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.SBNouveauClick(Sender: TObject);
var  i,j,n1,n2 : integer;
begin
  for j := 1 to 2 do
    for i := 1 to 9 do tbjeu[i,j] := 1;
  for j := 4 to 5 do
    for i := 1 to 9 do tbjeu[i,j] := 2;
  tbjeu[1,3] := 2;
  tbjeu[2,3] := 1;
  tbjeu[3,3] := 2;
  tbjeu[4,3] := 1;
  tbjeu[5,3] := 0;
  tbjeu[6,3] := 2;
  tbjeu[7,3] := 1;
  tbjeu[8,3] := 2;
  tbjeu[9,3] := 1;
  n1 := 0;
  n2 := 0;
  for j := 1 to 5 do
    for i := 1 to 9 do
    begin
      if tbjeu[i,j] = 1 then
      begin
        inc(n1);
        Fond.Canvas.Draw(px1[n1],py1[n1],PF);
      end;
      if tbjeu[i,j] = 2 then
      begin
        inc(n2);
        Fond.Canvas.Draw(px2[n2],py2[n2],PF);
      end;
    end;
  Fond.Repaint;
  for j := 1 to 5 do
    for i := 1 to 9 do
    begin
      if tbjeu[i,j] = 1 then
      begin
        Plan.Canvas.Draw((i-1)*69+15,(j-1)*69+15,PB);
      end;
      if tbjeu[i,j] = 2 then
      begin
        Plan.Canvas.Draw((i-1)*69+15,(j-1)*69+15,PJ);
      end;
    end;
  Plan.Canvas.Draw(4*69+15,2*69+15,PV);
  for i := 0 to 10 do
  begin
    tbjeu[i,0] := 9;
    tbjeu[i,6] := 9;
  end;
  for j := 1 to 5 do
  begin
    tbjeu[0,j] := 9;
    tbjeu[10,j] := 9;
  end;
  pijo := 22;
  pior := 22;
  OPio.Caption := IntToStr(pior);
  JPio.Caption := IntToStr(pijo);
  bfin := false;
  afin := 0;
  phase := 0;
  nbi := 0;
  nbor := 0;
  Pmess.Caption := '';
  jr := jm;
  jm := 3-jm;           
  Suivant;
end;

procedure TForm1.PlanMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var  i,nb,dr : byte;
begin
  if bfin or (jr = 1) then exit;
  if Button = mbLeft then
  begin
    ocl := X div 69 + 1;
    olg := Y div 69 + 1;
    if (tbjeu[ocl,olg] = 2) and (phase = 1) then phase := 0;
    case phase of
      0 : begin                         // choix du pion
            if tbjeu[ocl,olg] = 2 then
            begin
              EffaceRond;
              Plan.Canvas.Draw((ocl-1)*69+15,(olg-1)*69+15,PJ2);
              Plan.Repaint;
              pjeu := pnul;
              pjeu.pact.X := ocl;
              pjeu.pact.y := olg;
              inc(nbi);
              tbi[nbi] := pjeu.pact;
              phase := 1;
              dr := Environ(ocl,olg);
              if dr in[11..18] then
              begin
                dir := dr - 10;
                with pjeu do
                begin
                  pori := pact;
                  pact.X := ocl+kx[dir];
                  pact.Y := olg+ky[dir];
                  drav := dir;
                  drar := kar[dir];
                  nbav := 0;
                  nbar := 0;
                end;
                tbjeu[ocl,olg] := 0;
                Plan.Canvas.Draw((ocl-1)*69+15,(olg-1)*69+15,PV);
                Plan.Canvas.Draw((ocl-1)*69+15,(olg-1)*69+15,PZ);
                tbjeu[ocl,olg] := 3;
                BougePion(ocl-1,olg-1,dir);
                cl := pjeu.pact.X;
                lg := pjeu.pact.Y;
                tbjeu[cl,lg] := 2;
                Plan.Canvas.Draw((cl-1)*69+15,(lg-1)*69+15,PJ2);
                Plan.Repaint;
                if Comptage(1) > 0 then
                begin
                  ChoixPrise;
                  ExploJo;
                  if nbor = 0 then Suivant
                  else phase := 2;
                end
                else Suivant;
              end;
            end;
          end;
      1 : begin                      // choix du premier déplacement
            cl := X div 69+1;
            lg := Y div 69+1;
            ocl := pjeu.pact.X;
            olg := pjeu.pact.Y;
            if tbjeu[cl,lg] = 0 then
            begin
              dir := QuelleDir(ocl,olg,cl,lg);
              if ((ocl in[1,3,5,7,9]) and (olg in[2,4]))
              or ((ocl in[2,4,6,8])and (olg in[1,3,5])) then
                if dir in[1,3,5,7] then dir := 0;
              if dir > 0 then
              begin
                with pjeu do
                begin
                  pori := pact;
                  pact.X := cl;
                  pact.Y := lg;
                  drav := dir;
                  drar := kar[dir];
                  nbav := 0;
                  nbar := 0;
                end;
                tbjeu[ocl,olg] := 0;
                Plan.Canvas.Draw((ocl-1)*69+15,(olg-1)*69+15,PV);
                Plan.Canvas.Draw((ocl-1)*69+15,(olg-1)*69+15,PZ);
                tbjeu[ocl,olg] := 3;
                BougePion(ocl-1,olg-1,dir);
                tbjeu[cl,lg] := 2;
                Plan.Canvas.Draw((cl-1)*69+15,(lg-1)*69+15,PJ2);
                if Comptage(1) > 0 then
                begin
                  ChoixPrise;
                  ExploJo;
                  if nbor = 0 then Suivant
                  else phase := 2;
                end
                else Suivant;
              end
              else phase := 0;
            end;
          end;
      2 : begin                       // déplacements suivants
            cl := X div 69+1;
            lg := Y div 69+1;
            ocl := pjeu.pact.X;
            olg := pjeu.pact.Y;
            if tbjeu[cl,lg] = 0 then
            begin
              dir := QuelleDir(ocl,olg,cl,lg);
              if dir > 0 then
              begin
                adi := kar[dir];
                if (tbjeu[cl+kx[dir],lg+ky[dir]] <> 1)
                and (tbjeu[ocl+kx[adi],olg+ky[adi]] <> 1) then dir := 0;
                if nbi > 0 then
                begin
                  if (tbd[nbi] = dir)
                  or (tbd[nbi] = adi)  then
                  begin
                    Mess('Jeu même direction interdit',3);
                    dir := 0;
                  end
                  else
                    begin
                      nb := 0;
                      for i := 1 to nbi do
                        if (cl = tbi[i].X) and (lg = tbi[i].Y) then nb := 1;
                      if nb > 0 then
                      begin
                        Mess('Intersection déjà jouée',3);
                        dir := 0;
                      end;
                    end;
                end;
                if dir > 0 then
                  if ((ocl in[1,3,5,7,9]) and (olg in[2,4]))
                  or ((ocl in[2,4,6,8])and (olg in[1,3,5])) then
                    if dir in[0,1,3,5,7] then
                    begin
                      Mess('Direction impossible',3);
                      dir := 0;
                    end;
                if dir > 0 then
                begin
                  tbjeu[ocl,olg] := 0;
                  tbjeu[cl,lg] := 2;
                  Plan.Canvas.Draw((ocl-1)*69+15,(olg-1)*69+15,PV);
                  Plan.Canvas.Draw((ocl-1)*69+15,(olg-1)*69+15,PZ);
                  tbjeu[ocl,olg] := 3;
                  BougePion(ocl-1,olg-1,dir);
                  Plan.Canvas.Draw((cl-1)*69+15,(lg-1)*69+15,PJ2);
                  with pjeu do
                  begin
                    pori := pact;
                    pact.X := cl;
                    pact.Y := lg;
                    drav := dir;
                    drar := kar[dir];
                    nbav := 0;
                    nbar := 0;
                  end;
                  if Comptage(1) > 0 then
                  begin
                    ChoixPrise;
                    ExploJo;
                    if nbor = 0 then Suivant;
                  end
                  else Suivant;
                end
                else Suivant;
              end;
            end;
          end;
    end;
  end;
end;

procedure TForm1.ChoixPrise;
begin                              
  with pjeu do
  begin
    if (nbav > 0) and (nbar = 0) then
    begin
      cbc := 1;
      dir := drav;
      nbp := nbav;
      PrisePion;
      phase := 2;
    end
    else
      if (nbav = 0) and (nbar > 0) then
      begin
        cbc := 2;
        dir := drar;
        nbp := nbar;
        PrisePion;
        phase := 2;
      end
      else
        begin
          cbc := 0;
          while cbc = 0 do Form2.ShowModal;
          PrisePion;
          phase := 2;
        end;
  end;
end;

procedure TForm1.PrisePion;
var  i : byte;
     cl,lg : integer;
begin                              
  with pjeu do
  begin
    inc(nbi);
    tbi[nbi] := pjeu.pact;
    tbd[nbi] := dir;
    for i := 1 to nbp do
    begin
      if cbc = 1 then
      begin
        cl := tbav[i].X;
        lg := tbav[i].Y;
      end
      else
        begin
          cl := tbar[i].X;
          lg := tbar[i].Y;
        end;
      tbjeu[cl,lg] := 0;
      Plan.Canvas.Draw((cl-1)*69+15,(lg-1)*69+15,PV);
      if jr = 1 then
      begin
        dec(pijo);
        Deplace(22-pijo,(cl-1)*69+66,(lg-1)*69+66);
      end
      else
        begin
          dec(pior);
          Deplace(22-pior,(cl-1)*69+66,(lg-1)*69+66);
        end;
    end;
    afin := 0;
  end;
  OPio.Caption := IntToStr(pior);
  JPio.Caption := IntToStr(pijo);
  TestFin;
end;

procedure TForm1.BougePion(x,y : integer; dr : byte);
var  i,ix,iy : integer;
begin                           
  ix := kx[dr];
  iy := ky[dr];
  ima.Left := x * 69 + 66;
  ima.Top := y * 69 + 66;
  if jr = 1 then ima.Picture.Bitmap := PB
  else ima.Picture.Bitmap := PJ2;
  ima.Visible := true;
  for i := 1 to 69 do
  begin
    ima.Left := ima.Left + ix;
    ima.Top := ima.Top + iy;
    Ima.Repaint;
  end;
  ima.Visible := false;
  ima.Top := 452;
end;

procedure TForm1.Deplace(no : byte; x,y : integer);   // Pions pris
var xo, yo,
    xd, yd,
    ix, iy, ic : integer;
begin             // déplacement glissé
  Ima.Left := x;                          
  Ima.Top := y;
  if jr = 1 then ima.Picture.Bitmap := PJ
  else ima.Picture.Bitmap := PB;
  with Ima do
  begin
    xo := Left;       // position initiale de la pièce
    yo := Top;
    if jr = 1 then
    begin
      xd := px2[no];       // position finale
      yd := py2[no];
    end
    else
      begin
        xd := px1[no];
        yd := py1[no];
      end;
    ima.Visible := true;
    ic := 30;       // nbre de pas
    repeat
      ix := (xd-xo) div ic;
      iy := (yd-yo) div ic;
      xo := xo+ix;
      yo := yo+iy;
      Left := xo;              // on déplace la pièce
      Top := yo;
      ima.Repaint;
      dec(ic);
      sleep(10);
    until ic = 0;
    Fond.Canvas.Draw(Left,Top,Ima.Picture.Bitmap);
  end;
  ima.Visible := false;
  ima.Top := 452;
end;

procedure TForm1.Suivant;
begin
  Efface3;
  EffaceRond;
  TestFin;
  if bfin then exit;
  nbi := 0;
  nbor := 0;
  phase := 0;
  pjeu := pnul;
  if jr = 2 then
  begin
    Pnor.Color := clYellow;
    Pnjo.Color := nocol;
    Mess('A mon tour...',0);
    Sleep(2000);
    jr := 1;
    JeuOrdi;
  end
  else
    begin
      Pnor.Color := nocol;
      Pnjo.Color := clYellow;
      Mess('A vous de jouer...',0);
      jr := 2;
    end;
end;

procedure TForm1.TestFin;
var  n : byte;
begin
  n := 0;
  if pior = 0 then n := 2;
  if pijo = 0 then inc(n,1);
  if (pior < 5) and (pijo < 5) then  inc(afin);
  if afin >= 20 then n := 3;
  if n > 0 then
  begin
    bfin := true;
    Beep;
    if n = 3 then Mess('Match nul',0)
    else Mess(noms[n]+' gagne',0);
  end;
  n := 0;
end;

//------------------------------------------------------------------------------
procedure TForm1.JeuOrdi;
var  i,j : integer;
     n,n1,n2 : integer;
begin
  ChargeZero;
  for j := 1 to 5 do
    for i := 1 to 9 do
    begin
      if tbjeu[i,j] = 1 then Explore(i,j);
    end;
  if nbor > 0 then
  begin
    pjeu := tbor[1];
    n1 := pjeu.nbto;
    if nbor > 1 then
      for i := 2 to nbor do
      begin
        n2 := tbor[i].nbto;
        if n2 = n1 then
        begin
          n := random(10);
          if Odd(n) then
          begin
            n1 := n2;
            pjeu := tbor[i];
          end;
        end
        else
          if n2 > n1 then
          begin
            n1 := n2;
            pjeu := tbor[i];
          end;
      end;
    with pjeu do
    begin
      tbjeu[pori.X,pori.Y] := 0;
      tbjeu[pact.X,pact.Y] := 1;
      Plan.Canvas.Draw((pori.X-1)*69+15,(pori.Y-1)*69+15,PV);
      BougePion(pori.X-1,pori.Y-1,drav);
      Plan.Canvas.Draw((pact.X-1)*69+15,(pact.Y-1)*69+15,PB);
      if nbto > 0 then
      begin
        if nbav > nbar then
        begin
          cbc := 1;
          dir := drav;
          nbp := nbav;
        end
        else
          begin
            cbc := 2;
            dir := drar;
            nbp := nbar;
          end;
      end;
      while nbto > 0 do
      begin
        PrisePion;
        AutrePrise;
      end;
    end;
  end;
  Suivant;
end;

procedure TForm1.AutrePrise;
var  i,n,n1,n2 : byte;
begin
  nbor := 0;
  Explore2;
  pjeu := pnul;
  if nbor > 0 then
  begin
    pjeu := tbor[1];
    n1 := pjeu.nbto;
    if nbor > 1 then
    begin
      for i := 2 to nbor do
      begin
        n2 := tbor[i].nbto;
        if n2 = n1 then
        begin
          n := random(2);
          if n = 1 then
          begin
            n1 := n2;
            pjeu := tbor[i];
          end;
        end
        else
          if n2 > n1 then
          begin
            n1 := n2;
            pjeu := tbor[i];
          end;
      end;
    end;
    with pjeu do
    begin
      if nbto > 0 then
      begin
        tbjeu[pori.X,pori.Y] := 0;
        tbjeu[pact.X,pact.Y] := 1;
        Plan.Canvas.Draw((pori.X-1)*69+15,(pori.Y-1)*69+15,PV);
        BougePion(pori.X-1,pori.Y-1,drav);
        Plan.Canvas.Draw((pact.X-1)*69+15,(pact.Y-1)*69+15,PB);
        if nbav > nbar then
        begin
          cbc := 1;
          dir := drav;
          nbp := nbav;
        end
        else
          begin
            cbc := 2;
            dir := drar;
            nbp := nbar;
          end;
      end;
    end;
  end;
end;

procedure TForm1.Efface3;
var  x,y : byte;
begin
  for y := 1 to 5 do
    for x := 1 to 9 do
      if tbjeu[x,y] = 3 then
      begin
        tbjeu[x,y] := 0;
        Plan.Canvas.Draw((x-1)*69+15,(y-1)*69+15,PV);
      end;
end;
 
procedure TForm1.EffaceRond;
var  x,y : byte;
begin
  for y := 1 to 5 do
    for x := 1 to 9 do
      if tbjeu[x,y] = 2 then
      begin
        Plan.Canvas.Draw((x-1)*69+15,(y-1)*69+15,PJ);
        Plan.Repaint;
      end;
end;

//------------------------------------------------------------------------------
procedure TForm1.PnomClick(Sender: TObject);
var  tag : byte;
     st : string;
begin
  tag := (Sender as TPanel).Tag;
  st := InputBox('Identification du joueur','Donnez un nom','');
  if st = '' then exit;
  noms[tag] := st;
  if tag = 1 then Pnor.Caption := st
  else Pnjo.Caption := st;
end;

procedure TForm1.Mess(st : string; tm : byte);
var  i : byte;
begin
  for i := 1 to 3 do
  begin
    Pmess.Caption := '';
    Pmess.Repaint;
    Sleep(100);
    Pmess.Caption := st;
    Pmess.Repaint;
    Sleep(100);
  end;
  if tm > 0 then
  begin
    Timer1.Interval := tm * 1000;    trace(tm);
    Timer1.Enabled := true;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  Pmess.Caption := '';
end;

end.

