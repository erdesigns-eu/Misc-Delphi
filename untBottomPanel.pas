unit untBottomPanel;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.StdCtrls, untTranslation;

type
  TBottomPanelType = (ptOkCancel, ptOkCancelApply, ptClose);

  TBottomPanel = class(TCustomPanel)
  private
    { Private declarations }
    FOKButton: TButton;
    FCancelButton: TButton;
    FApplyButton: TButton;
    FCloseButton: TButton;

    FPanelType: TBottomPanelType;
    FTranslation: TTranslation;
    procedure SetPanelType(const T: TBottomPanelType);
    procedure SetTranslation(const ATranslation: TTranslation);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateLanguage;
  published
    { Published declarations }
    property PanelType: TBottomPanelType read FPanelType write SetPanelType default ptOkCancel;

    property OKButton: TButton read FOKButton;
    property CancelButton: TButton read FCancelButton;
    property ApplyButton: TButton read FApplyButton;
    property CloseButton: TButton read FCloseButton;
    property Translation: TTranslation read FTranslation write SetTranslation;
  end;

procedure Register;

implementation

constructor TBottomPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  { Create Panel }
  Align       := alBottom;
  BevelEdges  := [];
  BevelOuter  := bvNone;
  ShowCaption := False;
  Height      := 33;
  Font.Name   := 'Segoe UI';
  { Panel Type }
  FPanelType := ptOkCancel;
  { OK Button }
  FOKButton                       := TButton.Create(Self);
  FOKButton.Caption               := 'OK';
  FOKButton.Parent                := Self;
  FOKButton.AlignWithMargins      := True;
  FOKButton.Margins.Left          := 0;
  FOKButton.Margins.Top           := 1;
  FOKButton.Margins.Right         := 4;
  FOKButton.Margins.Bottom        := 7;
  FOKButton.Align                 := alRight;
  FOKButton.ModalResult           := 1;
  FOKButton.Width                 := 90;
  FOKButton.Name                  := Format('%sOKButton', [Name]);
  FOKButton.SetSubComponent(True);
  FOKButton.Visible               := True;
  { Cancel Button }
  FCancelButton                   := TButton.Create(Self);
  FCancelButton.Caption           := 'Cancel';
  FCancelButton.Parent            := Self;
  FCancelButton.AlignWithMargins  := True;
  FCancelButton.Margins.Left      := 0;
  FCancelButton.Margins.Top       := 1;
  FCancelButton.Margins.Right     := 8;
  FCancelButton.Margins.Bottom    := 7;
  FCancelButton.Align             := alRight;
  FCancelButton.ModalResult       := 2;
  FCancelButton.Width             := 90;
  FCancelButton.Name              := Format('%sCancelButton', [Name]);
  FCancelButton.SetSubComponent(True);
  FCancelButton.Visible           := True;
  { Apply Button }
  FApplyButton                    := TButton.Create(Self);
  FApplyButton.Caption            := 'Apply';
  FApplyButton.Parent             := Self;
  FApplyButton.AlignWithMargins   := True;
  FApplyButton.Margins.Left       := 0;
  FApplyButton.Margins.Top        := 1;
  FApplyButton.Margins.Right      := 8;
  FApplyButton.Margins.Bottom     := 7;
  FApplyButton.Align              := alRight;
  FApplyButton.ModalResult        := 0;
  FApplyButton.Width              := 90;
  FApplyButton.Name               := Format('%sApplylButton', [Name]);
  FApplyButton.SetSubComponent(True);
  FApplyButton.Visible            := False;
  { Apply Button }
  FCloseButton                    := TButton.Create(Self);
  FCloseButton.Caption            := 'Close';
  FCloseButton.Parent             := Self;
  FCloseButton.AlignWithMargins   := True;
  FCloseButton.Margins.Left       := 0;
  FCloseButton.Margins.Top        := 1;
  FCloseButton.Margins.Right      := 8;
  FCloseButton.Margins.Bottom     := 7;
  FCloseButton.Align              := alRight;
  FCloseButton.ModalResult        := 8;
  FCloseButton.Width              := 90;
  FCloseButton.Name               := Format('%sCloseButton', [Name]);
  FCloseButton.SetSubComponent(True);
  FCloseButton.Visible            := False;
end;

procedure TBottomPanel.SetPanelType(const T: TBottomPanelType);
begin
  if (T <> FPanelType) then
  begin
    FPanelType := T;
    case T of
      ptOkCancel:
      begin
        FOKButton.Visible     := True;
        FCancelButton.Visible := True;
        FApplyButton.Visible  := False;
        FCloseButton.Visible  := False;
      end;

      ptOkCancelApply:
      begin
        FOKButton.Visible     := True;
        FCancelButton.Visible := True;
        FApplyButton.Visible  := True;
        FCloseButton.Visible  := False;
      end;

      ptClose:
      begin
        FOKButton.Visible     := False;
        FCancelButton.Visible := False;
        FApplyButton.Visible  := False;
        FCloseButton.Visible  := True;
      end;
    end;
  end;
end;

procedure TBottomPanel.SetTranslation(const ATranslation: TTranslation);
begin
  FTranslation := ATranslation;
  if Assigned(FTranslation) then UpdateLanguage;
end;

procedure TBottomPanel.UpdateLanguage;
begin
  if Assigned(FTranslation) then
  begin
    FOKButton.Caption     := FTranslation.TextOfApplicationConstant('OK');
    FCancelButton.Caption := FTranslation.TextOfApplicationConstant('Cancel');
    FApplyButton.Caption  := FTranslation.TextOfApplicationConstant('Apply');
    FCloseButton.Caption  := FTranslation.TextOfApplicationConstant('Close');
  end;
end;

destructor TBottomPanel.Destroy;
begin
  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('ERDesigns', [TBottomPanel]);
end;

end.
