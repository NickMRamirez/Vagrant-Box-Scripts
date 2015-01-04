@echo off

REM MANUAL STEP: Eject disks drive
REM MANUAL STEP: Install the VirtualBox guest additions
REM MANUAL STEP: Add shared folder so you can put this batch file on the machine
REM MANUAL STEP: Add this file to the computer and run it


ECHO Do not require CTRL + ALT + DEL on login...
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 1 /f

ECHO Disable Server Manager at startup...
reg add "HKCU\Software\Microsoft\ServerManager" /v DoNotOpenServerManagerAtLogon /t REG_DWORD /d 1 /f

ECHO Disable the display of the Shutdown Event Tracker...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v ShutDownReasonOn /t REG_DWORD /d 0 /f

ECHO Disable password complexity...
set "file=C:\passwordcomplexity.cfg"
secedit /export /cfg %file%
powershell -Command "(Get-Content C:\passwordcomplexity.cfg) | Foreach-Object {$_ -replace '^PasswordComplexity = 1$', 'PasswordComplexity = 0'} | Set-Content C:\passwordcomplexity.cfg"
secedit /configure /db C:\Windows\security\passwordcomplexity.sdb /cfg %file% /areas SECURITYPOLICY
del %file%

ECHO Rename the built-in Administrator account to "vagrant"...
wmic useraccount where name='administrator' rename vagrant

ECHO Change vagrant user password to "vagrant"...
net user vagrant vagrant

ECHO Run gpupdate.exe...
gpupdate

ECHO Set powershell execution script to unrestricted...
powershell -Command Set-ExecutionPolicy Unrestricted

ECHO Update WinRM settings...
winrm quickconfig -q
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
winrm set winrm/config @{MaxTimeoutms="1800000"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}
sc config WinRM start= auto

ECHO Restart the computer...
shutdown /r /f /t 0

