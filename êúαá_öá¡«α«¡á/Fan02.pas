unit Fan02;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Dialogs;

type
  TPion = record
            pori,                 // position d'origine
            pact : TPoint;        // position actuelle
            drav,                 // direction avant
            drar : byte;          // direction arrière
            nbav,                 // nbre de pions avant
            nbar :byte;           //   "        "  arrière
            nbto : integer;
            tbav: array[1..7] of TPoint;    // position des pions à prendre
            tbar: array[1..7] of TPoint;    // avant et arrière
          end;
const
  nocol = $00FF953D;
  kar : array[1..8] of byte = (5,6,7,8,1,2,3,4);   // correspondance direction avant et arrière
  kx  : array[1..8] of integer = (-1,0,1,1,1,0,-1,-1);  // incréments selon direction
  ky  : array[1..8] of integer = (-1,-1,-1,0,1,1,1,0);  //       "
  px1 : array[1..22] of integer = (269,225,181,137,93,49,5,5,5,5,5,5,5,5,5,5,    // position des
                                   49,93,137,181,225,269);
  py1 : array[1..22] of integer = (5,5,5,5,5,5,5,49,93,137,181,225,269,313,357,  // pions hors
                                   401,401,401,401,401,401,401);
  px2 : array[1..22] of integer = (416,460,504,548,592,636,680,680,680,680,680,  // tableau
                                   680,680,680,680,680,636,592,548,504,460,416);
  py2 : array[1..22] of integer = (5,5,5,5,5,5,5,49,93,137,181,225,269,313,357,
                                   401,401,401,401,401,401,401);
var
  PB,PJ,PV,PF,PZ,PJ2,
  tablo : TBitmap;
  tbjeu : array[0..10,0..6] of byte;
  tbscr : array[1..117] of byte;
  chm : string;
  bfin : boolean;
  afin,
  phase : byte;
  jr,jm : byte;
  adi,
  dir : byte;
  cbc : byte;
  nbp : byte;
  nbi : byte;
  tbd : array[1..9] of byte;     // directions  jouées
  tbi : array[1..9] of TPoint;   // intersections jouées
  pnul,pjeu : TPion;
  pijo,pior : integer;
  nbor : integer;
  tbor : array[1..100] of TPion;
  noms : array[1..2] of string;
  fnom : TextFile;

procedure Ouverture;
procedure Fermeture;
function QuelleDir(x1,y1,x2,y2 : integer) : byte;
function Comptage(pn : byte) : byte;
function Environ(x,y : integer) : byte;
procedure ExploJo;
procedure Explore(x,y : integer);
procedure Explore2;
procedure ChargeZero;
procedure ScruteZero;
procedure Trace(num : integer);
procedure Trace2(n1,n2 : integer);
procedure TraceP(pn : TPion);

implementation

uses Fan01;

procedure Ouverture;
begin
  PB := TBitmap.Create;
  PB.LoadFromFile(chm+'PB.bmp');
  PB.Transparent := true;
  PJ := TBitmap.Create;
  PJ.LoadFromFile(chm+'PJ.bmp');
  PJ.Transparent := true;
  PJ2 := TBitmap.Create;
  PJ2.LoadFromFile(chm+'PJ2.bmp');
  PJ2.Transparent := true;
  PV := TBitmap.Create;
  PV.LoadFromFile(chm+'PV.bmp');
  PV.Transparent := true;
  PZ := TBitmap.Create;
  PZ.LoadFromFile(chm+'PZ.bmp');
  PZ.Transparent := true;
  PF := TBitmap.Create;
  PF.LoadFromFile(chm+'PF.bmp');
  tablo := TBitmap.Create;
  tablo.LoadFromFile(chm+'Tablo.bmp');
  with pnul do
  begin
    pori.X := 0;
    pori.Y := 0;
    pact.X := 0;
    pact.Y := 0;
    drav := 0;
    drar := 0;
    nbav := 0;
    nbar := 0;
    nbto := 0;
  end;
  AssignFile(fnom,chm+'Fanoms.txt');
  Reset(fnom);
  ReadLn(fnom,noms[1]);
  ReadLn(fnom,noms[2]);
  CloseFile(fnom);
