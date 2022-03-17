unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, XPMan, ExtCtrls, ShellApi, Grids;

type
  TFmain = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    XPManifest: TXPManifest;
    OpenDialog: TOpenDialog;
    StringGrid: TStringGrid;
    BitBtnOpen: TBitBtn;
    BitBtnDel: TBitBtn;
    TypeBox: TComboBox;
    Label1: TLabel;
    EditName: TLabeledEdit;
    Identifier: TLabeledEdit;
    BitBtnGen: TBitBtn;
    SaveDialog: TSaveDialog;
    procedure BitBtnOpenClick(Sender: TObject);
    procedure BitBtnGenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure StringGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure BitBtnDelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Fmain: TFmain;

implementation

{$R *.dfm}

function FileNameWithoutFormat(str: string): string;
var
  i:Integer; ind:Byte; st:String;
begin
  st:=str;
  for i:=length(st)-1 downto 0 do
    if (st[i]='.') then begin ind:=i; break; end;
  Delete(st,ind,length(st)); Result:=st;
end;

procedure SgDeleteLine(Sg:TStringGrid);
  var i: byte;
begin
  if Sg.RowCount=2 then Sg.Rows[1].Clear;
  if Sg.RowCount>2 then
    begin
      for i:=Sg.Row to Sg.RowCount-1 do
        Sg.Rows[i]:=Sg.Rows[i+1];
      Sg.RowCount:=Sg.RowCount-1;
    end;
end;

procedure TFmain.FormCreate(Sender: TObject);
begin
  StringGrid.Cells[0,0]:='Имя файла :';
  StringGrid.Cells[1,0]:='Тип ресурса :';
  StringGrid.Cells[2,0]:='Идентификатор :';
  StringGrid.Cells[3,0]:='Путь к файлам компилируемого файла ресурса :';
end;

procedure TFmain.BitBtnDelClick(Sender: TObject);
begin
  SgDeleteLine(StringGrid);
end;

procedure TFmain.StringGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  with TStringGrid(Sender),TStringGrid(Sender).Canvas Do
    Begin
      FillRect(Rect);
      if (gdFixed In State) then
        begin
          Canvas.Font.Color:=clBlack;
          Canvas.Brush.Color:=$00F0F0EA;
        end;
      Font.Color:=clBlack;
      if (gdSelected In State) then
        begin
          Canvas.Font.Color:=clNavy;
          Canvas.Brush.Color:=$F0F0F2;
        end;
      Canvas.FillRect(Rect);
      TextOut(Rect.Left+2,Rect.Top+4,Cells[ACol,ARow]);
   end;
end;

procedure TFmain.StringGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  i:integer;
begin
  Identifier.Text:=StringGrid.Cells[2,ARow];
  for i:=0 to TypeBox.Items.Count-1 do
    if (TypeBox.Items.Strings[i])=(StringGrid.Cells[1,ARow]) then TypeBox.ItemIndex:=i
    else TypeBox.ItemIndex:=-1;
end;

procedure TFmain.BitBtnOpenClick(Sender: TObject);
var
  i,j:integer;
begin
  if OpenDialog.Execute then
    begin
      for i:=0 to openDialog.Files.Count-1 do
        begin
          j:=StringGrid.RowCount-1;
          StringGrid.Cells[0,j]:=ExtractFileName(openDialog.Files[i]);
          StringGrid.Cells[1,j]:='RCDATA';
          StringGrid.Cells[2,j]:=FileNameWithoutFormat(ExtractFileName(openDialog.Files[i]));
          StringGrid.Cells[3,j]:='"'+openDialog.Files[i]+'"';
          StringGrid.RowCount := StringGrid.RowCount+1;
        end;
    end;
end;

procedure TFmain.BitBtnGenClick(Sender: TObject);
var
  i:integer;
  f:TextFile;
begin
  SaveDialog.FileName:=EditName.Text;
  if SaveDialog.Execute then
    begin
      SaveDialog.InitialDir:=GetCurrentDir;
      AssignFile(f,EditName.Text+'.rc');
      Rewrite(f);
      for i:=1 to StringGrid.RowCount-1 do
        begin
          Write(f,StringGrid.Cells[2,i]);
          Write(f,'   ');
          Write(f,StringGrid.Cells[1,i]);
          Write(f,'   ');
          Writeln(f,StringGrid.Cells[3,i]);
        end;
      CloseFile(f);
      AssignFile(f,'run_res.bat');
      Rewrite(f);
      Writeln(f,'brcc32.exe'+' '+EditName.Text+'.rc');
      CloseFile(f);
      ShellExecute(Handle,'open',PChar('run_res.bat'),nil,nil,SW_SHOWNORMAL);
    end;
end;

procedure TFmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FileExists ('run_res.bat') then DeleteFile('run_res.bat');
  if FileExists (EditName.Text+'.rc') then DeleteFile(EditName.Text+'.rc');
end;

end.
