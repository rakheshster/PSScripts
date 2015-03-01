REM Creates a scheduled task. 
REM NOTE: Change the user account below. Must be an admin account as you connect remotely & update the hosts file.
schtasks /create /xml schtask.xml /tn "Update-Hosts" /ru "RAXNET\AdminAccount" /rp