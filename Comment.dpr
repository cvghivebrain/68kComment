program Comment;

{$APPTYPE CONSOLE}

uses
  Windows, SysUtils, StrUtils, Classes;

var
  buffer: TStringList;
  rec: TSearchRec;
  s, c: string;
  n, i, colonmin, colonwant, colonpos: integer;
  basefolder, filemask: string;
  folders: array of string;

label endnow;

  { Functions. }

  { Get length of string with tabs. }
  function LengthWithTabs(str: string): integer;
  var r, x: integer;
  begin
  r := 0; // Start with 0.
  for x := 1 to Length(str) do // Check each character for tab.
    begin
    if str[x] = #9 then r := (r+8) and $fff8 // If tab, add 8 and round down to 8.
      else inc(r); // If other character, add 1.
    end;
  result := r;
  end;

  { Pad a line with tabs. }
  function PadLine(ln: string): string;
  var x: integer;
  begin
  ln := TrimRight(ln); // Remove trailing spaces and tabs.
  x := LengthWithTabs(ln); // Get length of line.
  if x >= colonwant then ln := ln+' ' // Single space for line that's longer than target colon position.
    else
      begin
      while x < (colonwant and $fff8) do // Add tabs until length is correct.
        begin
        ln := ln+#9;
        x := LengthWithTabs(ln);
        end;
      while x < colonwant do // Add spaces if target length isn't multiple of 8.
        begin
        ln := ln+' ';
        inc(x);
        end;
      end;
    result := ln;
  end;


  { Program start. }
begin

  if ParamStr(1) = '' then goto endnow; // End program if run without parameters.
  colonmin := StrtoInt(ParamStr(1)); // Get minimum colon position.
  colonwant := StrtoInt(ParamStr(2)); // Get target colon position.

  { Generate a list of all folders (and subfolders) in folders array. }
  SetLength(folders,1);
  basefolder := ExtractFilePath(ParamStr(0)); // Get target folder.
  n := 0;
  while (n < Length(folders)) and (ParamStr(3) = '') do // Don't add subfolders if 3rd param is set.
    begin
    if (FindFirst(basefolder+folders[n]+'*.*', faDirectory, rec) = 0) then
      begin
      repeat
      if (rec.Name<>'.') and (rec.Name<>'..') and ((rec.attr and faDirectory)=faDirectory) then
        begin
        SetLength(folders,Length(folders)+1); // Add 1 slot for folder name.
        folders[Length(folders)-1] := folders[n]+rec.Name+'\'; // Add folder name to array.
        end;
      until FindNext(rec) <>0;
      FindClose(rec);
      end;
    inc(n);
    end;

  if (ParamStr(3) <> '') and (FileExists(basefolder+ParamStr(3))) then filemask := ParamStr(3) // Look for specific file.
    else filemask := '*.asm'; // Look for all asm files.

  for n := 0 to Length(folders)-1 do
    begin
    if FindFirst(basefolder+folders[n]+filemask, faAnyFile-faDirectory, rec) = 0 then
      begin
      repeat
        begin
        buffer := TStringList.Create;
        buffer.LoadFromFile(basefolder+folders[n]+rec.Name); // Load file to memory.
        writeln('opened '+basefolder+folders[n]+rec.Name);
        for i := 0 to buffer.Count-1 do
          begin
          colonpos := AnsiPos(';',buffer[i]);
          if colonpos <> 0 then // Check if line contains comment.
            begin
            s := Copy(buffer[i],1,colonpos-1); // Get line without comment.
            c := Copy(buffer[i],colonpos,Length(buffer[i])-colonpos+1); // Get comment only.
            colonpos := LengthWithTabs(s)+1; // Get colon position corrected for tabs.
            if colonpos > colonmin then // Check if colon is past minimum position.
              buffer[i] := PadLine(s)+c; // Update line with new padding.
            end;
          end;
        buffer.SaveToFile(basefolder+folders[n]+rec.Name); // Save file.
        buffer.Free; // Remove file from memory.
        end;
      until FindNext(rec) <> 0;
      FindClose(rec);
      end;
    end;

  endnow:
end.