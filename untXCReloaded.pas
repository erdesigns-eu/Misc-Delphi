{
  DelphiXC v1.0.0 - a lightweight, one-unit, cross-platform XC API Wrapper
  for Delphi 2010 - 10.3 Tokyo by Ernst Reidinga
  https://erdesigns.eu

  This is a simple wrapper unit for XC Reloaded API - M3U 2 STRM Edit.

  (c) Copyrights 2017-2020 Ernst Reidinga <ernst@erdesigns.eu>

  Bugfixes / Updates:
  - Initial Release 1.0.0

  If you use this unit, please give credits to the original author;
  Ernst Reidinga.
}

unit untXCReloaded;

interface

uses
  WinApi.Windows, System.SysUtils, System.Variants, System.Classes,
  Generics.Collections, System.Generics.Defaults, System.StrUtils,
  Winapi.Messages, System.RegularExpressions, idHTTP, System.DateUtils,
  VCL.ComCtrls, untJSONParser, Vcl.Menus;

type
  TXCCategoryIdArray = array of Integer;

  TXCMovie = class;
  TXCSeries = class;

  TXCCategory = class
  private
    FCategoryId: string;
    FCategoryName: string;

    FMovies: TObjectList<TXCMovie>;
    FSeries: TObjectList<TXCSeries>;
  public
    constructor Create;
    destructor Destroy; override;

    property CategoryId: string read FCategoryId;
    property CategoryName: string read FCategoryName;

    property Movies: TObjectList<TXCMovie> read FMovies write FMovies;
    property Series: TObjectList<TXCSeries> read FSeries write FSeries;
  end;

  TXCategories = class
  private
    FList : TObjectList<TXCCategory>;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property Categories: TObjectList<TXCCategory> read FList write FList;

    function AddItem(ACategory: TXCCategory) : TXCCategory;
    function Add : TXCCategory;
  end;

  TXCMovie = class
  private
    FTitle: string;
    FYear: string;
    FId: string;
    FExtension: string;
  public
    constructor Create(ATitle: string; AYear: string; AID: string; AExtension: string);

    property Title: string read FTitle;
    property Year: string read FYear;
    property Id: string read FId;
    property Extension: string read FExtension;
  end;

  TXCEpisode = class
  private
    FTitle: string;
    FSeason: Integer;
    FEpisode: Integer;
    FId: string;
    FExtension: string;
  public
    constructor Create(ATitle: string; ASeason: Integer; AEpisode: Integer; AID: string; AExtension: string);

    property Title: string read FTitle;
    property Season: Integer read FSeason;
    property Episode: Integer read FEpisode;
    property Id: string read FId;
    property Extension: string read FExtension;
  end;

  TXCSeries = class
  private
    FTitle: string;
    FYear: string;
    FEpisodes: TObjectList<TXCEpisode>;
  public
    constructor Create(ATitle: string; AYear: string); virtual;
    destructor Destroy; override;

    property Title: string read FTitle;
    property Year: string read FYear;
    property Episodes: TObjectList<TXCEpisode> read FEpisodes write FEpisodes;
  end;

  TXCUserStatus = (usActive, usBanned, usOther);

  TXCReloadedAccount = class(TPersistent)
  private
    FOnChange: TNotifyEvent;

    FUsername: string;
    FPassword: string;
    FMessage: string;
    FAuth: Boolean;
    FStatus: TXCUserStatus;
    FExpiryDate: TDateTime;
    FIsTrial: Boolean;
    FActiveCons: Integer;
    FCreatedAt: TDateTime;
    FMaxCons: Integer;

    procedure SetUsername(const Value: string);
    procedure SetPassword(const Value: string);
    procedure SetMessage(const Value: string);
    procedure SetAuth(const Value: Boolean);
    procedure SetStatus(const Value: TXCUserStatus);
    procedure SetExpiryDate(const Value: TDateTime);
    procedure SetIsTrial(const Value: Boolean);
    procedure SetActiveCons(const Value: Integer);
    procedure SetCreatedAt(const Value: TDateTime);
    procedure SetMaxCons(const Value: Integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;
  published
    property Username: string read FUsername write SetUsername;
    property Password: string read FPassword write SetPassword;
    property Message: string read FMessage write SetMessage;
    property Auth: Boolean read FAuth write SetAuth;
    property Status: TXCUserStatus read FStatus write SetStatus;
    property ExpiryDate: TDateTime read FExpiryDate write SetExpiryDate;
    property IsTrial: Boolean read FIsTrial write SetIsTrial;
    property ActiveCons: Integer read FActiveCons write SetActiveCons;
    property CreatedAt: TDateTime read FCreatedAt write SetCreatedAt;
    property MaxCons: Integer read FMaxCons write SetMaxCons;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;


  TXCConnectChangeEvent = procedure(Sender: TObject; Connected: Boolean) of object;

  TXCConnectErrorType   = (cetHTTP, cetParser, cetAuthZero);
  TXCConnectErrorEvent  = procedure(Sender: TObject; Error: TXCConnectErrorType; ErrorMsg: string) of object;

  TXCRequestErrorType   = (retHTTP, retParser, retOther);
  TXCRequestErrorEvent  = procedure(Sender: TObject; Error: TXCRequestErrorType; ErrorMsg: string) of object;

  TXCReloadedAPI = class
  private
    FConnected: Boolean;
    FAccount: TXCReloadedAccount;
    FHTTP: TidHTTP;

    FServer: string;
    FPort: string;
    FUser: string;
    FPass: string;

    FMovieCategories  : TXCategories;
    FSeriesCategories : TXCategories;

    FOnConnectChange: TXCConnectChangeEvent;
    FOnAccountChange: TNotifyEvent;
    FOnConnectError : TXCConnectErrorEvent;
    FOnRequestError : TXCRequestErrorEvent;

    procedure SetConnected(const B: Boolean);
  protected
    procedure AccountChange(Sender: TObject);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function APIGetRequest(const AURL: string) : string;

    procedure ConnectToServer(AServer: string; APort: string; AUsername: string; APassword: string);
    procedure Disconnect;
    procedure UpdateConnections;

    procedure LoadMovies(ACategories: TXCCategoryIdArray);
    procedure LoadSeries(ACategories: TXCCategoryIdArray);

    function ExtractMoviesInfo(const AText: string; var AName: string; var AYear: string) : Boolean;
    function CleanFilename(const aFileName: string; const aReplaceWith: Char = '_') : string;
    function DownloadURL(const MovieId: string = ''; const EpisodeID: string = ''; const FileExt: string = '') : string;
  published
    property Connected: Boolean read FConnected write SetConnected;
    property Account: TXCReloadedAccount read FAccount;
    property HTTP: TidHTTP read FHTTP write FHTTP;

    property Server: string read FServer;
    property Port: string read FPort;
    property Username: string read FUser;
    property Password: string read FPass;

    property MovieCategories: TXCategories read FMovieCategories write FMovieCategories;
    property SeriesCategories: TXCategories read FSeriesCategories write FSeriesCategories;

    property OnConnectChange: TXCConnectChangeEvent read FOnConnectChange write FOnConnectChange;
    property OnAccountChange: TNotifyEvent read FOnAccountChange write FOnAccountChange;
    property OnConnectError: TXCConnectErrorEvent read FOnConnectError write FOnConnectError;
    property OnRequestError: TXCRequestErrorEvent read FOnRequestError write FOnRequestError;
  end;

implementation

uses System.Math, System.IOUtils;

const
  BaseA = '%s:%s/player_api.php?username=%s&password=%s';
  BaseB = '%s/player_api.php?username=%s&password=%s';

function IsInCategoryArray(const ACategoryId: Integer; const AArray: TXCCategoryIdArray): Boolean;
var
  I: Integer;
begin
  for I := Low(AArray) to High(AArray) do
    if ACategoryId = AArray[I] then
      Exit(True);
  Result := False;
end;

constructor TXCCategory.Create;
begin
  inherited Create;

  FMovies := TObjectList<TXCMovie>.Create(True);
  FSeries := TObjectList<TXCSeries>.Create(True);
end;

destructor TXCCategory.Destroy;
begin
  FMovies.Free;
  FSeries.Free;
  inherited Destroy;
end;

constructor TXCategories.Create;
begin
  inherited Create;
  FList := TObjectList<TXCCategory>.Create(True);
end;

function TXCategories.AddItem(ACategory: TXCCategory) : TXCCategory;
begin
  if ACategory = nil then
    Result := TXCCategory.Create
  else
    Result := ACategory;
  FList.Insert(FList.Count, Result);
end;

function TXCategories.Add : TXCCategory;
begin
  Result := AddItem(nil);
end;

destructor TXCategories.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

constructor TXCMovie.Create(ATitle: string; AYear: string; AID: string; AExtension: string);
begin
  inherited Create;
  FTitle     := ATitle;
  FYear      := AYear;
  FId        := AID;
  FExtension := AExtension;
end;

constructor TXCEpisode.Create(ATitle: string; ASeason: Integer; AEpisode: Integer; AID: string; AExtension: string);
begin
  inherited Create;
  FTitle     := ATitle;
  FSeason    := ASeason;
  FEpisode   := AEpisode;
  FId        := AID;
  FExtension := AExtension;
end;

constructor TXCSeries.Create(ATitle: string; AYear: string);
begin
  inherited Create;
  FTitle := ATitle;
  FYear  := AYear;
  FEpisodes := TObjectList<TXCEpisode>.Create(True);
end;

destructor TXCSeries.Destroy;
begin
  FEpisodes.Free;
  inherited Destroy;
end;

// XC API User
constructor TXCReloadedAccount.Create;
begin
  inherited Create;
end;

procedure TXCReloadedAccount.SetUsername(const Value: string);
begin
  FUsername := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetPassword(const Value: string);
begin
  FPassword := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetMessage(const Value: string);
begin
  FMessage := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetAuth(const Value: Boolean);
begin
  FAuth := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetStatus(const Value: TXCUserStatus);
begin
  FStatus := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetExpiryDate(const Value: TDateTime);
begin
  FExpiryDate := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetIsTrial(const Value: Boolean);
begin
  FIsTrial := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetActiveCons(const Value: Integer);
begin
  FActiveCons := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetCreatedAt(const Value: TDateTime);
begin
  FCreatedAt := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TXCReloadedAccount.SetMaxCons(const Value: Integer);
begin
  FMaxCons := Value;
  if Assigned(FOnChange) then FOnChange(Self);
end;

destructor TXCReloadedAccount.Destroy;
begin
  inherited Destroy;
end;

// XC API Wrapper
constructor TXCReloadedAPI.Create;
begin
  inherited Create;
  FAccount := TXCReloadedAccount.Create;
  FAccount.OnChange := AccountChange;

  FMovieCategories  := TXCategories.Create;
  FSeriesCategories := TXCategories.Create;
end;

procedure TXCReloadedAPI.AccountChange(Sender: TObject);
begin
  if Assigned(FOnAccountChange) then FOnAccountChange(Self);
end;

procedure TXCReloadedAPI.SetConnected(const B: Boolean);
begin
  if (B <> FConnected) then
  begin
    FConnected := B;
    if Assigned(OnConnectChange) then OnConnectChange(Self, B);
  end;
end;

function TXCReloadedAPI.APIGetRequest(const AURL: string) : string;
var
  S : TStringStream;
begin
  Result := '';
  S := TStringStream.Create('', TEncoding.UTF8);
  try
    HTTP.Get(AURL, S);
    Result := S.DataString;
  finally
    S.Free;
  end;
end;

procedure TXCReloadedAPI.ConnectToServer(AServer: string; APort: string; AUsername: string; APassword: string);

  function StringToXCStatus(Str: string) : TXCUserStatus;
  begin
    Result := usOther;
    if Lowercase(Trim(Str)) = 'active' then
      Result := usActive;
    if Lowercase(Trim(Str)) = 'banned' then
      Result := usBanned;
  end;

var
  R : string;
  J : TJSON;
begin
  FServer := '';
  FPort   := '';
  FUser   := '';
  FPass   := '';
  if Connected then Connected := False;
  if Assigned(HTTP) then
  begin
    R := '';
    try
      R := APIGetRequest(IfThen((APort.Trim <> ''), Format(BaseA, [AServer, APort, AUsername, APassword]), Format(BaseB, [AServer, AUsername, APassword])));
    except
      on E : Exception do if Assigned(FOnConnectError) then FOnConnectError(Self, cetHTTP, E.Message);
    end;
    if (R <> '') then
    try
      J := TJSON.Parse(R);
      if J.Items.ContainsKey('user_info') and J.Items.Items['user_info'].Items.ContainsKey('auth') and
         J.Items.Items['user_info'].Items.Items['auth'].AsBoolean then with Account do
      begin
        FServer := AServer;
        FPort   := APort;
        FUser   := AUsername;
        FPass   := APassword;
        FUsername := IfThen(J.Items.Items['user_info'].Items.ContainsKey('username'), J.Items.Items['user_info'].Items.Items['username'].AsString, '');
        FPassword := IfThen(J.Items.Items['user_info'].Items.ContainsKey('password'), J.Items.Items['user_info'].Items.Items['password'].AsString, '');
        FMessage  := IfThen(J.Items.Items['user_info'].Items.ContainsKey('message'), J.Items.Items['user_info'].Items.Items['message'].AsString, '');
        FAuth     := J.Items.Items['user_info'].Items.ContainsKey('auth') and J.Items.Items['user_info'].Items.Items['auth'].AsBoolean;
        if J.Items.Items['user_info'].Items.ContainsKey('status') then
        FStatus := StringToXCStatus(J.Items.Items['user_info'].Items.Items['status'].AsString);
        if J.Items.Items['user_info'].Items.ContainsKey('exp_date') then
        if (J.Items.Items['user_info'].Items.Items['exp_date'].AsString.ToLower = 'null') or (J.Items.Items['user_info'].Items.Items['exp_date'].AsInteger = 0) then
          FExpiryDate := 0
        else
          FExpiryDate := UnixToDateTime(J.Items.Items['user_info'].Items.Items['exp_date'].AsInt64, False);
        if J.Items.Items['user_info'].Items.ContainsKey('created_at') then
        if (J.Items.Items['user_info'].Items.Items['created_at'].AsString.ToLower = 'null') or (J.Items.Items['user_info'].Items.Items['created_at'].AsInteger = 0) then
          FCreatedAt := 0
        else
          FCreatedAt := UnixToDateTime(J.Items.Items['user_info'].Items.Items['created_at'].AsInt64, False);
        FIsTrial := J.Items.Items['user_info'].Items.ContainsKey('is_trial') and J.Items.Items['user_info'].Items.Items['is_trial'].AsBoolean;
        if J.Items.Items['user_info'].Items.ContainsKey('active_cons') then
          FActiveCons := J.Items.Items['user_info'].Items.Items['active_cons'].AsInteger;
        if J.Items.Items['user_info'].Items.ContainsKey('max_connections') then
          FMaxCons := J.Items.Items['user_info'].Items.Items['max_connections'].AsInteger;
        Connected := True;
      end else
        if Assigned(FOnConnectError) then FOnConnectError(Self, cetAuthZero, '');
    except
      on E : Exception do if Assigned(FOnConnectError) then FOnConnectError(Self, cetParser, E.Message);
    end;
  end;
end;

procedure TXCReloadedAPI.Disconnect;
begin
  with Account do
  begin
    FUsername    := '';
    FPassword    := '';
    FMessage     := '';
    FAuth        := False;
    FStatus      := usOther;
    FExpiryDate  := 0;
    FCreatedAt   := 0;
    FActiveCons  := 0;
    FMaxCons     := 0;
  end;
  Connected := False;
end;

procedure TXCReloadedAPI.UpdateConnections;
var
  R : string;
  J : TJSON;
begin
  if Assigned(HTTP) and Connected then
  begin
    R := '';
    try
      R := APIGetRequest(IfThen((FPort.Trim <> ''), Format(BaseA, [FServer, FPort, FUser, FPass]), Format(BaseB, [FServer, FUser, FPass])));
    except
    end;
    if (R <> '') then
    try
      J := TJSON.Parse(R);
      if J.Items.ContainsKey('user_info') and J.Items.Items['user_info'].Items.ContainsKey('auth') and
         J.Items.Items['user_info'].Items.Items['auth'].AsBoolean then with Account do
      begin
        if J.Items.Items['user_info'].Items.ContainsKey('active_cons') then
          FActiveCons := J.Items.Items['user_info'].Items.Items['active_cons'].AsInteger;
      end
    except
    end;
  end;
end;

{

  Load movies (categories) -> (movies in category)

}
procedure TXCReloadedAPI.LoadMovies(ACategories: TXCCategoryIdArray);

  procedure LoadMovieCategories;
  var
    U : string;
    R : string;
    J : TJSON;
    I : Integer;
  begin
    R := '';
    try
      U := IfThen((FPort.Trim <> ''), Format(BaseA, [FServer, FPort, FUser, FPass]), Format(BaseB, [FServer, FUser, FPass]));
      R := APIGetRequest(Format('%s&action=get_vod_categories', [U]));
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retHTTP, E.Message);
    end;
    if (R <> '') then
    try
      MovieCategories.Categories.Clear;
      J := TJSON.Parse(R);
      if J.IsList then
      for I := 0 to J.ListItems.Count -1 do
      if IsInCategoryArray(J.ListItems.Items[I].Items.Items['category_id'].AsInteger, ACategories) then
      with MovieCategories.Add do
      begin
        FCategoryId   := J.ListItems.Items[I].Items.Items['category_id'].AsString;
        FCategoryName := J.ListItems.Items[I].Items.Items['category_name'].AsString;
      end;
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retParser, E.Message);
    end;
  end;

  procedure LoadMoviesInCategory(const ACategory: TXCCategory);
  var
    U : string;
    R : string;
    J : TJSON;
    I : Integer;
    X : Integer;
    M : TXCMovie;

    N, Y : string;
  begin
    R := '';
    try
      U := IfThen((FPort.Trim <> ''), Format(BaseA, [FServer, FPort, FUser, FPass]), Format(BaseB, [FServer, FUser, FPass]));
      R := APIGetRequest(Format('%s&action=get_vod_streams&category_id=%s', [U, ACategory.CategoryId]));
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retHTTP, E.Message);
    end;
    if (R <> '') then
    try
      ACategory.Movies.Clear;
      J := TJSON.Parse(R);
      if J.IsList then
      for I := 0 to J.ListItems.Count -1 do
      begin
        if ExtractMoviesInfo(J.ListItems.Items[I].Items.Items['name'].AsString, N, Y) then
          M := TXCMovie.Create(
            N,
            Y,
            J.ListItems.Items[I].Items.Items['stream_id'].AsString,
            J.ListItems.Items[I].Items.Items['container_extension'].AsString
          )
        else
         M := TXCMovie.Create(
            J.ListItems.Items[I].Items.Items['name'].AsString,
            '',
            J.ListItems.Items[I].Items.Items['stream_id'].AsString,
            J.ListItems.Items[I].Items.Items['container_extension'].AsString
          );
         ACategory.Movies.Add(M);
      end;

    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retParser, E.Message);
    end;
  end;