end;

procedure Fermeture;
begin
  PB.Free;
  PJ.Free;
  PV.Free;
  PF.Free;
  PZ.Free;
  PJ2.Free;
  tablo.Free;
  AssignFile(fnom,chm+'Fanoms.txt');
  Rewrite(fnom);
  WriteLn(fnom,noms[1]);
  WriteLn(fnom,noms[2]);
  CloseFile(fnom);
end;

function QuelleDir(x1,y1,x2,y2 : integer) : byte;
var  dr : byte;
begin
  dr := 0;                   
  if y1 - y2 = 1 then
  begin
    if x1 - x2 = 1 then dr := 1;
    if x1 = x2 then dr := 2;
    if x1 - x2 = -1 then dr := 3;
  end
  else
    if y1 = y2 then
    begin
      if x1 - x2 = 1 then dr := 8;
      if x1 - x2 = -1 then dr := 4;
    end
    else
      if y1 - y2 = -1 then
      begin
        if x1 - x2 = 1 then dr := 7;
        if x1 = x2 then dr := 6;
        if x1 - x2 = -1 then dr := 5;
      end;
  Result := dr;
end;

function Comptage(pn : byte) : byte;     //...des pions en prise
var  ix,iy,px,py : integer;
begin                                   
  with pjeu do
  begin
    ix := kx[drav];
    iy := ky[drav];
    px := pact.X + ix;
    py := pact.Y + iy;
    repeat
      if tbjeu[px,py] = pn then
      begin
        inc(nbav);
        tbav[nbav].X := px;
        tbav[nbav].Y := py;
        px := px + ix;
        py := py + iy;
      end;
    until tbjeu[px,py] <> pn;
    ix := kx[drar];
    iy := ky[drar];
    px := pori.X + ix;
    py := pori.Y + iy;
    repeat
      if tbjeu[px,py] = pn then
      begin
        inc(nbar);
        tbar[nbar].X := px;
        tbar[nbar].Y := py;
        px := px + ix;
        py := py + iy;
      end;
    until tbjeu[px,py] <> pn;
    nbto := nbav+nbar;
    Result := nbto;
  end;
end;

function Environ(x,y : integer) : byte;
var  i,n,nb : byte;
begin                                       
  n := 0;
  nb := 0;
  for i := 1 to 8 do
    if tbjeu[x+kx[i],y+ky[i]] = 0 then
    begin
      inc(n);           
      nb := n*10+i;
    end;
  Result := nb;
end;

procedure ExploJo;      // Recherche pions jouables du joueur
var  i,n : byte;
     tjeu : TPion;
     x,y,cl,lg : integer;
     ok : boolean;
begin
  nbor := 0;
  x := pjeu.pact.X;
  y := pjeu.pact.Y;
  tjeu := pjeu;
  for i := 1 to 8 do
    if (i <> dir) and (i <> kar[dir]) then
    begin
      cl := x+kx[i];
      lg := y+ky[i];
      if tbjeu[cl,lg] = 0 then
      begin
        ok := true;
        pjeu := pnul;
        if (y in[2,4]) and (x in[1,3,5,7,9]) then
          if i in[1,3,5,7] then ok := false;
        if (y in[1,3,5]) and (x in[2,4,6,8]) then
          if i in[1,3,5,7] then ok := false;
        if nbi > 0 then
          for n := 1 to nbi do
            if (cl = tbi[n].X) and (lg = tbi[n].Y) then ok := false;
        if ok then
        begin
          pjeu.pori.X := X;
          pjeu.pori.Y := Y;
          pjeu.pact.X := cl;
          pjeu.pact.Y := lg;
          pjeu.drav := i;
          pjeu.drar := kar[i];
          n := Comptage(1);
          if n > 0 then inc(nbor);
        end;
      end;
    end;
  pjeu := tjeu;  
