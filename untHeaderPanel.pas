unit untHeaderPanel;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.StdCtrls;

type
  THeaderPanel = class(TCustomPanel)
  private
    { Private declarations }
    FImage: TImage;
    FTitle: TLabel;
    FSubTitle: TLabel;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Image: TImage read FImage;
    property Title: TLabel read FTitle;
    property SubTitle: TLabel read FSubTitle;
  end;

procedure Register;

implementation

constructor THeaderPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  { Create Panel }
  Align             := alTop;
  BevelEdges        := [beBottom];
  BevelKind         := bkTile;
  BevelOuter        := bvNone;
  Color             := clWindow;
  ParentBackground  := False;
  ShowCaption       := False;
  Height            := 73;
  Font.Name         := 'Segoe UI';
  DoubleBuffered    := True;
  { Create Image }
  FImage := TImage.Create(Self);
  FImage.Name       := Format('%sImage', [Name]);
  FImage.Parent     := Self;
  FImage.Align      := alRight;
  FImage.Center     := True;
  FImage.Width      := 71;
  FImage.SetSubComponent(True);
  { Create Title Label }
  FTitle            := TLabel.Create(Self);
  FTitle.AutoSize   := False;
  FTitle.Name       := Format('%sTitle', [Name]);
  FTitle.Parent     := Self;
  FTitle.Left       := 16;
  FTitle.Top        := 16;
  FTitle.Width      := Width - 95;
  FTitle.Anchors    := [akLeft, akTop, akRight];
  FTitle.Font.Style := [fsBold];
  FTitle.WordWrap   := True;
  FTitle.SetSubComponent(True);
  { Create Subtitle Label }
  FSubTitle         := TLabel.Create(Self);
  FSubTitle.AutoSize:= False;
  FSubTitle.Name    := Format('%sSubTitle', [Name]);
  FSubTitle.Parent  := Self;
  FSubTitle.Left    := 16;
  FSubTitle.Top     := 35;
  FSubTitle.Width   := Width - 95;
  FSubTitle.Anchors := [akLeft, akTop, akRight];
  FSubTitle.WordWrap:= True;
  FSubTitle.SetSubComponent(True);
end;

destructor THeaderPanel.Destroy;
begin
  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('ERDesigns', [THeaderPanel]);
end;

end.