var
  I : Integer;
begin
  LoadMovieCategories;
  for I := 0 to MovieCategories.Categories.Count -1 do
  LoadMoviesInCategory(MovieCategories.Categories.Items[I]);
end;

{

  Load series (categories) -> (series in category) -> (episodes in series)

}
procedure TXCReloadedAPI.LoadSeries(ACategories: TXCCategoryIdArray);

  procedure LoadSeriesCategories;
  var
    U : string;
    R : string;
    J : TJSON;
    I : Integer;
  begin
    R := '';
    try
      U := IfThen((FPort.Trim <> ''), Format(BaseA, [FServer, FPort, FUser, FPass]), Format(BaseB, [FServer, FUser, FPass]));
      R := APIGetRequest(Format('%s&action=get_series_categories', [U]));
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retHTTP, E.Message);
    end;
    if (R <> '') then
    try
      SeriesCategories.Categories.Clear;
      J := TJSON.Parse(R);
      if J.IsList then
      for I := 0 to J.ListItems.Count -1 do
      if IsInCategoryArray(J.ListItems.Items[I].Items.Items['category_id'].AsInteger, ACategories) then
      with SeriesCategories.Add do
      begin
        FCategoryId   := J.ListItems.Items[I].Items.Items['category_id'].AsString;
        FCategoryName := J.ListItems.Items[I].Items.Items['category_name'].AsString;
      end;
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retParser, E.Message);
    end;
  end;

  procedure LoadSeriesEpisodes(const ASeries: TXCSeries; const ASeriesId: string);

    function GetSeasonNumber(J: TJSON; var Offset: Integer) : string;
    var
      I : Integer;
    begin
      I := Offset;
      repeat
        Inc(I);
      until J.Items.ContainsKey(I.ToString);
      Offset := I;
      Result := I.ToString;
    end;

  var
    U : string;
    R : string;
    J : TJSON;
    S : Integer;
    I : Integer;
    O : Integer;
    X : TJSON;
    E : TXCEpisode;
  begin
    R := '';
    try
      U := IfThen((FPort.Trim <> ''), Format(BaseA, [FServer, FPort, FUser, FPass]), Format(BaseB, [FServer, FUser, FPass]));
      R := APIGetRequest(Format('%s&action=get_series_info&series_id=%s', [U, ASeriesId]));
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retHTTP, E.Message);
    end;
    if (R <> '') then
    try
      ASeries.Episodes.Clear;
      J := TJSON.Parse(R);
      O := 0;
      if J.Items.ContainsKey('episodes') then
      for S := 0 to J.Items.Items['episodes'].Items.Count -1 do
      begin
        X := J.Items.Items['episodes'].Items.Items[GetSeasonNumber(J.Items.Items['episodes'], O)];
        if X.IsList then
        for I := 0 to X.ListItems.Count -1 do
        begin
          E := TXCEpisode.Create(
             X.ListItems.Items[I].Items.Items['title'].AsString,
             X.ListItems.Items[I].Items.Items['season'].AsInteger,
             X.ListItems.Items[I].Items.Items['episode_num'].AsInteger,
             X.ListItems.Items[I].Items.Items['id'].AsString,
             X.ListItems.Items[I].Items.Items['container_extension'].AsString
          );
          ASeries.Episodes.Add(E);
        end;
      end;
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retParser, E.Message);
    end;
  end;

  procedure LoadSeriesInCategory(const ACategory: TXCCategory);
  var
    U : string;
    R : string;
    J : TJSON;
    I : Integer;
    X : Integer;

    S : TXCSeries;
    N, Y : string;
  begin
    R := '';
    try
      U := IfThen((FPort.Trim <> ''), Format(BaseA, [FServer, FPort, FUser, FPass]), Format(BaseB, [FServer, FUser, FPass]));
      R := APIGetRequest(Format('%s&action=get_series&category_id=%s', [U, ACategory.CategoryId]));
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retHTTP, E.Message);
    end;
    if (R <> '') then
    try
      ACategory.Series.Clear;
      J := TJSON.Parse(R);
      if J.IsList then
      for I := 0 to J.ListItems.Count -1 do
      begin
        // Create series
        if ExtractMoviesInfo(J.ListItems.Items[I].Items.Items['name'].AsString, N, Y) then
          S := TXCSeries.Create(N, Y)
        else
         S := TXCSeries.Create(J.ListItems.Items[I].Items.Items['name'].AsString, '');
        // Add episodes to series
        LoadSeriesEpisodes(S, J.ListItems.Items[I].Items.Items['series_id'].AsString);
        ACategory.Series.Add(S);
      end;
    except
      on E : Exception do if Assigned(FOnRequestError) then FOnRequestError(Self, retParser, E.Message);
    end;
  end;

