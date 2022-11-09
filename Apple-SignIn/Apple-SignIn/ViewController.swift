//
//  ViewController.swift
//  Apple-SignIn
//
//  Created by EOO61 on 09/11/22.
//

//Tutorial Link for Integration - https://medium.com/@priya_talreja/sign-in-with-apple-using-swift-5cd8695a46b6


import UIKit
import AuthenticationServices

class ViewController: UIViewController, ASAuthorizationControllerDelegate {
    
    @IBOutlet weak var sampleView: UIView!
    var userIdValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Test")
        self.setUpSignInAppleButton()
    }
    
    //Add Sign In with Apple Button.
    func setUpSignInAppleButton() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        authorizationButton.cornerRadius = 5
        //Add button on some view or stack
        self.sampleView.addSubview(authorizationButton)
    }
    
    //Function to create a request using ASAuthorizationAppleIDProvider and initialize a controller ASAuthorizationController to perform the request.
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self //this need to add i.e need to confirm prototcol - ASAuthorizationControllerDelegate
        authorizationController.performRequests()
    }
    
    //Conform to ASAuthorizationControllerDelegate
    //Below function is called after successful Sign In.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
            self.userIdValue = userIdentifier
        }
        //Actual Output: User id is 000432.8e85d399f61d427199a18dbdf75d2c9f.1020
        // Full Name is Optional(givenName: Mallikarjun familyName: Hanagandi )
        //   Email id is Optional("mallikarjun.h@emudhra.com")
        
        
        //Note: Check Credential State
        //On successful authorization, we get User Info which has User Identifier.
        // We can use that identifier to check the user’s credential state by calling the getCredentialState(forUserID:completion:) method:
        self.checkAndGetCCredentialState(userID: self.userIdValue)
    }
    
    //You can handle error in the below function.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    func checkAndGetCCredentialState(userID:String) {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userID) {  (credentialState, error) in
            switch credentialState {
            case .authorized:
                debugPrint("The Apple ID credential is valid.")
                break
            case .revoked:
                debugPrint("The Apple ID credential is revoked.")
                break
            case .notFound:
                debugPrint("No credential was found, so show the sign-in UI.")
            default:
                break
            }
        }
        
    }
}

