[Setup]
AppName=WSPR
AppVerName=WSPR Version 4.0 r2873

AppCopyright=Copyright (C) 2008-2013 by Joe Taylor, K1JT
DefaultDirName={pf}\WSPR
DefaultGroupName=WSPR

[Files]
Source: "c:\Users\joe\wsjt\wspr\wspr.exe";            DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\wsjt.ico";            DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr\wsprrc.win";          DestDir: "{app}";  Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\wspr\hamlib_rig_numbers";  DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr\rigctl.exe";          DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr\libhamlib-2.dll";     DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr\hamlib*.dll";         DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr\libusb0.dll";         DestDir: "{app}";
Source: "c:\Users\joe\wsjt\wspr\save\Samples\091022_0436.wav";  DestDir: "{app}\save\Samples";  Flags: onlyifdoesntexist
Source: "c:\Users\joe\wsjt\wspr\fcal.exe";            DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\fcal.dat";            DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\fmt.exe";             DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\fmtave.exe";          DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\fmeasure.exe";        DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\gocal.bat";           DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\0230.bat";            DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\wspr0.exe";           DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\WSPR0_Instructions.TXT";  DestDir: "{app}"
Source: "c:\Users\joe\wsjt\wspr\WSPR_4.0_User.pdf";   DestDir: "{app}"


[Icons]
Name: "{group}\WSPR";        Filename: "{app}\WSPR.EXE"; WorkingDir: {app}; IconFilename: {app}\wsjt.ico
Name: "{userdesktop}\WSPR";  Filename: "{app}\WSPR.EXE"; WorkingDir: {app}; IconFilename: {app}\wsjt.ico

