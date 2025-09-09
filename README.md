# iOS Test Application

This repository enables TT2 testing.

## 1.0 Requirements

In order to run this application the following needs to be created:

Place this file in your root folder:
config.plist
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>SERVER_URL</key>
	<string>Your central server URL</string>
	<key>API_KEY</key>
	<string>Your API key</string>
	<key>CLIENT_ID</key>
	<integer>1</integer>
</dict>
</plist>
```

In StoreViewController.swift create TestItems, this enables map access.
