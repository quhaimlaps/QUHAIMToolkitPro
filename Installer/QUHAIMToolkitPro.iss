#define AppName "QUHAIM Toolkit Pro"
#define AppVersion "0.4.6.2"
#define AppPublisher "QUHAIM Labs"
[Setup]
AppId={{0F3B572B-52D0-4A26-AFFB-60A4D4E9A9C1}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/quhaimlaps/QUHAIMToolkitPro
AppSupportURL=https://github.com/quhaimlaps/QUHAIMToolkitPro/issues
AppUpdatesURL=https://github.com/quhaimlaps/QUHAIMToolkitPro/releases
DefaultDirName={autopf}\QUHAIM Labs\QUHAIM Toolkit Pro
DefaultGroupName=QUHAIM Labs
DisableProgramGroupPage=yes
OutputDir={#ReleaseRoot}
OutputBaseFilename=QUHAIMToolkitProSetup
SetupIconFile={#AppIcon}
UninstallDisplayIcon={app}\Assets\Branding\quhaim-toolkit-pro.ico
Compression=zip/9
SolidCompression=no
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
UsedUserAreasWarning=no
LicenseFile={#SourceRoot}\LICENSE

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "{#SourceRoot}\Assets\*"; DestDir: "{app}\Assets"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\Config\*"; DestDir: "{app}\Config"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\Console\*"; DestDir: "{app}\Console"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\Core\*"; DestDir: "{app}\Core"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\Engine\*"; DestDir: "{app}\Engine"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\Gui\*"; DestDir: "{app}\Gui"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\Launcher\*"; DestDir: "{app}\Launcher"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\Plugins\*"; DestDir: "{app}\Plugins"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceRoot}\Main.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\QUHAIMToolkitPro.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\QUHAIMToolkitPro.Console.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\QUHAIMToolkitPro.Diagnostic.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\NOTICE"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\TRADEMARK.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\TRUST.md"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
Name: "{app}\Data"; Permissions: users-modify
Name: "{app}\Logs"; Permissions: users-modify
Name: "{app}\Reports"; Permissions: users-modify

[Icons]
Name: "{autoprograms}\QUHAIM Labs\QUHAIM Toolkit Pro"; Filename: "{app}\QUHAIMToolkitPro.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\Assets\Branding\quhaim-toolkit-pro.ico"
Name: "{autodesktop}\QUHAIM Toolkit Pro"; Filename: "{app}\QUHAIMToolkitPro.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\Assets\Branding\quhaim-toolkit-pro.ico"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: checkedonce
