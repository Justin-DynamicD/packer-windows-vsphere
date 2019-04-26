@ECHO OFF

ECHO Installing WMF 5.1
powershell -ExecutionPolicy Bypass -command "Invoke-webrequest -uri https://go.microsoft.com/fwlink/?linkid=839516 -outfile C:\Windows\Temp\Win8.1AndW2K12R2-KB3191564-x64.msu"
START /WAIT wusa C:\Windows\Temp\Win8.1AndW2K12R2-KB3191564-x64.msu /quiet /norestart /log:C:\Windows\Temp\wmf.log