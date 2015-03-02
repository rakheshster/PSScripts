@ECHO OFF
REM Creates a scheduled task. 
REM NOTE: This file must be RunAs with an admin account because the Scheduled Task is set to run with Highest Privileges.
REM See https://social.technet.microsoft.com/forums/windowsserver/en-US/e7ac3a6c-a2fd-434f-ae5a-453c9955a510/what-effect-does-run-with-highest-priviledges-in-task-scheduler-have-on-powershell-scripts

REM Replace the variable below. Must be an admin account as you connect remotely & update the hosts file.
SET ADMINACCOUNT=%USERDOMAIN%\AdminAccount

ECHO If you don't run this with batch file an admin account the task creation will fail!
powershell -Command "(Get-Content .\schtask.xml) -replace '--REPLACE--', '%ADMINACCOUNT%' | Out-File -Encoding ASCII .\schtask-tmp.xml"

schtasks /create /xml .\schtask-tmp.xml /tn "Test2" /ru %ADMINACCOUNT% /rp

del /q schtask-tmp.xml