{:JvBandObject wizard.  }
{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvBandObjectDLLWizard.PAS, released on 2001-07-10.

The Initial Developer of the Original Code is Chiang Seng Chang <cs@ctzen.com>
Portions created by Chiang Seng Chang are Copyright (C) 2001 Chiang Seng Chang.
All Rights Reserved.

Contributor(s): ______________________________________.

Last Modified: 2001-mm-dd

You may retrieve the latest version of this file at the Project JEDI home page,
located at http://www.delphi-jedi.org

Known Issues:
-----------------------------------------------------------------------------}

{$I JVCL.INC}

unit JvBandObjectDLLWizard;

interface

uses
  ToolsApi, Windows;

type
  TJvBandObjectDLLWizard = class(TInterfacedObject,
      IOTANotifier, IOTAWizard, IOTARepositoryWizard, IOTAProjectWizard)
  public
    // IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    // IOTAWizard
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
    // IOTARepositoryWizard
    function GetAuthor: string;
    function GetComment: string;
    function GetPage: string;
    {$IFDEF COMPILER6_Up}
    function GetGlyph: Cardinal;
    {$ELSE}
    function GetGlyph: HICON;
    {$ENDIF}

  end;

  TJvBandObjectProjectCreator = class(TInterfacedObject,
      IOTACreator, IOTAProjectCreator)
  public
    // IOTACreator
    function GetCreatorType: string;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;
    // IOTAProjectCreator
    function GetFileName: string;
    function GetOptionFileName: string;
    function GetShowSource: Boolean;
    procedure NewDefaultModule;
    function NewOptionSource(const ProjectName: string): IOTAFile;
    procedure NewProjectResource(const Project: IOTAProject);
    function NewProjectSource(const ProjectName: string): IOTAFile;
  end;

  TJvBandObjectProjectSource = class(TInterfacedObject, IOTAFile)
  private
    FProjectName: string;
  public
    constructor Create(const ProjectName: string);
    // IOTAFile
    function GetSource: string;
    function GetAge: TDateTime;
  end;

  TJvBandType = (zbtInfoBand, zbtCommBand, zbtToolBand, zbtDeskBand);

  TJvBandObjectModuleCreator = class(TInterfacedObject,
      IOTACreator, IOTAModuleCreator)
  private
    FBandName: string;
    FBandDesc: string;
    FBandType: TJvBandType;
  public
    constructor Create(const BandName, BandDesc: string;
      const BandType: TJvBandType);
    // IOTACreator
    function GetCreatorType: string;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;
    // IOTAModuleCreator
    function GetAncestorName: string;
    function GetImplFileName: string;
    function GetIntfFileName: string;
    function GetFormName: string;
    function GetMainForm: Boolean;
    function GetShowForm: Boolean;
    function GetShowSource: Boolean;
    function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    procedure FormCreated(const FormEditor: IOTAFormEditor);
  end;

  TJvBandObjectModuleSource = class(TInterfacedObject, IOTAFile)
  private
    FBandName: string;
    FBandDesc: string;
    FBandType: TJvBandType;
    FModuleIdent: string;
    FFormIdent: string;
    FAncestorIdent: string;
  public
    constructor Create(const BandName, BandDesc: string;
      const BandType: TJvBandType;
      const ModuleIdent, FormIdent, AncestorIdent: string);
    // IOTAFile
    function GetSource: string;
    function GetAge: TDateTime;
  end;

implementation

uses
  SysUtils, Forms, Controls, ComObj,
  JvBandObjectDLLWizardForm;

const
  CRLF = #13#10;
  CRLF2 = #13#10#13#10;
  BAND_TYPE_DESC: array [0..3] of PChar = ('Info', 'Comm', 'Tool', 'Desk');

var
  ProjectModule: IOTAModule;

procedure TJvBandObjectDLLWizard.AfterSave;
begin
end;

procedure TJvBandObjectDLLWizard.BeforeSave;
begin
end;

procedure TJvBandObjectDLLWizard.Destroyed;
begin
end;

procedure TJvBandObjectDLLWizard.Execute;
begin
  with TzWizardForm.Create(Application) do
  try
    if ShowModal <> mrOK then
      Exit;
    with BorlandIDEServices as IOTAModuleServices do
    begin
      ProjectModule := CreateModule(TJvBandObjectProjectCreator.Create);
      CreateModule(TJvBandObjectModuleCreator.Create(EditBandName.Text,
        EditBandDesc.Text, TJvBandType(RgBandType.ItemIndex)));
    end;
  finally
    Free;
  end;