end;

procedure Explore(x,y : integer); // Recherche pions jouables de l'ordi (phase 1)
var  i,n : byte;
     ok : boolean;
begin
  for i := 1 to 8 do
  begin
    if tbjeu[x+kx[i],y+ky[i]] = 0 then
    begin
      ok := true;
      if (y in[2,4]) and (x in[1,3,5,7,9]) then
        if i in[1,3,5,7] then ok := false;
      if (y in[1,3,5]) and (x in[2,4,6,8]) then
        if i in[1,3,5,7] then ok := false;
      if ok then
      begin
        pjeu := pnul;
        pjeu.pori.X := x;
        pjeu.pori.Y := y;
        pjeu.pact.X := x+kx[i];
        pjeu.pact.Y := y+ky[i];
        pjeu.drav := i;
        pjeu.drar := kar[i];
        n := Comptage(2);
        if n = 0 then ScruteZero;
        inc(nbor);
        tbor[nbor] := pjeu;
      end;
    end;
  end;
end;

procedure Explore2;        // Recherche pions jouables de l'ordi (phase 2)
var  i,n : byte;
     x,y,cl,lg : integer;
     ok : boolean;
begin
  nbor := 0;
  x := pjeu.pact.X;
  y := pjeu.pact.Y;
  for i := 1 to 8 do
    if (i <> dir) and (i <> kar[dir]) then
    begin
      cl := x+kx[i];
      lg := y+ky[i];
      if tbjeu[cl,lg] = 0 then
      begin
        ok := true;
        pjeu := pnul;
        if (y in[2,4]) and (x in[1,3,5,7,9]) then
          if i in[1,3,5,7] then ok := false;
        if (y in[1,3,5]) and (x in[2,4,6,8]) then
          if i in[1,3,5,7] then ok := false;
        if nbi > 0 then
          for n := 1 to nbi do
            if (cl = tbi[n].X) and (lg = tbi[n].Y) then ok := false;
        if ok then
        begin
          pjeu.pori.X := X;
          pjeu.pori.Y := Y;
          pjeu.pact.X := cl;
          pjeu.pact.Y := lg;
          pjeu.drav := i;
          pjeu.drar := kar[i];
          n := Comptage(2);
          if n > 0 then
            begin
              inc(nbor);
              tbor[nbor] := pjeu;
            end;
        end;
      end;
    end;
end;

procedure ChargeZero;
var  i,j,x : byte;
begin
  for i := 1 to 117 do tbscr[i] := 0;
  for j := 1 to 5 do
  begin
    x := (j+1) * 13 + 2;
    for i := 1 to 9 do
    begin
      inc(x);
      tbscr[x] := tbjeu[i,j];
    end;
  end;
end;

procedure ScruteZero;  // déplacement du pion ordi si pas de prise possible
const  tbn : array[1..16] of integer = (-28,-26,-24,-14,-13,-12,-2,-1,1,2,
                                        12,13,14,24,26,28);
var  i,n,x : integer;
begin
  with pjeu do
  begin
    x := (pact.Y + 1) * 13 + 2 + pact.X;
    n := 0;
    for i := 1 to 16 do
      if tbscr[x+tbn[i]] = 2 then inc(n);
    if n > 0 then nbto := n * -1;
  end;
end;
//------------------------------------------------ Mise au point ---------------
procedure Trace(num : integer);
begin
  ShowMessage(IntToStr(num));
end;

procedure Trace2(n1,n2 : integer);
begin
  ShowMessage(IntToStr(n1)+' - '+IntToStr(n2));
end;

procedure TraceP(pn : TPion);
begin
  with pn do
    Showmessage(Format('  ori: %d,%d  act: %d,%d  dir: %d,%d  nbp: %d,%d  ',
                 [pori.X,pori.Y,pact.X,pact.Y,drav,drar,nbav,nbar]));
end;

end.
