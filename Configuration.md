# Configuration Guide

## API Configuration

This app uses The Guardian Open Platform API. You need to configure the API settings in the `Info.plist` file.

### Required Configuration

Add the following keys to your `Info.plist`:

```xml
<key>GuardianAPIBaseURL</key>
<string>https://content.guardianapis.com</string>
<key>GuardianAPIKey</key>
<string>YOUR_API_KEY_HERE</string>
```

### Getting an API Key

1. Visit [The Guardian Open Platform](https://open-platform.theguardian.com/)
2. Sign up for a free account
3. Request an API key
4. Replace `YOUR_API_KEY_HERE` with your actual API key

### Security Notes

- Never commit API keys to version control
- Consider using environment variables or a secure configuration management system for production
- The app will crash on startup if the API key is not configured

### Example Info.plist Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Other configurations -->
    
    <!-- Guardian API Configuration -->
    <key>GuardianAPIBaseURL</key>
    <string>https://content.guardianapis.com</string>
    <key>GuardianAPIKey</key>
    <string>your-actual-api-key-here</string>
</dict>
</plist>
``` 