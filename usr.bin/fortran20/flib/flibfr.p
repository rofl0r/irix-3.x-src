(*****************************************************************************)
(*                                                                           *)
(*                             File: FLIBFR.TEXT                             *)
(*                                                                           *)
(*           (C) Copyright 1982, 1985 Silicon Valley Software, Inc.          *)
(*                                                                           *)
(*                            All Rights Reserved.               10-May-85   *)
(*                                                                           *)
(*****************************************************************************)


{$%+} {$R-} {$I-}

unit %flibfr;

interface

uses {$u flibinit} %flibinit,
     {$u flibrec}  %flibrec,
     {$u flibfmt}  %flibfmt;

procedure %%rdfch(fpac: ppac; paclen: integer);
function %rdintconst(width: integer; OpSigned: Boolean): int4;

implementation

function %rdintconst{*width: integer; OpSigned: Boolean): int4*};
  var lch: char; lint: int4; PosFlag: Boolean;
begin {%rdintconst}
lint := 0; col := 0;
repeat
  %getch(lch);
until (lch <> ' ') or (col = width);
PosFlag := lch <> '-';
if (lch = '-') or (lch = '+')
then begin
  if not OpSigned then %error(1);
  if col = width then %error(2);
  %getch(lch);
  end;
while col <= width do begin
  if lch = ' ' 
  then begin
    if BZFlag then lint := 10 * lint;
    end
  else begin
    if (lch < '0') or (lch > '9') then %error(3);
    lint := (10 * lint + ord('0')) - ord(lch);
    end;
  if col < width then %getch(lch) else col := col + 1;
  end;
if PosFlag then %rdintconst := - lint else %rdintconst := lint;
end; {%rdintconst}


function %getnibble(fch: char): integer;
begin {%getnibble}
if fch = ' ' then fch := '0';
if (fch >= 'a') and (fch <= 'z') then fch := chr(ord(fch) - 32);
if (fch >= '0') and (fch <= '9')
then %getnibble := ord(fch) - ord('0')
else
  if (fch >= 'A') and (fch <= 'F')
  then %getnibble := ord(fch) - ord('A') + 10
  else begin %error(108); %getnibble := 0; end;
end; {%getnibble}


{ Read a character or hex numeric variable }

procedure %%rdfch{*fpac: ppac; paclen: integer*};
  var i,lpaclen: integer; lch: char; temp: longint;
      larray: array [0..1] of longint;
  
  procedure %leftnibble;
    var lval: longint;
  begin {%leftnibble}
  if larray[1] < 0
  then lval := ((larray[1] and $7FFFFFFF) div $10000000) + 8
  else lval := larray[1] div $10000000;
  larray[1] := larray[1] * 16;
  larray[0] := larray[0] * 16 or lval;
  end; {%leftnibble}
  
begin {%%rdfch}
if edlet = 'A'
then begin
  if not EdwPresent then edw := paclen;
  for i := 1 to edw - paclen do
    %getch(lch);
  if edw <= paclen then lpaclen := edw else lpaclen := paclen;
  for i := 1 to lpaclen do begin
    %getch(lch); fpac^[i] := lch;
    end;
  for i := lpaclen + 1 to paclen do
    fpac^[i] := ' ';
  end
else begin {edlet = 'Z', paclen = 1,2,4, or 8 (double)}
  if not EdwPresent then edw := paclen*2;
  larray[0] := 0; larray[1] := 0;
  for i := 1 to edw do begin
    %getch(lch);
    if lch = ' ' 
    then begin
      if BZFlag then %leftnibble;
      end
    else begin
      %leftnibble; larray[1] := larray[1] or %getnibble(lch);
      end;
    end;
  temp := 1; moveleft(temp,lpaclen,2);
  if lpaclen = 0
  then {lsb in higher addresses (68000 byte sex)}
    for i := 1 to (8 - paclen)*2 do
      %leftnibble
  else begin {lsb in lower addresses (16000 byte sex)}
    temp := larray[0]; larray[0] := larray[1]; larray[1] := temp;
    end;
  moveleft(larray,fpac^,paclen);
  end;
end; {%%rdfch}

procedure %_rdfch(fpac: ppac; paclen: longint);
  var lpaclen,i,lval: integer; lch: char; hexptr: pint1array;
begin {%_rdfch}
%getfmt;
if edlet = 'A'
then %%rdfch(fpac,paclen)
else
  if edlet = 'Z'
  then begin {Read a character under 'Z' format}
    if not EdwPresent then edw := paclen*2;
    moveleft(fpac,hexptr,4);
    for i := 1 to edw - paclen*2 do
      %getch(lch);
    if edw <= paclen*2 then lpaclen := edw else lpaclen := paclen*2;
    for i := 2 to paclen*2 + 1 do begin
      if i <= (lpaclen + 1) then %getch(lch) else lch := ' '; 
      lval := hexptr^[i div 2];
      if odd(i)
      then lval := (lval and $F0) or %getnibble(lch)
      else lval := (lval and $F) or (16 * %getnibble(lch));
      hexptr^[i div 2] := lval;
      end;
    end
  else %error(40);