var
  I : Integer;
begin
  LoadSeriesCategories;
  for I := 0 to SeriesCategories.Categories.Count -1 do
  LoadSeriesInCategory(SeriesCategories.Categories.Items[I]);
end;

function TXCReloadedAPI.ExtractMoviesInfo(const AText: string; var AName: string; var AYear: string) : Boolean;

  function TrimChar(const Str: string; Ch: Char): string;
  var
    S, E : integer;
  begin
    S := 1;
    while (S <= Length(Str)) and (Str[S] = Ch) do Inc(S);
    E:=Length(Str);
    while (E >= 1) and (Str[E] = Ch) do Dec(E);
    SetString(Result, PChar(@Str[S]), E - S + 1);
  end;

const
  Ext1 = '^(.+)\.*(19\d{2}|20(?:0\d|1[0-9]|2[0-9])).*$';
var
  R : TRegEx;
  M : TMatch;
begin
  Result := False;
  R := TRegEx.Create(Ext1, [roIgnoreCase]);
  M := R.Match(AText);
  if (M.Groups.Count = 3) then
  begin
    AName    := Trim(TrimChar(TrimChar(TrimChar(Trim(M.Groups.Item[1].Value), '-'), '('), '['));
    AYear    := M.Groups.Item[2].Value;
    Exit(True);
  end;
