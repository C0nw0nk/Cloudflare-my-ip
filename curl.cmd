@ECHO OFF & setLocal EnableDelayedExpansion
TITLE github.com/C0nw0nk/Cloudflare-my-ip - Cloudflare API Batch FILE CMD Script

:: Copyright Conor McKnight
:: https://github.com/C0nw0nk/Cloudflare-my-ip
:: https://www.facebook.com/C0nw0nk

:: Edit Cloudflare API Key and Set your own domain details

:: CloudFlare API Key
set cf_api_key=APIKEYHERE!
:: Domain name without subdomains
set zone_name=primarydomain.com
:: DNS record to be modified
set dns_record=localhost.primarydomain.com

:: End Edit DO NOT TOUCH ANYTHING BELOW THIS POINT UNLESS YOU KNOW WHAT YOUR DOING!

color 0A
%*
SET root_path=%~dp0

:: Get IP Address with CURL
for /F %%I in ('
%root_path%curl.exe "https://checkip.amazonaws.com/" 2^>Nul
') do set ip=%%I
rem echo %ip%

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
echo {>binary.txt
echo 	"content": "%ip%",>>binary.txt
echo 	"data": {},>>binary.txt
echo 	"id": "%cf_id%",>>binary.txt
echo 	"name": "%dns_record%",>>binary.txt
echo 	"proxiable": true,>>binary.txt
echo 	"proxied": false,>>binary.txt
echo 	"ttl": 1,>>binary.txt
echo 	"type": "A",>>binary.txt
echo 	"zone_id": "%cf_zone_id%",>>binary.txt
echo 	"zone_name": "%zone_name%">>binary.txt
echo }>>binary.txt

:: Send our JSON to Cloudflare API
%root_path%curl.exe -X PUT "https://api.cloudflare.com/client/v4/zones/%cf_zone_id%/dns_records/%cf_id%" -H "Authorization: Bearer %cf_api_key%" -H "content-type:application\/json" --data-binary "@%root_path%binary.txt"

EXIT