end; {%_rdfch}


{ Read an integer }

procedure %_rdfi4(var fint: int4);
begin {%_rdfi4}
%getfmt;
if AorZFlag
then %%rdfch(@fint,4)
else begin
     if edlet <> 'I' then %error(33);
     fint := %rdintconst(edw,TRUE);
     end;
end; {%_rdfi4}


procedure %_rdfi2(var fint: int2);
begin {%_rdfi2}
%getfmt;
if AorZFlag
then %%rdfch(@fint,2)
else begin
     if edlet <> 'I' then %error(33);
     fint := %rdintconst(edw,TRUE);
     end;
end; {%_rdfi2}


procedure %_rdfi1(var fint: int1);
begin {%_rdfi1}
%getfmt;
if AorZFlag
then %%rdfch(@fint,1)
else begin
     if edlet <> 'I' then %error(33);
     fint := %rdintconst(edw,TRUE);
     end;
end; {%_rdfi1}


{ Read a logical }

function %%rdfl: int4;
  var lch: char;
begin {%%rdfl4}
if edlet <> 'L' then %error(37); col := 0;
repeat
  %getch(lch);
until (lch <> ' ') or (col = edw);
if lch = '.'
then
  if col = edw then %error(39) else %getch(lch);
if (lch <> 'T') and (lch <> 'F') and 
   (lch <> 't') and (lch <> 'f') and (not EofFlag)
then %error(39);
if (lch = 'T') or (lch = 't') then %%rdfl := 1 else %%rdfl := 0;
while col < edw do
  %getch(lch);
end; {%%rdfl}

procedure %_rdfl4(var flog: int4);
begin {%_rdfl4}
%getfmt;
if AorZFlag then %%rdfch(@flog,4) else flog := %%rdfl;
end; {%_rdfl4}

procedure %_rdfl2(var flog: int2);
begin {%_rdfl2}
%getfmt;
if AorZFlag then %%rdfch(@flog,2) else flog := %%rdfl;
end; {%_rdfl2}

procedure %_rdfl1(var flog: int1);
begin {%_rdfl1}
%getfmt;
if AorZFlag then %%rdfch(@flog,1) else flog := %%rdfl;
end; {%_rdfl1}


procedure %_rafi4(var fintarray: int4array; count: int4);
  var ctr: longint;
begin {%_rafi4}
for ctr := 1 to count do
  %_rdfi4(fintarray[ctr]);
end; {%_rafi4}

procedure %_rafi2(var fintarray: int2array; count: int4);
  var ctr: longint;
begin {%_rafi2}
for ctr := 1 to count do
  %_rdfi2(fintarray[ctr]);
end; {%_rafi2}

procedure %_rafi1(var fintarray: int1array; count: int4);
  var ctr: longint;
begin {%_rafi1}
for ctr := 1 to count do
  %_rdfi1(fintarray[ctr]);
end; {%_rafi1}

procedure %_rafl4(var flogarray: int4array; count: int4);
  var ctr: longint;
begin {%_rafl4}
for ctr := 1 to count do
  %_rdfl4(flogarray[ctr]);
end; {%_rafl4}

procedure %_rafl2(var flogarray: int2array; count: int4);
  var ctr: longint;
begin {%_rafl2}
for ctr := 1 to count do
  %_rdfl2(flogarray[ctr]);
end; {%_rafl2}

procedure %_rafl1(var flogarray: int1array; count: int4);
  var ctr: longint;
begin {%_rafl1}
for ctr := 1 to count do
  %_rdfl1(flogarray[ctr]);
end; {%_rafl1}

procedure %_rafch(fpac: pbyte; paclen: longint; count: int4);
  var lpaclen,i: integer; lch: char; ctr: longint; p: ppac;
begin {%_rafch}
for ctr := 0 to count - 1 do begin
  %getfmt; if edlet <> 'A' then %error(40);
  if not EdwPresent then edw := paclen;
  for i := 1 to edw - paclen do
    %getch(lch);
  p := pointer(ord(fpac) + ctr*paclen);
  for i := 1 to edw do begin
    %getch(lch); p^[i] := lch;
    end;
  for i := edw + 1 to paclen do
    p^[i] := ' ';
  end;
end; {%_rafch}

end. {%flibfr}

                                                                                                                                                                                                                                                                                                                    