end;

function TJvBandObjectDLLWizard.GetAuthor: string;
begin
  Result := 'Chiang Seng Chang <cs@ctzen.com>';
end;

function TJvBandObjectDLLWizard.GetComment: string;
begin
  Result := 'Creates a Band Object DLL Project.';
end;

{$IFDEF COMPILER6_Up}
function TJvBandObjectDLLWizard.GetGlyph: Cardinal;
{$ELSE}
function TJvBandObjectDLLWizard.GetGlyph: HICON;
{$ENDIF}
begin
  Result := 0;
end;

function TJvBandObjectDLLWizard.GetIDString: string;
begin
  Result := 'ctZen.JvBandObjectDLLWizard';
end;

function TJvBandObjectDLLWizard.GetName: string;
begin
  Result := 'Band Object DLL Wizard';
end;

function TJvBandObjectDLLWizard.GetPage: string;
begin
  Result := '';
end;

function TJvBandObjectDLLWizard.GetState: TWizardState;
begin
  Result := [];
end;

procedure TJvBandObjectDLLWizard.Modified;
begin
end;

{ TJvBandObjectProjectCreator }

function TJvBandObjectProjectCreator.GetCreatorType: string;
begin
  Result := '';
end;

function TJvBandObjectProjectCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TJvBandObjectProjectCreator.GetFileName: string;
begin
  Result := '';
end;

function TJvBandObjectProjectCreator.GetFileSystem: string;
begin
  Result := '';
end;

function TJvBandObjectProjectCreator.GetOptionFileName: string;
begin
  Result := '';
end;

function TJvBandObjectProjectCreator.GetOwner: IOTAModule;
begin
  Result := nil;
end;

function TJvBandObjectProjectCreator.GetShowSource: Boolean;
begin
  Result := False;
end;

function TJvBandObjectProjectCreator.GetUnnamed: Boolean;
begin
  Result := True;
end;

procedure TJvBandObjectProjectCreator.NewDefaultModule;
begin
end;

function TJvBandObjectProjectCreator.NewOptionSource(
  const ProjectName: string): IOTAFile;
begin
  Result := nil;
end;

procedure TJvBandObjectProjectCreator.NewProjectResource(
  const Project: IOTAProject);
begin
end;

function TJvBandObjectProjectCreator.NewProjectSource(
  const ProjectName: string): IOTAFile;
begin
  Result := TJvBandObjectProjectSource.Create(ProjectName);
end;

{ TJvBandObjectProjectSource }

constructor TJvBandObjectProjectSource.Create(const ProjectName: string);
begin
  inherited Create;
  FProjectName := ProjectName;
end;

function TJvBandObjectProjectSource.GetAge: TDateTime;
begin
  Result := -1;
end;

function TJvBandObjectProjectSource.GetSource: string;
begin
  Result :=
    'library ' + FProjectName + ';' + CRLF2 +
    'uses' + CRLF +
    '  ComServ;' + CRLF2 +
    'exports' + CRLF +
    '  DllGetClassObject,' + CRLF +
    '  DllCanUnloadNow,' + CRLF +
    '  DllRegisterServer,' + CRLF +
    '  DllUnregisterServer;' + CRLF2 +
    '{$R *.RES}' + CRLF2 +
    'begin' + CRLF +
    'end.';
end;

constructor TJvBandObjectModuleCreator.Create(const BandName, BandDesc: string;
  const BandType: TJvBandType);
begin
  inherited Create;
  FBandName := BandName;
  FBandDesc := BandDesc;
  FBandType := BandType;
end;

procedure TJvBandObjectModuleCreator.FormCreated(
  const FormEditor: IOTAFormEditor);
begin
end;

function TJvBandObjectModuleCreator.GetAncestorName: string;
begin
  Result := 'JvBandForm';
end;

function TJvBandObjectModuleCreator.GetCreatorType: string;
begin
  Result := sForm;
end;

function TJvBandObjectModuleCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TJvBandObjectModuleCreator.GetFileSystem: string;
begin
  Result := '';
end;

function TJvBandObjectModuleCreator.GetFormName: string;
begin
  Result := FBandName + 'Form';
