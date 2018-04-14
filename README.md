<p align="center"><img src="https://raw.githubusercontent.com/pierrot-app/site/master/src/assets/images/Logo.svg"></p>

<h1 align="center">Pierrot raspberry pi install</h1>
<h4 align="center">Raspbian setup with ease</h4>

<br><br>

## How it works

Plug your disk and check its identifier
```bash
diskutil list
```

Set your options in the `setup.config` file
```bash
DISK="/dev/<myDiskIdentifier>"
SSID="my-wifi-name"
PSK="my-wifi-assword"
```

Once you identified your disk, unmount it and run the script
```bash
diskutil unmountDisk /dev/<myDiskIdentifier>
sudo sh setup.sh
```