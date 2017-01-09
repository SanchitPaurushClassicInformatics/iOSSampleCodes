 //
//  LoginViewController.swift
//  TrailHUB
//
//  Created by Chandrakant Goyal on 05/05/16.
//  Copyright © 2016 ClassicInformatics. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,ServiceHelperDelegate {

   
    @IBOutlet weak var textFieldEmail: UITextField!         /*! @brief This property is declared for email field. */
    @IBOutlet weak var textFieldPswd: UITextField!          /*! @brief This property is declared for password field. */
    @IBOutlet weak var buttonSighIn: UIButton!              /*! @brief This property is declared for SignIn Button. */
    @IBOutlet weak var buttonForgotPassword: UIButton!      /*! @brief This property is declared for ForgotPassword Button. */
    @IBOutlet weak var buttonSignUp: UIButton!              /*! @brief This property is declared for SignUp Button. */

    var appWebEngine:ServiceHelper!        /*! @brief This object is declared of ServiceHelper Class */
    var welcomeVC = WelcomeVC()            /*! @brief This object is declared of WelcomeVC Class */
    var notificationStr = String()         /*! @brief This String get notificationType from AppDelegate*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*! @brief Do any additional setup after loading the view, typically from a nib. !*/
        
         /*!
         @brief It checks user is already logged in or not.
         
         @discussion This method get "LoggedUserDict" value from User Defaults, if dcitionary contains values then it moved to next screen.
          
         */
        
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "LoggedUserDict") != nil)
        {
            let myDictionary = defaults.object(forKey: "LoggedUserDict") as! NSDictionary
          
            Singleton.sharedInstance.userInfo = UserInfo.getUserDetailsFromData(myDictionary)
                       
            
            let trailSearchVC = TrailSearchVC(nibName: "TrailSearchVC", bundle: nil)
            trailSearchVC.isSignUP = false
            trailSearchVC.finalNotificationStr = notificationStr
            self.navigationController!.pushViewController(trailSearchVC, animated: true)
        }
        else
        {
            
        }
        addCornerRadiusAndBorder(buttonSighIn) /*! @brief This method set radius to corners and add border to Button !*/
        
        let attributesDictionary = [NSForegroundColorAttributeName: UIColor.white] /*! @brief Attributed Dictionary containd white Color !*/
        
        textFieldEmail.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: attributesDictionary) /*! @brief Add custom color of placeholder in UITextField !*/
        textFieldPswd.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributesDictionary)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        /*! @brief Called right before your view appears. !*/
        
        // Add Screen Tracking
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIDescription, value: "LoginScreen")
        let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as! [NSObject : AnyObject])
        
        /*! @brief Hide status bar from app and fields email and password will blank. !*/
        UIApplication.shared .setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
        textFieldEmail.text = ""
        textFieldPswd.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Textfield Delegate Methods
    
    /*! @brief This method called when keyboard is removed from particular text field.
        @discussion If keyboard is on first text field, then it moves to next and if keyboard is on last textfield, then resign keyboard from textfield.
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch (textField.tag){
        case 10:
            
            textFieldEmail.resignFirstResponder()
            textFieldPswd.becomeFirstResponder()
            break
            
        case 11:
            
            textFieldPswd.resignFirstResponder()
            break
        default:break
            
        }
        
        return true
    }
    
    /*! @brief This method called when user start typing on textfield.
        @discussion animate view upto 185.
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(self.view.window?.bounds.height == 480) {
            animateViewMoving(true, moveValue: 185)
        }
    }
    /*! @brief This method called when user finishes typing on textfield.
       @discussion animate view upto 185.
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if(self.view.window?.bounds.height == 480) {
            animateViewMoving(false, moveValue: 185)
        }
    }
    
    
    /*! @brief This method called for animation.
      @discussion animate view in upward and forward Directions.
     */

    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }

    // MARK: - UIResponder Method
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*! @brief Custom Buttons Action Method and other helper methods. !*/
    @IBAction func CommonButtonsAction(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        switch (sender.tag) {
            
        case 101:           //Sign In Button Action
            
            if(self.isAllFieldVerifiedSignIn()){
                 self.callApiForSignIn()
            }
            
            break
            
        case 102:           //Forgot Password Button Action
            
            let forgotPasswordVC = ForgotPasswordVC(nibName: "ForgotPasswordVC", bundle: nil)
            self.navigationController!.pushViewController(forgotPasswordVC, animated: true)

            break
            
        case 103:           //SignUp Button Action
            
            let signUpSelectionVC = SignUpSelectionVC(nibName: "SignUpSelectionVC", bundle: nil)
            signUpSelectionVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.addSubview(signUpSelectionVC.view)
            self.addChildViewController(signUpSelectionVC)
            signUpSelectionVC.didMove(toParentViewController: self)

            
            break
        default: break
            
        }

    }
    
    /*! @brief CheckValidations.
        @discussion Check validations for empty field, email validation and password must between 4 to 14 characters.   !*/
    
    func isAllFieldVerifiedSignIn() -> Bool {
        
        /*! @brief DTIToastCenter - is custom pop up ie shown on place of default alertViews.!*/
        
        var  isVerified:Bool = false
        if(!isMsgLenth(self.textFieldEmail.text!)){
            
           DTIToastCenter.defaultCenter.makeText(popUpString("Please enter email address."))
        }
        else  if(!validateEmail(self.textFieldEmail.text!)){
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Please enter valid email address."))
        }
        else if(!isMsgLenth(self.textFieldPswd.text!)) {
            
           DTIToastCenter.defaultCenter.makeText(popUpString("Please enter password."))
        }
        else if(isLenthTrue(self.textFieldPswd.text!) < 4 || isLenthTrue(self.textFieldPswd.text!) > 14) {
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Password should be between 4 to 14 characters."))
        }
        else {
            
            isVerified = true
        }
        return isVerified
    }

    /*! @brief ApiCalling Method for SignIN.
     @param  email - Email text typed on emailField.
     @param  password - Password text typed on passwordField.
     @param  deviceType - type of device whether it is iPhone (I) or Android.
     @param  deviceToken - Device token of iPhone Device fron push notification purpose. !*/

    func callApiForSignIn() {
        
        self.view.endEditing(true)
        let deviceT:NSString
        if(UserDefaults.standard.object(forKey: "kDeviceToken") == nil) {
            deviceT = "abc"
        }else {
            deviceT = UserDefaults.standard.object(forKey: "kDeviceToken")! as! NSString
        }

        
        let paramDict : NSMutableDictionary = [ "email" : self.textFieldEmail.text!,
            "password" : self.textFieldPswd.text!,
            "deviceType" : "I",
            "deviceToken" : deviceT ]
        getAppEngine().callPOSTMethod(withData: paramDict, andMethodName: WebMethodType_Login, andController: self)
    }

    
    
    /*! @brief  Service Helper Methods. !*/
    
    func getAppEngine() -> ServiceHelper {
        
        if (appWebEngine == nil) {
            appWebEngine = ServiceHelper.sharedEngine()
        }
        
        appWebEngine.serviceHelperDelegate = self
        return appWebEngine;
    }
    
    
    /*! @brief Service Helper Delegate method - Called when response is OK. !*/
    
    func serviceResponse(_ response: AnyObject!, andMethodName methodName: WebMethodType) {
        
        switch (methodName.rawValue) {
            
        case 0:             //WebMethodType_Login - Handle Response when getting from server.
            
            if let myDictionary = response as? [String : AnyObject] {
                
                Singleton.sharedInstance.userInfo = UserInfo.getUserDetailsFromData(myDictionary as NSDictionary)
              
                /*! @brief Save data in userDefaults for checking user is already logged in. !*/
                let defaults = UserDefaults.standard
                defaults.setValue(myDictionary, forKey: "LoggedUserDict")
                defaults.setValue(textFieldEmail.text, forKey: "LoggedUser")
                
                /*! @brief Move to next Screen "TrailSearchVC". !*/
                let trailSearchVC = TrailSearchVC(nibName: "TrailSearchVC", bundle: nil)
                trailSearchVC.isSignUP = false
                self.navigationController!.pushViewController(trailSearchVC, animated: true)
                
            }
            
            break
            
        default:
            break
        }
    }
    
    /*! @brief Service Helper Delegate method - Called when getting error in response. !*/
    func serviceError(_ response: AnyObject!, andMethodName methodName: WebMethodType) {
        
        var msg:String
        if let myDictionary = response as? [String : AnyObject] {
            msg = myDictionary["message"]! as! String
            
            if(isMsgLenth(msg)) {
                  DTIToastCenter.defaultCenter.makeText(msg)
            }
        }
    }
    
     /*! @brief Service Helper Delegate method - Called when connection is failed due to network connection and request time limit exceeds. !*/
    func connectionFailWithErrorMessage(_ error: String!, andMethodName methodName: WebMethodType) {
        
        if(isMsgLenth(error)){
            
            let alert = UIAlertView()
            alert.title = ""
            alert.message = error                         //"You have lost your network connection."
            alert.addButton(withTitle: "Ok")
            alert.show()
        }
    }

    
}