end;

function TXCReloadedAPI.CleanFilename(const aFileName: string; const aReplaceWith: Char = '_') : string;
var
  I: integer;
begin
  Result := aFileName;
  for I := High(Result) downto Low(Result) do
  if not TPath.IsValidFileNameChar(Result[I]) then
  if (aReplaceWith = '_') then
    Delete(Result, I, 1)
  else
    Result[I] := aReplaceWith;
end;

function TXCReloadedAPI.DownloadURL(const MovieId: string = ''; const EpisodeID: string = ''; const FileExt: string = '') : string;
const
  MA = '%s:%s/movie/%s/%s/%s.%s';
  MB = '%s/movie/%s/%s/%s.%s';
  SA = '%s:%s/series/%s/%s/%s.%s';
  SB = '%s/series/%s/%s/%s.%s';
var
  U : string;
begin
  Result := '';
  if (MovieId <> '') then
    Result := IfThen((FPort.Trim <> ''), Format(MA, [FServer, FPort, FUser, FPass, MovieId, FileExt]), Format(MB, [FServer, FUser, FPass, MovieId, FileExt]))
  else
  if (EpisodeId <> '') then
    Result := IfThen((FPort.Trim <> ''), Format(SA, [FServer, FPort, FUser, FPass, EpisodeID, FileExt]), Format(SB, [FServer, FUser, FPass, EpisodeID, FileExt]));
end;

destructor TXCReloadedAPI.Destroy;
begin
  FAccount.Free;
  MovieCategories.Free;
  FSeriesCategories.Free;
  inherited Destroy;
end;

end.
