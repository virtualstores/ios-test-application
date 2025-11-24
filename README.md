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
	<key>CLIENT_0</key>
	<dict>
		<key>CENTRAL_SERVER_URL</key>
		<string>Your central server</string>
		<key>DATA_SERVER_URL</key>
		<string>Your data server</string>
		<key>USERNAME</key>
		<string>Your username</string>
		<key>PASSWORD</key>
		<string>Your password</string>
		<key>CLIENT_ID</key>
		<integer>1</integer>
	</dict>
</dict>
</plist>
```

In StoreViewController.swift create TestItems, this enables map access.
