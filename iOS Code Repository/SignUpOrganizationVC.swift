//
//  SignUpOrganizationVC.swift
//  TrailHUB
//
//  Created by Minni on 24/05/16.
//  Copyright © 2016 ClassicInformatics. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


@objc protocol SignUpOrgDelegate {
    @objc optional  func SignInButtonPressed()
}

class SignUpOrganizationVC: UIViewController,CZPickerViewDelegate,CZPickerViewDataSource,ServiceHelperDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var activityImage: UIImageView!               /*! @brief This property is declared for activityImage. */
    @IBOutlet weak var textFieldOrgName: UITextField!            /*! @brief This property is declared for organization textField. */
    @IBOutlet weak var textFieldContName: UITextField!           /*! @brief This property is declared for contact person name field. */
    @IBOutlet weak var textFieldEmail: UITextField!              /*! @brief This property is declared for email field. */
    @IBOutlet weak var textFieldPassword: UITextField!           /*! @brief This property is declared for passowrd field. */
    @IBOutlet weak var textFieldTown: UITextField!               /*! @brief This property is declared for Town field. */
    
    @IBOutlet weak var buttonSelectActivity: UIButton!           /*! @brief This property is declared for select activity button. */
    @IBOutlet weak var buttonSelectCountry: UIButton!            /*! @brief This property is declared for select country button. */
    @IBOutlet weak var buttonState: UIButton!                    /*! @brief This property is declared for select state button. */
    @IBOutlet weak var buttonRegion: UIButton!                   /*! @brief This property is declared for select region button. */
    @IBOutlet weak var btnCheckBox: UIButton!                    /*! @brief This property is declared for checkbox button. */
    @IBOutlet weak var organizationSignUpButton: UIButton!       /*! @brief This property is declared for signUp button. */
    
    var appWebEngine:ServiceHelper!   /*! @brief This object is declared of ServiceHelper Class. */
    var delegate: SignUpOrgDelegate?  /*! @brief delaration of delegate of SignUpOrgDelegate. */
    
    var activityListArray:NSMutableArray!   /*! @brief mutable array declaration for activities list. */
    var countryListArray:NSMutableArray!    /*! @brief mutable array declaration for countries list. */
    var stateListArray:NSMutableArray!      /*! @brief mutable array declaration for states list. */
    var regionListArray:NSMutableArray!     /*! @brief mutable array declaration for regions list. */
    var townListArray = NSMutableArray()    /*! @brief mutable array declaration for towna list. */
    
    var commonPicker:CZPickerView!          /*! @brief custom pickerView declaration of CZPickerView class. */
    var activityID: NSString!               /*! @brief string declaration to store activityID. */
    var countryID: NSString!                /*! @brief custom pickerView declaration of CZPickerView class. */
    var stateID: NSString!                  /*! @brief custom pickerView declaration of CZPickerView class. */
    var regionID: NSString!                 /*! @brief custom pickerView declaration of CZPickerView class. */
    var townID: NSString!                   /*! @brief custom pickerView declaration of CZPickerView class. */
    
    var autocompleteTableView : UITableView!   /*! @brief tableView declaration. */
    var autocompleteUrls = NSMutableArray()   /*! @brief mutable array declaration for autocompletetableView. */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*! @brief mutableArray allocations. */
        self.activityListArray = []
        self.countryListArray = []
        self.stateListArray = []
        self.regionListArray = []
        
        /*! @brief This method set radius to corners and add border to Button !*/
        addCornerRadiusAndBorder(organizationSignUpButton)
        /*! @brief Attributed Dictionary containd white Color !*/
        let attributesDictionary = [NSForegroundColorAttributeName: UIColor.white]
        
        textFieldOrgName.attributedPlaceholder = NSAttributedString(string: "Organization Name", attributes: attributesDictionary)  /*! @brief Add custom color of placeholder in UITextField !*/
        textFieldContName.attributedPlaceholder = NSAttributedString(string: "Contact Person-First & Last Name", attributes: attributesDictionary)  /*! @brief Add custom color of placeholder in UITextField !*/
        textFieldEmail.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: attributesDictionary)  /*! @brief Add custom color of placeholder in UITextField !*/
        textFieldPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: attributesDictionary)  /*! @brief Add custom color of placeholder in UITextField !*/
        textFieldTown.attributedPlaceholder = NSAttributedString(string: "Town", attributes: attributesDictionary)  /*! @brief Add custom color of placeholder in UITextField !*/
        
        /*! @brief Add Add action to town textfield. !*/
        textFieldTown.addTarget(self, action: #selector(SignUpOrganizationVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        /*! @brief Add Dynamic TableView!*/
        let screenSize : CGSize = UIScreen.main.bounds.size
        autocompleteTableView = UITableView(frame: CGRect(x: 8, y: textFieldTown.frame.origin.y+40, width: screenSize.width-40,height: 120), style: UITableViewStyle.plain)
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.backgroundColor = UIColor.white
        autocompleteTableView.bounces = false
        
        /*! @brief Add dark Gray Shadow to TableView!*/
        autocompleteTableView.clipsToBounds = false
        autocompleteTableView.layer.masksToBounds = false
        autocompleteTableView.layer.shadowColor = UIColor.darkGray.cgColor
        autocompleteTableView.layer.shadowOffset = CGSize(width: 0, height: 0)
        autocompleteTableView.layer.shadowRadius = 5.0
        autocompleteTableView.layer.shadowOpacity = 1.0
        
        self.view.addSubview(autocompleteTableView)
        autocompleteTableView.isHidden = true
        /*! @brief Registyer custom cell for TableView!*/
        autocompleteTableView.register(UINib(nibName: "AutoSuggestionCell", bundle: nil), forCellReuseIdentifier: "AutoSuggestionCell")
        
         /*! @brief Call country and activity api to get list of country and activity. */
        self.getActivityListApi()
        self.getCountryListApi()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*! @brief Add Screen Tracking.*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIDescription, value: "SignUpOrganization Screen")
        let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(builder as! [NSObject : AnyObject])
        
    }
   
    /*! @brief This method called when user tap on towntextfield for editing textfield.
     @discussion If "townListArray" contains value, Call "searchAutocompleteEntriesWithSubstring" with typed string to search in list .
     */

    func textFieldDidChange (_ textField: UITextField)
    {
        //your code
        if townListArray.count == 0
        {
            
            
            
        }
        townID = ""
        if textField == textFieldTown
        {
            if textField.text?.characters.count == 0
            {
                autocompleteTableView.isHidden = true
            }
            else
            {
                let substring = textField.text! as NSString
                searchAutocompleteEntriesWithSubstring(substring)
                
                
            }
        }
        
    }
    
    /*! @brief This method called when user tap on towntextfield for editing textfield.
     @discussion If "townListArray" contains value, Call "searchAutocompleteEntriesWithSubstring" with typed string to search in list and if strin gfound in array then show autocompleteTableView shows to user and user can select from there. If user found string then "ID" must be sent in api and townTextField Text sent to api.
     */
    func searchAutocompleteEntriesWithSubstring(_ substring: NSString)
    {
        autocompleteUrls.removeAllObjects()
        if self.townListArray.count>0
        {
            
            for index in 0  ..< self.townListArray.count  {
                
                let townStringName = (self.townListArray[index] as AnyObject).object(forKey: "townName") as! NSString
                let substringRange : NSRange = townStringName.range(of: substring as String)
                if substringRange.location == 0
                {
                    let dict = self.townListArray[index]
                    autocompleteUrls.insert(dict, at: autocompleteUrls.count)
                }
                else
                {
                }
                
            }
           
            if autocompleteUrls.count>0
            {
                let screenSize : CGSize = UIScreen.main.bounds.size
                autocompleteTableView.isHidden = false
                var arrayCount : Int = autocompleteUrls.count * 32
                if arrayCount > Int (screenSize.height) - 262
                {
                    arrayCount = autocompleteUrls.count * 32-162
                }
                autocompleteTableView.frame.origin.y = textFieldTown.frame.origin.y - CGFloat(arrayCount)+150
                autocompleteTableView.frame.size.height = CGFloat(arrayCount)
                autocompleteTableView.reloadData()
            }
            else
            {
                autocompleteTableView.isHidden = true
            }
            
        }
        else
        {
            
        }
        
    }
   
    /*! @brief TableViewDataSource Method.*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteUrls.count
    }
    
    /*! @brief TableViewDataSource Method.*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let autoCompleteRowIdentifier = "AutoSuggestionCell"
        let cell : AutoSuggestionCell = tableView.dequeueReusableCell(withIdentifier: autoCompleteRowIdentifier, for: indexPath) as! AutoSuggestionCell
        
        let townName = (autocompleteUrls.object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "townName")  as! NSString
        cell.textLbl!.text = townName as String
        
        return cell
    }
    
    /*! @brief TableViewDelegate Method.*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
      
        let townName = (autocompleteUrls.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "townName") as! String
        textFieldTown.text = townName
        townID = (autocompleteUrls.object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "townId") as! NSString
        autocompleteTableView.isHidden = true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - UIResponder Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Textfield Delegate
    
    /*! @brief This method called when user types on any text field.
     @discussion If organization and contactname field contain 0 - 30 characters then it will show on textfields.
     @discussion TextfieldPassword Field must contain 0 - 14 characters.
     */

    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        switch (textField.tag){
        case 10:
            
            if(textFieldOrgName.text?.characters.count >= 30 && range.length == 0) {
                return false
            }
            break
            
        case 11:
            
            if(textFieldContName.text?.characters.count >= 30 && range.length == 0) {
                return false
            }
            break
        case 12:
            
            
            break
        case 13:
            
            if(textFieldPassword.text?.characters.count >= 14 && range.length == 0) {
                return false
            }
            
            break
        case 14:
            
            //            if(textFieldTown.text?.characters.count >= 10 && range.length == 0) {
            //                return false
            //            }
            break
        default:break
            
        }
        
        return true
    }
    
    /*! @brief This method called when keyboard is removed from particular text field.
     @discussion If keyboard is on first text field, then it moves to next and if keyboard is on last textfield, then resign keyboard from textfield.
     */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch (textField.tag){
        case 10:
            
            textFieldOrgName.resignFirstResponder()
            textFieldContName.becomeFirstResponder()
            
            break
            
        case 11:
            
            textFieldContName.resignFirstResponder()
            textFieldEmail.becomeFirstResponder()
            
            break
        case 12:
            
            textFieldEmail.resignFirstResponder()
            textFieldPassword.becomeFirstResponder()
            
            break
        case 13:
            
            textFieldPassword.resignFirstResponder()
            textFieldTown.becomeFirstResponder()
            
            break
        case 14:
            
            textFieldTown.resignFirstResponder()
            
            break
        default:break
            
        }
        
        return true
    }
    /*! @brief This method called when user start typing on textfield.
     @discussion animate view upto 185.
     */
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if(textField.tag == 14) {
            animateViewMoving(true, moveValue: 110)
        }
        
    }
    /*! @brief This method called when user finishes typing on textfield.
     @discussion animate view upto 185.
     */
  

    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if(textField.tag == 14) {
            animateViewMoving(false, moveValue: 110)
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
    
      /*! @brief Back Buttons Action Method. !*/ 
    @IBAction func backButtonAction(_ sender: AnyObject) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navController.popViewController(animated: true)
    }
     /*! @brief Custom Buttons Action Method and other helper methods. !*/
    @IBAction func CommonButtonsAction(_ sender: UIButton) {
        
        self.view.endEditing(true)
        switch (sender.tag) {
            
        case 201:
            if activityListArray.count != 0
            {
                self.PopUpViewForCommonList(1)  //Select Activity Button Action
            }
            break
            
        case 202:
            if countryListArray.count != 0
            {
                self.PopUpViewForCommonList(2)   //Select Country Button Action
            }
            break
            
        case 203:
            if stateListArray.count != 0
            {
                self.PopUpViewForCommonList(3)  //State Button Action
            }
            break
            
        case 204:
            if regionListArray.count != 0
            {
                self.PopUpViewForCommonList(4)  //Region Button Action
            }
            break
            
        case 205:           //Select Terms of Use Button Action
            
            sender.isSelected = !sender.isSelected
            break
            
        case 206:           //Terms of Use Button Action
            
            let termsConditionsVC = TermsConditionsVC(nibName: "TermsConditionsVC", bundle: nil)
            self.navigationController!.pushViewController(termsConditionsVC, animated: true)
            break
            
        case 207:           //Organization Button Action
            
            if(self.isAllFieldVerifiedSignIn()){
                self.callApiForSignUpOrganistaion()
            }
            break
            
        case 208:           //SignIn Button Action
            
            if let delegate = self.delegate ,  (delegate.SignInButtonPressed != nil){
                self.delegate?.SignInButtonPressed!()
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.navController.popViewController(animated: true)
            
            break
        default: break
            
        }
        
    }
   
    /*! @brief CheckValidations.
     @discussion Check validations for empty field, email validation and password must between 4 to 14 characters and Town should not contain special characters and numbers. !*/

    func isAllFieldVerifiedSignIn() -> Bool {
        
        var  isVerified:Bool = false
        
        if(!isMsgLenth(self.textFieldOrgName.text!))
        {
            DTIToastCenter.defaultCenter.makeText(popUpString("Please enter organization name."))
        }
        else if(isLenthTrue(self.textFieldOrgName.text!) < 5) {
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Organization name should be of minimum 6 characters"))
        }
        else if((self.buttonSelectActivity.titleLabel!.text!) == "Select Activity") || ((self.buttonSelectActivity.titleLabel!.text!) == "Activity")
        {
            DTIToastCenter.defaultCenter.makeText(popUpString("Please select Activity."))
        }
        else if(!isMsgLenth(self.textFieldContName.text!)){
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Please enter Contact Person name."))
        }
        else if(!isMsgLenth(self.textFieldEmail.text!)){
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Please enter email address."))
        }
        else  if(!validateEmail(self.textFieldEmail.text!)){
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Please enter valid email address."))
        }
        else if(!isMsgLenth(self.textFieldPassword.text!)) {
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Please enter password."))
        }
        else if(isLenthTrue(self.textFieldPassword.text!) < 4 || isLenthTrue(self.textFieldPassword.text!) > 14) {
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Password should be between 4 to 14 characters."))
        }
        else if((self.buttonSelectCountry.titleLabel!.text!) == "Select Country") || ((self.buttonSelectCountry.titleLabel!.text!) == "Country")
        {
            DTIToastCenter.defaultCenter.makeText(popUpString("Please select Country."))
        }
        else if((self.buttonState.titleLabel!.text!) == "State") || ((self.buttonState.titleLabel!.text!) == "Select State") || ((self.buttonState.titleLabel!.text!) == "Select Province")
        {
            DTIToastCenter.defaultCenter.makeText(popUpString("Please select State."))
        }
        else if((self.buttonRegion.titleLabel!.text!) == "Region") || ((self.buttonRegion.titleLabel!.text!) == "Select Region")
        {
            DTIToastCenter.defaultCenter.makeText(popUpString("Please select Region."))
        }
        else if(!isMsgLenth(self.textFieldTown.text!))
        {
            DTIToastCenter.defaultCenter.makeText(popUpString("Please enter Town."))
            
        }
        else  if(!filterSpecialCharatersAndNumbers(self.textFieldTown.text!)){
            
            DTIToastCenter.defaultCenter.makeText(popUpString("Town should not contain special characters and numbers."))
        }
            
        else if(!self.btnCheckBox.isSelected) {
            DTIToastCenter.defaultCenter.makeText(popUpString("Please accept terms & conditions."))
        }
        else {
            
            isVerified = true
        }
        return isVerified
    }
    
    /*! @brief This method called for open pickerView to select values. */
    
    func PopUpViewForCommonList(_ type: NSInteger) { //type = 1 for activity, type = 2 for country, type = 3 for State, type = 4 for Region
        
        if type == 1
        {
            commonPicker = CZPickerView.init(headerTitle: "Select Activity", cancelButtonTitle: "Cancel", confirmButtonTitle: "Done")
            commonPicker.tag = 1
        }
        if type == 2
        {
            commonPicker = CZPickerView.init(headerTitle: "Select Country", cancelButtonTitle: "Cancel", confirmButtonTitle: "Done")
            commonPicker.tag = 2
        }
        if type == 3
        {
            commonPicker = CZPickerView.init(headerTitle: "Select State", cancelButtonTitle: "Cancel", confirmButtonTitle: "Done")
            commonPicker.tag = 3
        }
        if type == 4
        {
            commonPicker = CZPickerView.init(headerTitle: "Select Region", cancelButtonTitle: "Cancel", confirmButtonTitle: "Done")
            commonPicker.tag = 4
        }
        
        
        commonPicker.delegate = self
        commonPicker.dataSource = self
        commonPicker.needFooterView = false
        commonPicker.show()
    }
    
    /*! @brief custom PickerView Delegate Methods.
      @return return values which will show on pickerview as pickerview content
      */
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        
        if pickerView.tag == 1
        {
            return (self.activityListArray[row] as AnyObject).object(forKey: "activityName") as! String
        }
        if pickerView.tag == 2
        {
            return (self.countryListArray[row] as AnyObject).object(forKey: "countryName") as! String
        }
        if pickerView.tag == 3
        {
            return (self.stateListArray[row] as AnyObject).object(forKey: "stateName") as! String
        }
        if pickerView.tag == 4
        {
            return (self.regionListArray[row] as AnyObject).object(forKey: "regionName") as! String
        }
        return nil
        
        
    }
   
    /*! @brief custom PickerView Delegate Methods.
     @return return image icon url which will show on pickerview as pickerview content
      */

    func czpickerView(_ pickerView: CZPickerView!, imageForRow row: Int) -> String!
    {
        if pickerView.tag == 1
        {
            return (self.activityListArray[row] as AnyObject).object(forKey: "icon") as! String
        }
        if pickerView.tag == 2
        {
            return ""
        }
        if pickerView.tag == 3
        {
            return ""
        }
        if pickerView.tag == 4
        {
            return ""
        }
        return nil
    }
    
    /*! @brief custom PickerView Delegate Methods.
     @return return number of rows in pickerview.
      */
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        
        if pickerView.tag == 1
        {
            return self.activityListArray.count
        }
        if pickerView.tag == 2
        {
            return self.countryListArray.count
        }
        if pickerView.tag == 3
        {
            return self.stateListArray.count
        }
        if pickerView.tag == 4
        {
            return self.regionListArray.count
        }
        
        
        return 0
    }
    
    /*! @brief custom PickerView Delegate Methods.
     @discussion get image name and id of tapped row by user from pickerview.
      */
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        
        if pickerView.tag == 1
        {
            activityID = (self.activityListArray[row] as! NSDictionary).object(forKey: "activityId") as! NSString
            let returnStr = (self.activityListArray[row] as! NSDictionary).object(forKey: "activityName")  as! NSString
            self.buttonSelectActivity.setTitle(returnStr as String, for: UIControlState())
            
            let imageStr = (self.activityListArray[row] as AnyObject).object(forKey: "icon") as! String
            if (imageStr == "")
            {
                activityImage.image = nil
            }
            else
            {
                activityImage.setImageWith(URL(string: imageStr), placeholderImage: UIImage(named:"Nordic-AT-Backcountry"))
            }
            
        }
        if pickerView.tag == 2
        {
            countryID = (self.countryListArray[row] as! NSDictionary).object(forKey: "countryId") as! NSString
            let returnStr = (self.countryListArray[row] as AnyObject).object(forKey: "countryName") as! String
            self.buttonSelectCountry.setTitle(returnStr, for: UIControlState())
            stateListArray =  NSMutableArray.init(array:  (self.countryListArray[row] as AnyObject).object(forKey: "countryState") as! NSArray)
            
            if returnStr == "USA"
            {
                self.buttonState.setTitle("Select State", for: UIControlState())
                let dict = NSMutableDictionary()
                let regionArray = NSMutableArray()
                dict.setObject("Select State", forKey: "stateName" as NSCopying)
                dict.setObject(regionArray, forKey: "regions" as NSCopying)
                dict.setObject("", forKey: "stateId" as NSCopying)
                let stateMutableArray = stateListArray.mutableCopy()
                (stateMutableArray as AnyObject).insert(dict, at: 0)
                stateListArray = stateMutableArray as! NSMutableArray
            }
            else if returnStr == "Canada"
            {
                self.buttonState.setTitle("Select Province", for: UIControlState())
                
                let dict = NSMutableDictionary()
                let regionArray = NSMutableArray()
                dict.setObject("Select Province", forKey: "stateName" as NSCopying)
                dict.setObject(regionArray, forKey: "regions" as NSCopying)
                dict.setObject("", forKey: "stateId" as NSCopying)
                let stateMutableArray = stateListArray.mutableCopy()
                (stateMutableArray as AnyObject).insert(dict, at: 0)
                stateListArray = stateMutableArray as! NSMutableArray
                
                
            }
            else
            {
                self.buttonState.setTitle("State", for: UIControlState())
            }
            self.buttonRegion.setTitle("Region", for: UIControlState())
            
        }
        if pickerView.tag == 3
        {
            stateID = (self.stateListArray[row] as! NSDictionary).object(forKey: "stateId") as! NSString
            let returnStr = (self.stateListArray[row] as AnyObject).object(forKey: "stateName") as! String
            self.buttonState.setTitle(returnStr, for: UIControlState())
            self.buttonRegion.setTitle("Select Region", for: UIControlState())
            regionListArray =  NSMutableArray.init(array:  (self.stateListArray[row] as AnyObject).object(forKey: "regions") as! NSArray)
            let dict = NSMutableDictionary()
            dict.setObject("Select Region", forKey: "regionName" as NSCopying)
            dict.setObject("", forKey: "regionId" as NSCopying)
            let regionMutableArray = regionListArray.mutableCopy()
            (regionMutableArray as AnyObject).insert(dict, at: 0)
            regionListArray = regionMutableArray as! NSMutableArray
        }
        if pickerView.tag == 4
        {
            regionID = (self.regionListArray[row] as! NSDictionary).object(forKey: "regionId") as! NSString
            let returnStr = (self.regionListArray[row] as AnyObject).object(forKey: "regionName") as! String
            self.buttonRegion.setTitle(returnStr, for: UIControlState())
            
            if  (self.regionListArray[row] as AnyObject).object(forKey: "town") != nil
            {
                townListArray =  NSMutableArray.init(array:  (self.regionListArray[row] as AnyObject).object(forKey: "town") as! NSArray)
               
            }
            
            
        }
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!) {
        
    }
    
    
    /*! @brief Call Api to get list of all activities. 
        @param authToken - Pass static authToken.
     */
    func getActivityListApi ()
    {
        let paramDict : NSMutableDictionary = ["authToken" : kAuthConstant]
        getAppEngine().callPOSTMethod(withData: paramDict, andMethodName:WebMethodType_ActivityList, andController: self)
        
    }
    /*! @brief Call Api to get list of all Countries.
     @param authToken - Pass static authToken.
     */
    func getCountryListApi ()
    {
        let paramDict : NSMutableDictionary = ["authToken" : kAuthConstant]
        getAppEngine().callPOSTMethod(withData: paramDict, andMethodName:WebMethodType_CountryList, andController: self)
        
    }
    
    /*! @brief Call Api to SignUP.
     @param organizationName, activityId, email, password, countryId, stateId, regionId, contactPersonName, userType, deviceType, deviceToken, townId.
     @ discussion - Call Post Method
     */
    
    func callApiForSignUpOrganistaion() {
        
        self.view.endEditing(true)
        let deviceT:NSString
        if(UserDefaults.standard.object(forKey: "kDeviceToken") == nil) {
            deviceT = ""
        }else {
            deviceT = UserDefaults.standard.object(forKey: "kDeviceToken")! as! NSString
        }
        
        
        let paramDict : NSMutableDictionary = [ "organizationName" : self.textFieldOrgName.text!,
                                                "activityId" : activityID,
                                                "email" : self.textFieldEmail.text!,
                                                "password" : self.textFieldPassword.text!,
                                                "countryId" : countryID,
                                                "stateId" : stateID,
                                                "regionId" : regionID,
                                                
                                                "contactPersonName" : self.textFieldContName.text!,
                                                "userType" : "O",
                                                "deviceType" : "I",
                                                "deviceToken" : deviceT ]
        if townID == ""
        {
            paramDict.setObject(self.textFieldTown.text!, forKey: "townId" as NSCopying)
        }
        else
        {
            paramDict.setObject(townID, forKey: "townId" as NSCopying)
        }
        
        getAppEngine().callPOSTMethod(withData: paramDict, andMethodName: WebMethodType_signUpOrganization, andController: self)
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
            
        case 4:     //WebMethodType_ActivityList
            
            if let myDictionary = response as? [String : AnyObject]
            {
                //activity
                activityListArray = NSMutableArray.init(array:  myDictionary["records"] as! NSArray)
                let dict = NSMutableDictionary()
                dict.setObject("Select Activity", forKey: "activityName" as NSCopying)
                dict.setObject("", forKey: "icon" as NSCopying)
                dict.setObject("", forKey: "activityId" as NSCopying)
                let activityMutableArray = activityListArray.mutableCopy()
                (activityMutableArray as AnyObject).insert(dict, at: 0)
                activityListArray = activityMutableArray as! NSMutableArray
                buttonSelectActivity.setTitle("Select Activity", for: UIControlState())
            }
            
            break
            
        case 5:     //WebMethodType_CountryList
            
            if let myDictionary = response as? [String : AnyObject]
            {
                //country
                countryListArray = NSMutableArray.init(array:  myDictionary["records"] as! NSArray)
                let dict = NSMutableDictionary()
                let countryArray = NSMutableArray()
                dict.setObject("Select Country", forKey: "countryName" as NSCopying)
                dict.setObject("", forKey: "countryId" as NSCopying)
                dict.setObject(countryArray, forKey: "countryState" as NSCopying)
                let countryMutableArray = countryListArray.mutableCopy()
                (countryMutableArray as AnyObject).insert(dict, at: 0)
                countryListArray = countryMutableArray as! NSMutableArray
                
                buttonSelectCountry.setTitle("Select Country", for: UIControlState())
            }
            
            break
            
        case 6:     //WebMethodType_signUpOrganization
            
            if let myDictionary = response as? [String : AnyObject] {
                
                Singleton.sharedInstance.userInfo = UserInfo.getUserDetailsFromSignUpOrg(myDictionary as NSDictionary)
               
                
                let trailSearchVC = TrailSearchVC(nibName: "TrailSearchVC", bundle: nil)
                trailSearchVC.isSignUP = true
                trailSearchVC.signUpType = "Organisation"
                trailSearchVC.emailIdForWelcomeVC = Singleton.sharedInstance.userInfo.email
                self.navigationController!.pushViewController(trailSearchVC, animated: true)
                
                
                //user default key for search in TrailSearch screen
                let defaults = UserDefaults.standard
                defaults.setValue(myDictionary, forKey: "LoggedUserDict")
                
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


