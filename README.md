# Cloudflare-my-ip

A Windows Batch File Script / Command prompt CMD script to obtain and Update Cloudflare API DNS record with your machines localhost or Public Internet facing IP address for Windows.

A script to update a DNS record with either localhost or public internet facing IP address just like Afraid.org would provide.


Keeps your dynamic IP static by using a subdomain instead of your actual IP address when connecting to a IP:PORT you will use DOMAIN:PORT 


Just run this script on the machine with a dynamic IP and then use the domain name to connect in future

# Usage

Download ```curl.cmd``` and put your ```curl.exe``` in the same directory as the script.

# Customization

You can change https://github.com/C0nw0nk/Cloudflare-my-ip/blob/main/curl.cmd#L10-L15 To set your Cloudflare API key and domain information you wish to modify.

You can change ```root_path=%~dp0``` to the directory you wish to use for your curl executable. For example ```root_path=C:\curl_folder\``` By default the script will assume the ```curl.exe``` is inside the same folder as ```curl.cmd```


# Requirements

CURL I strongly recommend this CURL build for Windows.

https://curl.se/download.html#Win64

https://curl.se/download.html#Win32

https://skanthak.homepage.t-online.de/download/curl-7.64.1.cab
