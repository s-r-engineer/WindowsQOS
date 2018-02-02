# WindowsQOS

## Automated QOS management

Script for automated QOS management (for WUS in my case, port = 8530) in supported Windows operation systems via scheduler for example.<br>
Tested on Windows Server 2012R2 and Windows 10 PRO<br>
While testing we encountered a trouble. Windows can't manage a lot of QOS policies creating or removing. Because of that I used cycles.

### Usage:

Dict **$table_begin** must contains networks to operate in format **IP**=**bandwidth in MB** where **IP** must be a string<br>
Logs will be written in **"script folder"\logs**<br>
You can change cycles amount by modifying variable **$attempt**

`powershell.exe qos.ps1 (setup|drop)`
