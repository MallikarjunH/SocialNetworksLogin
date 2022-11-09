//
//  ViewController.swift
//  Google-SignIn
//
//  Created by EOO61 on 04/11/22.
//

/*
   //Step 1: Add pod 'GoogleSignIn' file into your project and install
   //Step 2: Need to create and get new  "OAuth client ID". Here is the link -https://developers.google.com/identity/sign-in/ios/start-integrating
   //Step 3: Add a URL scheme for Google Sign-In to your project - steps (check preveous link)
   //Step 4: check this link https://developers.google.com/identity/sign-in/ios/sign-in
*/

import UIKit
import GoogleSignIn

class ViewController: UIViewController {

    let signInConfig = GIDConfiguration(clientID: "519260288793-aclhkk0tpae93l3e60gveu6agqjvutja.apps.googleusercontent.com")
    
    @IBOutlet weak var signInGoogleImg: UIImageView!
    @IBOutlet weak var logoutButtonOutlet: UIButton!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
                self.logoutButtonOutlet.isHidden =  true
            } else {
                // Show the app's signed-in state.
                self.logoutButtonOutlet.isHidden =  false
            }
        }
        
        //enable it only when user signined successfully
        self.userProfileImage.layer.cornerRadius = 30
        self.userProfileImage.clipsToBounds = true
        self.userNameLabel.isHidden = true
        self.userEmailLabel.isHidden = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(googleSignInButton(tapGestureRecognizer:)))
        signInGoogleImg.isUserInteractionEnabled = true
        signInGoogleImg.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func googleSignInButton(tapGestureRecognizer: UITapGestureRecognizer){
        // Your action
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }

            // If sign in succeeded, display the app's main content View.
            
            let emailAddress = user?.profile?.email
            let fullName = user?.profile?.name
            //let givenName = user?.profile?.givenName
            //let familyName = user?.profile?.familyName
           
            let profilePicUrl = user?.profile?.imageURL(withDimension: 320) //image URL
            
            DispatchQueue.main.async {
                self.userNameLabel.isHidden = false
                self.userEmailLabel.isHidden = false
                self.userNameLabel.text = "Name: \(fullName ?? "")"
                self.userEmailLabel.text = "EmailId: \(emailAddress ?? "")"
                self.downloadImage(from: profilePicUrl!)
            }
          }
    }
    
    //MARK: Logout Button Action
    @IBAction func logoutButtonAction(_ sender: Any) {
        
        GIDSignIn.sharedInstance.signOut()
        self.logoutButtonOutlet.isHidden =  true
        self.userNameLabel.isHidden = false
        self.userEmailLabel.isHidden = false
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.userProfileImage.image = UIImage(data: data)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}