end;

function TJvBandObjectModuleCreator.GetImplFileName: string;
begin
  Result := '';
end;

function TJvBandObjectModuleCreator.GetIntfFileName: string;
begin
  Result := '';
end;

function TJvBandObjectModuleCreator.GetMainForm: Boolean;
begin
  Result := False;
end;

function TJvBandObjectModuleCreator.GetOwner: IOTAModule;
begin
  Result := ProjectModule;
end;

function TJvBandObjectModuleCreator.GetShowForm: Boolean;
begin
  Result := True;
end;

function TJvBandObjectModuleCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TJvBandObjectModuleCreator.GetUnnamed: Boolean;
begin
  Result := True;
end;

function TJvBandObjectModuleCreator.NewFormFile(const FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result := nil;
end;

function TJvBandObjectModuleCreator.NewImplSource(const ModuleIdent,
  FormIdent, AncestorIdent: string): IOTAFile;
begin
  Result := TJvBandObjectModuleSource.Create(FBandName, FBandDesc, FBandType,
    ModuleIdent, FormIdent, AncestorIdent);
end;

function TJvBandObjectModuleCreator.NewIntfSource(const ModuleIdent,
  FormIdent, AncestorIdent: string): IOTAFile;
begin
  Result := nil;
end;

constructor TJvBandObjectModuleSource.Create(const BandName, BandDesc: string;
  const BandType: TJvBandType; const ModuleIdent, FormIdent, AncestorIdent: string);
begin
  inherited Create;
  FBandName := BandName;
  FBandDesc := BandDesc;
  FBandType := BandType;
  FModuleIdent := ModuleIdent;
  FFormIdent := FormIdent;
  FAncestorIdent := AncestorIdent;
end;

function TJvBandObjectModuleSource.GetAge: TDateTime;
begin
  Result := -1;
end;

function TJvBandObjectModuleSource.GetSource: string;
const
  cSource =
    'unit %3:s;' + CRLF2 +
    'interface' + CRLF2 +
    'uses' + CRLF +
    '  Windows,' + CRLF +
    '  JvBandObject, JvBandForms;' + CRLF2 +
    'type' + CRLF +
    '  // Band Object Factory' + CRLF +
    '  T%0:sFactory = class(Tz%2:sBandObjectFactory)' + CRLF +
    '  end;' + CRLF2 +
    '  // Band Object' + CRLF +
    '  T%0:s = class(Tz%2:sBandObject)' + CRLF +
    '  protected' + CRLF +
    '    function CreateBandForm(const ParentWnd: HWND): TJvBandForm; override;' + CRLF +
    '  end;' + CRLF2 +
    '  // Band Form' + CRLF +
    '  T%4:s = class(T%5:s)' + CRLF +
    '  private' + CRLF +
    '    function GetBandObject: T%0:s;' + CRLF +
    '  public' + CRLF +
    '    property BandObject: T%0:s read GetBandObject;' + CRLF +
    '  end;' + CRLF2 +
    'const' + CRLF +
    '  Class_%0:s: TGUID = ''%6:s'';' + CRLF2 +
    'implementation' + CRLF2 +
    '{$R *.DFM}' + CRLF2 +
    'uses' + CRLF +
    '  ComObj, ComServ;' + CRLF2 +
    '{ T%0:s }' + CRLF2 +
    'function T%0:s.CreateBandForm(const ParentWnd: HWND): TJvBandForm;' + CRLF +
    'begin' + CRLF +
    '  Result := T%4:s.CreateBandForm(ParentWnd, Self);' + CRLF +
    'end;' + CRLF2 +
    '{ T%4:s }' + CRLF2 +
    'function T%4:s.GetBandObject: T%0:s;' + CRLF +
    'begin' + CRLF +
    '  Result := T%0:s(_BandObject);' + CRLF +
    'end;' + CRLF2 +
    'initialization' + CRLF +
    '  T%0:sFactory.Create(ComServer, T%0:s, Class_%0:s,' + CRLF +
    '    ''%0:s'', ''%1:s'', ciMultiInstance, tmApartment);' + CRLF2 +
    'end.';
begin
  Result := Format(cSource, [FBandName, FBandDesc, BAND_TYPE_DESC[Ord(FBandType)],
    FModuleIdent, FFormIdent, FAncestorIdent, CreateClassID]);
end;

end.

