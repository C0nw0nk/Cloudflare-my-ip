@ECHO OFF & setLocal EnableDelayedExpansion
TITLE github.com/C0nw0nk/Cloudflare-my-ip - Cloudflare API Batch FILE CMD Script

:: Copyright Conor McKnight
:: https://github.com/C0nw0nk/Cloudflare-my-ip
:: https://www.facebook.com/C0nw0nk

:: To run this Automatically open command prompt RUN COMMAND PROMPT AS ADMINISTRATOR and use the following command
:: SCHTASKS /CREATE /SC HOURLY /TN "Cons Cloudflare API Script" /RU "SYSTEM" /TR "C:\Windows\System32\cmd.exe /c start /B "C:\path-to\script\curl.cmd"

:: Edit Cloudflare API Key and Set your own domain details

:: CloudFlare API Key | https://developers.cloudflare.com/api/tokens/create
set cf_api_key=APIKEYHERE!
:: Domain name without subdomains
set zone_name=primarydomain.com
:: DNS record to be modified
set dns_record=localhost.primarydomain.com
:: IP Type :
:: ip_type=0 | Localhost
:: ip_type=1 | Public Internet IP (DEFAULT)
:: ip_type=1.1.1.1 | Custom
set ip_type=1

:: End Edit DO NOT TOUCH ANYTHING BELOW THIS POINT UNLESS YOU KNOW WHAT YOUR DOING!

color 0A
%*
SET root_path=%~dp0
SET binary_file=binary.txt

IF NOT DEFINED ip_type (SET ip_type=1)
IF /I "%ip_type%"=="0" (goto :localhost_ip) else (goto :public_ip)
:localhost_ip
:: Get Private IP Land Line Localhost Address
for /f "tokens=1,2* delims=:" %%A in ('
ipconfig ^| find "IPv4 Address"
') do (
    set "tempip=%%~B"
    set "tempip=!tempip: =!"
    ping !tempip! -n 1 -w 50 >Nul
    if !errorlevel!==0 (
        set localip=!tempip!
        goto foundlocal
    )
)
:foundlocal
set ip=%localip%
goto :ip_end

:public_ip
IF /I NOT "%ip_type%"=="1" (
SET ip=%ip_type%
goto :ip_end
)

:: Get IP Address with CURL
for /F %%I in ('
%root_path%curl.exe "https://checkip.amazonaws.com/" 2^>Nul
') do set ip=%%I
rem echo %ip%

:ip_end

:: Get Zone ID number from Cloudflare API
For /f "delims=" %%x in ('
%root_path%curl.exe "https://api.cloudflare.com/client/v4/zones?name=%zone_name%&status=active" -H "Authorization: Bearer %cf_api_key%" -H "content-type:application/json" 2^>Nul
') do set "data=!data!%%x"
:: Remove new lines and put entire response on a single line
set data=%data:"=\"%
rem echo %data%

:: Remove unwanted JSON leaving us with the ID number we want
set cf_zone_id=%data:~23,32%
rem echo %cf_zone_id%

:: Prove the Zone ID number of main domain to Get DNS ID number of the subdomain from Cloudflare API
For /f "delims=" %%x in ('
%root_path%curl.exe "https://api.cloudflare.com/client/v4/zones/%cf_zone_id%/dns_records?type=A&name=%dns_record%" -H "Authorization: Bearer %cf_api_key%" -H "content-type:application/json" 2^>Nul
') do set "data2=!data2!%%x"
:: Remove new lines and put entire response on a single line
set data2=%data2:"=\"%
rem echo %data2%

:: Remove unwanted JSON leaving us with the ID number we want
set cf_id=%data2:~23,32%
rem echo %cf_id%

:: Build our JSON to send to Cloudflare API to Update the DNS record with our current IP address
echo {>%root_path%%binary_file%
echo 	"content": "%ip%",>>%root_path%%binary_file%
echo 	"data": {},>>%root_path%%binary_file%
echo 	"id": "%cf_id%",>>%root_path%%binary_file%
echo 	"name": "%dns_record%",>>%root_path%%binary_file%
echo 	"proxiable": true,>>%root_path%%binary_file%
echo 	"proxied": false,>>%root_path%%binary_file%
echo 	"ttl": 1,>>%root_path%%binary_file%
echo 	"type": "A",>>%root_path%%binary_file%
echo 	"zone_id": "%cf_zone_id%",>>%root_path%%binary_file%
echo 	"zone_name": "%zone_name%">>%root_path%%binary_file%
echo }>>%root_path%%binary_file%

:: Send our JSON to Cloudflare API
For /f "delims=" %%x in ('
%root_path%curl.exe -X PUT "https://api.cloudflare.com/client/v4/zones/%cf_zone_id%/dns_records/%cf_id%" -H "Authorization: Bearer %cf_api_key%" -H "content-type:application/json" --data-binary "@%root_path%%binary_file%" 2^>Nul
') do set "data3=!data3!%%x"
:: Remove new lines and put entire response on a single line
set data3=%data3:"=\"%
rem echo %data3%

:: Delete the binary file
del "%root_path%%binary_file%"

EXIT
