//
//  ViewController.swift
//  MSAL-Office365-Login
//
//  Created by EOO61 on 19/07/21.
//

import UIKit
import MSAL

class ViewController: UIViewController {

    // Update the below to your client ID you received in the portal. The below is for running the demo only
    let kClientID = "66855f8a-60cd-445e-a9bb-8cd8eadbd3fa"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kRedirectUri = "msauth.com.microsoft.identitysample.MSALiOS://auth"
    
    let kScopes: [String] = ["user.read"]
    
    var accessToken = String()
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?

    var loggingText: UITextView!
    var signOutButton: UIButton!
    var callGraphButton: UIButton!
    var usernameLabel: UILabel!
    
    var currentAccount: MSALAccount?
    
    @IBOutlet weak var updateLogging: UILabel!
    typealias AccountCompletion = (MSALAccount?) -> Void
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        do {
            try self.initMSAL()
        } catch let error {
            updateLogging.text = "Unable to create Application Context \(error)"
            print("Erro: \(error)")
        }
        
    }
    
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            updateLogging.text =  "Unable to create authority URL"
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID,
                                                                  redirectUri: kRedirectUri,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.initWebViewParams()
    }
    
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
    }
    
    @IBAction func loginWithOffice365(_ sender: Any) {
        
                  
                // We check to see if we have a current logged in account.
                // If we don't, then we need to sign someone in.
                self.acquireTokenInteractively()
            
    }
    
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.updateLogging.text = "Could not acquire token: \(error)"
                return
            }
            
            guard let result = result else {
                
                self.updateLogging.text = "Could not acquire token: No result returned"
                return
            }
            
            self.accessToken = result.accessToken
            self.updateLogging.text = "Access token is \(self.accessToken)"
            self.updateCurrentAccount(account: result.account)
            self.getContentWithToken()
        }
    }
    
    func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
        //self.updateAccountLabel()
        //self.updateSignOutButton(enabled: account != nil)
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        /**
         
         Acquire a token for an existing account silently
         
         - forScopes:           Permissions you want included in the access token received
         in the result in the completionBlock. Not all scopes are
         guaranteed to be included in the access token returned.
         - account:             An account object that we retrieved from the application object before that the
         authentication flow will be locked down to.
         - completionBlock:     The completion block that will be called when the authentication
         flow completes, or encounters an error.
         */
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.loggingText.text =  "Could not acquire token silently: \(error)"
                return
            }
            
            guard let result = result else {
                
                self.loggingText.text = "Could not acquire token: No result returned"
                return
            }
            
            self.accessToken = result.accessToken
            self.loggingText.text = "Refreshed Access token is \(self.accessToken)"
            //self.updateSignOutButton(enabled: true)
            self.getContentWithToken()
        }
    }
    
    func getContentWithToken() {
        
        // Specify the Graph API endpoint
        let graphURI = getGraphEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.updateLogging.text = "Couldn't get graph result: \(error)"
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
                self.updateLogging.text =  "Couldn't deserialize result JSON"
                return
            }
            
            DispatchQueue.main.async {
                self.updateLogging.text = "Result from Graph: \(result))"
                
                guard let resultNew = result as? [String:Any] else {
                    return
                }
                let email = resultNew["mail"]  as! String
                print("Email is: \(email)")
                let name = resultNew["displayName"]  as! String
                print("name is: \(name)")
                
                self.nameLabel.text = name
                self.emailLabel.text = email
            }
           
            
            }.resume()
    }
    
    func getGraphEndpoint() -> String {
        return kGraphEndpoint.hasSuffix("/") ? (kGraphEndpoint + "v1.0/me/") : (kGraphEndpoint + "/v1.0/me/");
    }
    
   
    @IBAction func logOutButtonClicked(_ sender: Any) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        guard let account = self.currentAccount else { return }
        
        do {
            
            /**
             Removes all tokens from the cache for this application for the provided account
             
             - account:    The account to remove from the cache
             */
            
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!)
            signoutParameters.signoutFromBrowser = false
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    self.updateLogging.text = "Couldn't sign out account with error: \(error)"
                    return
                }
                
                self.updateLogging.text =  "Sign out completed successfully"
                self.accessToken = ""
                self.updateCurrentAccount(account: nil)
            })
            
        }
    }
    
}


