<h1 align="center">Pierrot raspbian install</h1>
<h4 align="center">Raspbian setup for macOS</h4>

<br><br>

## How it works

Set your network options in the `wifi.config` file
```bash
COUNTRY="my-country-ISO-code"
SSID="my-wifi-name"
PSK="my-wifi-assword"
```

Plug your disk and check its identifier, then run the setup
```bash
diskutil list
# My disk identitfier is /dev/disk2
sudo sh setup.sh -d /dev/disk2
```