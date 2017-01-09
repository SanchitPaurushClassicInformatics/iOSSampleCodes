//
//  TermsConditionsVC.swift
//  TrailHUB
//
//  Created by Chandrakant Goyal on 24/05/16.
//  Copyright © 2016 ClassicInformatics. All rights reserved.
//

import UIKit

class TermsConditionsVC: UIViewController, ServiceHelperDelegate {
    
    @IBOutlet weak var webViewForTermsCondi: UIWebView! /*! @brief This property is declared for webViewForTermsCondi field. */
    @IBOutlet weak var headingLabel: UILabel! /*! @brief This property is declared for navigation header Label field. */
    var aboutUsString : String = "" /*! @brief Declare string for AboutUS and Term&Condition. */
    
    var appWebEngine:ServiceHelper! /*! @brief This object is declared of ServiceHelper Class */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*! @brief Do any additional setup after loading the view, typically from a nib. !*/
        
        /*!
         @brief It checks user tapped About US or Terms & Condition.
         
         @discussion This method get "aboutUsString" value, if aboutUsString value is true, then it is about us otherwise Terms & Condition and call api accordingly.
         
         */
        

        if aboutUsString == "true"
        {
            headingLabel.text = "About Us"
            self.getAboutUs()
        }
        else
        {
             headingLabel.text = "Terms & Conditions - TrailHUB.org"
             self.getTermsAndConditionApi()
        }
        
       
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    /*! @brief Call Api to get contebt of about Us. */
    func getAboutUs ()
    {
        let paramDict : NSMutableDictionary = NSMutableDictionary()
        getAppEngine().callPOSTMethod(withData: paramDict, andMethodName:WebMethodType_aboutUs, andController: self)
    }
    /*! @brief Call Api to get contebt of Terms & Conditions.
        @param authToken - static authToken of application.
     */
    func getTermsAndConditionApi ()
    {
        let paramDict : NSMutableDictionary = ["authToken" : kAuthConstant]
        getAppEngine().callPOSTMethod(withData: paramDict, andMethodName:WebMethodType_termcondition, andController: self)
        
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
            
        case 3:     //WebMethodType_termcondition
            
            if let myDictionary = response as? [String : AnyObject]
            {
                let htmlTextStr = myDictionary["htmlText"]
                webViewForTermsCondi.loadHTMLString(htmlTextStr as! String, baseURL: nil)
            }
            
            break
            
        case 28:     //WebMethodType_aboutUs
            
            if let myDictionary = response as? [String : AnyObject]
            {
                let htmlTextStr = myDictionary["htmlText"]
                webViewForTermsCondi.loadHTMLString(htmlTextStr as! String, baseURL: nil)
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
                let alert = UIAlertView()
                alert.title = ""
                alert.message = msg
                alert.addButton(withTitle: "Ok")
                alert.show()
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
    

    
    // MARK: - Custom UIButtons Actions
    
    @IBAction func backButtonAction(_ sender: AnyObject) {
        
        self.navigationController!.popViewController(animated: true)
    }
    
}
