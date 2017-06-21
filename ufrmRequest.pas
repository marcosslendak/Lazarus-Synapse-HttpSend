//unit utstsynapese;
unit ufrmRequest;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, httpsend;

type

  { TfrmRequest }

  TfrmRequest = class(TForm)
    btSend: TButton;
    cbTypeSend: TComboBox;
    edProxy: TEdit;
    edPorta: TEdit;
    edUser: TEdit;
    edPassword: TEdit;
    edURL: TEdit;
    lblProxy: TLabel;
    lblPorta: TLabel;
    lblUser: TLabel;
    lblPassword: TLabel;
    lblURL: TLabel;
    mReturn: TMemo;
    mBody: TMemo;
    procedure btSendClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  function ReturnRequest(sMethod: String; sUrl: String; sHeader: String; Var sBody: String; sProxy: String; sPorta: String; sUser: String; sPassword: String): Integer;

var
  frmRequest: TfrmRequest;

implementation

{$R *.lfm}

{ TfrmRequest }

procedure TfrmRequest.btSendClick(Sender: TObject);
var
  sBody: String;
  iResultCode: Integer;
begin

  mReturn.Lines.Clear;
  edURL.Text:=Trim(edURL.Text);
  if Length(cbTypeSend.Text) = 0 then begin
     cbTypeSend.Text:='GET';
  end;

  if Length(edURL.Text) > 0 then begin
     sBody:=Trim(mBody.Text);
     iResultCode := ReturnRequest(cbTypeSend.Text, edURL.Text, '', sBody, edProxy.Text, edPorta.Text, edUser.Text, edPassword.Text);
     mReturn.Lines.Add(sBody);
  end;

end;

function ReturnRequest(sMethod: String; sUrl: String; sHeader: String; Var sBody: String; sProxy: String; sPorta: String; sUser: String; sPassword: String): Integer;
var
  httpSend: THTTPSend;
  slReturn: TStringList;
  liIndex: Longint;
  sReturn: String;
  iResultCode: Integer;
  sResultString: String;
begin
  sReturn:='';
  iResultCode:=404;
  sResultString:='...';

  httpSend:=THTTPSend.Create;
  slReturn:=TStringList.Create;
  try
    try
//      sUrl := EncodeURL(Trim(sUrl));
      if Length(sUrl) > 0 then begin
         if Length(sProxy) > 0 then begin
            httpSend.ProxyHost:=sProxy;
         end;
         if Length(sPorta) > 0 then begin
            httpSend.ProxyPort:=sPorta;
         end;
         if Length(sUser) > 0 then begin
            httpSend.ProxyUser:=sUser;
         end;
         if Length(sPassword) > 0 then begin
            httpSend.ProxyPass:=sPassword;
         end;
         //httpSend.Timeout:=1;
         httpSend.Document.Clear;
         if sMethod = 'POST' then begin
            httpSend.Document.Write(Pointer(sBody)^, Length(sBody));
            httpSend.MimeType:='application/json; charset=UTF-8';
         end;
         if httpSend.HTTPMethod(sMethod, sUrl) then begin
            slReturn.LoadFromStream(httpSend.Document);
            for liIndex:=0 to slReturn.Count-1 do
               sReturn:=sReturn + slReturn[liIndex];
         end;
         iResultCode:=httpSend.ResultCode;
         sResultString:=httpSend.ResultString;
      end;
      httpSend.Clear;
      slReturn.Clear;
      sBody:='';

    except
       on e: Exception do begin
          iResultCode:=404;
          sResultString:=e.Message;
       end;
    end;
  finally
     httpSend.Free;
     slReturn.Free;
  end;
  sBody:='{"code":' + IntToStr(iResultCode);
  sBody:=sBody + ', "status":';
  if iResultCode = 200 then begin
     sBody:=sBody + '"success"';
     if Length(sReturn) > 0 then begin
        sBody:=sBody +  ', "data":' + sReturn;
     end;
  end else begin
     sBody:=sBody + '"error"';
     if Length(sResultString) > 0 then begin
        sBody:=sBody + ', "message":"' + sResultString + '"';
     end;
     if Length(sReturn) > 0 then begin
        sBody:=sBody +  ', "data":"' + sReturn + '"';
     end;
  end;
  sBody:=sBody + '}';
  ReturnRequest:=iResultCode;
end;


end.

