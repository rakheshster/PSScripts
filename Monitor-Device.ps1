 <#
  .SYNOPSIS
  Keeps sending ICMP packets to a device you specify until it's reachable, upon which an email is sent.
  .DESCRIPTION
  Keeps sending ICMP packets to a device you specify until it's reachable, upon which an email is sent to an address you specify from an address you specify. Optionally, the script can wait for the device to be not reachable, and then start sending ICMP packets. 
  .EXAMPLE
  .\Monitor-Device.ps1 -Computer www.rakhesh.com -To abc@example.com -From def@example.com
  .EXAMPLE
  .\Monitor-Device.ps1 -Computer www.rakhesh.com -Wait -To abc@example.com -From def@example.com
  .PARAMETER Device
  The name/ IP address of the device to query. 
  .PARAMETER Wait
  To wait or not to wait before querying?
  .PARAMETER To
  To address.
  .PARAMETER From
  From address.
  .PARAMETER SmtpServer
  Optional SMTP server to use. 
  #>

[CmdletBinding()]
Param (
  [Parameter(Mandatory=$True)]
  [string]$Device, 

  [Parameter(Mandatory=$True)]
  [string]$To, 

  [Parameter(Mandatory=$True)]
  [string]$From,

  [Parameter(Mandatory=$False)]
  [string]$SmtpServer,

  [switch]$Wait
)

# I had a good mind to use regexps to validate the email addresses, but then I read http://www.regular-expressions.info/email.html. :)

if ($Wait) {
    # wait until the server is unreachable
    while (Test-Connection -ComputerName $Device -Quiet -Count 1 -BufferSize 16) {
        Write-Host "[$(get-date -format u)] Waiting for $Device to shutdown"
        Start-Sleep -Seconds 30
    }
}

while (!(Test-Connection -ComputerName $Device -Quiet -Count 1 -BufferSize 16)) {
    Write-Host "[$(get-date -format u)] Waiting for $Device to be reachable"
    Start-Sleep -Seconds 30 
}

if ($SmtpServer) { Send-MailMessage -Subject "$Device now reachable" -To $To -From $From -SmtpServer $SmtpServer } else { Send-MailMessage -Subject "$Device now reachable" -To $To -From $From}