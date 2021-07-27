//
//  IntegrationGuide.swift
//  MSALogin
//
//  Created by EOO61 on 27/07/21.
//

import Foundation

//Step 1 - Install pod file
    //   pod 'MSAL'

//Step 2 - to register and get client Id, follow the steps mentioned in the following URL
//URL - https://docs.microsoft.com/en-us/azure/active-directory/develop/tutorial-v2-ios
//Sample Project Code - https://github.com/Azure-Samples/ms-identity-mobile-apple-swift-objc

//Step 3 - Go to Signing & Capabilities
    //   - Add Keychain Sharing (add this one if not present)
    //   - Inside keychain Groups, add your bundle id (com.mallikarjun.msalLogin) and com.microsoft.adalcache

//Step 4 - Goto info.plist and add following, and update your bundle identifier inside code
/*
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>msauth.com.mallikarjun.msalLogin</string>
        </array>
    </dict>
</array>
<key>CFBundleVersion</key>
<string>1</string>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>msauth</string>
    <string>msauthv2</string>
    <string>msauthv3</string>
</array>
*/

//Step 5 - Go to Target, click on Info tab, and goto URL Types and add one + button, and add following URL there
     //  - msauth.com.mallikarjun.msalLogin

//Step 6 - In AppDelegate class, add necessary code - check the current project

//Step 7 - Add UI and Code for Login with 365 in Login Screen - - check the current project
