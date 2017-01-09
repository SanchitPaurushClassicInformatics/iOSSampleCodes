    //
    //  TrailDetailScreenVC.swift
    //  TrailHUB
    //
    //  Created by Chandrakant Goyal on 02/06/16.
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
    
    fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l > r
        default:
            return rhs < lhs
        }
    }
    
     /*! @brief declare completion handler method to get polyline and coordinate bounds. */
    typealias CompletionHandler = (_ gmsBounds: GMSCoordinateBounds, _ polyline:GMSPolyline, _ success:Bool) -> Void
    
    class TrailDetailScreenVC: UIViewController,ServiceHelperDelegate, GMSMapViewDelegate, UITableViewDelegate, UITableViewDataSource, XMLParserDelegate,xmlParserDelegate{
        
        
        /*! @brief Declaration for KML Parsing !*/
        var parser = XMLParser()
        var pathArray = NSMutableArray()
        var coordinateArray = NSMutableArray()
        var coordinateDict = NSMutableDictionary()
        var element = NSString()
        var coordinateString = NSMutableString()
        var polylineWithPath = GMSPolyline()
        var coordinatesBound = GMSCoordinateBounds()
        
        
        /*! @brief Map and googleMaps and directionsButton property !*/
        var mapView = GMSMapView()
        var googleMapsButton : MyButton!
        var directionsButton : MyButton!
        
        
        @IBOutlet weak var infoHeaderBtn: MIBadgeButton! /*! @brief This property is declared for infoHeaderBtn type of custom MIBadgeButton. */
        @IBOutlet weak var trailHeaderBtn: MIBadgeButton! /*! @brief This property is declared for trailHeaderBtn type of custom MIBadgeButton. */

        @IBOutlet weak var msgHeaderBtn: MIBadgeButton! /*! @brief This property is declared for msgHeaderBtn type of custom MIBadgeButton. */

        
        @IBOutlet weak var orgInfoBtn: UIButton!  /*! @brief This property is declared for orgInfoBtn. */

        @IBOutlet weak var labelMovableInfo: MarqueeLabel!   /*! @brief This property is declared for MarqueeLabel ie movable with animation. */
        var tableViewTrailDetail: UITableView!   /*! @brief tableView declaration. */
        
        /*! @brief Below All label declared to set dynamic values on header. */
        @IBOutlet weak var activityNameTrailSearchLabel: UILabel!
        @IBOutlet weak var totalTrailSearchLabel: UILabel!
        @IBOutlet weak var totalOpenTrailSearchLabel: UILabel!
        @IBOutlet weak var stateCountryTrailSearchLabel: UILabel!
        @IBOutlet weak var openMilesLabel: UILabel!

        @IBOutlet weak var mapAndListBtn: UIButton! /*! @brief This property is declared for mapAndListBtn. */
        @IBOutlet weak var favoritepopUpView: UIView! /*! @brief This property is declared for custom PopView. */
        
        var refreshControl: UIRefreshControl!     /*! @brief This object is declared for pullToRefresh Control. */
        var appWebEngine:ServiceHelper!          /*! @brief This object is declared of ServiceHelper Class. */
       
        // New Params
        var activityName : String!   /*! @brief string declaration to store activityName. */
        var enmMirrorActivity : String!   /*! @brief string declaration to store enmMirrorActivity getting from last screen. */
        
        var organizationId : String!    /*! @brief string declaration to store organizationId. */
        var activityId : String!        /*! @brief string declaration to store activityId. */
        var countryId : String!         /*! @brief string declaration to store countryId. */
        var stateId : String!           /*! @brief string declaration to store stateId. */
        var openMeasure : String!       /*! @brief string declaration to store openMeasure. */
        var trailSearchItem = NSMutableArray()   /*! @brief mutable array declaration for trailDetailArray. */

        var favoriteTrailTag: Int!          /*! @brief Int declaration to store Tag of fav trail. */
        var favoriteTrailSender: UIButton!   /*! @brief UIButton type declaration. */
        var trailDefaultShowListArray = NSMutableArray()   /*! @brief mutable array declaration for trailDefaultShowListArray. */
        var responseDict = NSDictionary()            /*! @brief Dcitionary declaration to store dictionary getting from api response. */
        var trailDetailVC = TrailDetailShowVC()         /*! @brief TrailDetailShowVC class declaration. */
        var boolForPresentingView : Bool! = false       /*! @brief Bool type declaration. */
        var boolForMenuView : Bool! = false             /*! @brief Bool type declaration. */
        var boolForMAapAndListBool : Bool! = false      /*! @brief Bool type declaration. */
        var countForDowloading : Int = 0                /*! @brief property declaration to get count of downloaded file. */
        var flagForServerFile : Bool! = false           /*! @brief Bool type declaration. */
        var flagForServerFileIfNotDownloaded : Bool!    /*! @brief Bool type declaration. */
        
        var adsview = AdsView()                         /*! @brief AdsView class declaration. */
        var imageArray = NSMutableArray()               /*! @brief mutable array declaration for imageArray. */
        var timer : Timer = Timer()
        var savedIndexOfImage : Int!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
           /*! @brief  Remove all filter Values from defaultCenter */
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "SavedTrailShowOptionArray")
            defaults.removeObject(forKey: "addedTrailStatusListArray")
            defaults.removeObject(forKey: "addedTrailDifficultyListArray")
            defaults.removeObject(forKey: "addedTrailStatusListArrayTemp")
            defaults.removeObject(forKey: "addedTrailDifficultyListArrayTemp")
            
            /*! @brief Add Observer for local notification with "UpdateBadgeNotification" name */
            NotificationCenter.default.addObserver(self, selector: #selector(TrailDetailScreenVC.updateBadges(_:)), name: NSNotification.Name(rawValue: "UpdateBadgeNotification"), object: nil)
            
            /*! @brief get usertype from UserDefaults and show/Hide buttons accordingly */
            if Singleton.sharedInstance.userInfo.userType == "O"
            {
                infoHeaderBtn.isHidden = true
                trailHeaderBtn.isHidden = true
                msgHeaderBtn.isHidden = true
            }
            else
            {
                infoHeaderBtn.isHidden = false
                trailHeaderBtn.isHidden = false
                msgHeaderBtn.isHidden = false
            }
            
            
            favoriteTrailTag = 0
            favoriteTrailSender = nil
            
            /*! @brief set animation speed of movable label */
            labelMovableInfo.tag = 101
            //labelMovableInfo.type = .continuous
            labelMovableInfo.speed = .duration(27)
            //labelMovableInfo.animationCurve = .easeInOut
            labelMovableInfo.fadeLength = 10.0
            labelMovableInfo.leadingBuffer = 2.0
            labelMovableInfo.trailingBuffer = 25.0
            
            
             /*! @brief Call Methods to add tableView and MapView and call api to get listing of trailDetail */
            boolForMAapAndListBool = false
            self.createMap()
            self.createTableView()
            self.trailDetailSearchApi()
            
            /*! @brief Save default show settings for Trail Detail Screen !*/
            trailDefaultShowListArray = ["Navigation: Show All", "Services: Show All", "Navigation: Parking", "Navigation: Trailheads", "Navigation: Intersections", "Navigation: Difficulty", "Navigation: Features", "Navigation: Scenic", "Navigation: Direction", "Services: Accommodations", "Services: Breweries", "Services: Restaurants", "Services: Bar-Pubs", "Services: Fuel-Gas", "Services: Service-Repairs"]
            //Save array to user defaults
            defaults.set(trailDefaultShowListArray, forKey: "SavedTrailShowOptionArray")
            defaults.synchronize()
            
            
            
        }
        /*! @brief This method calls automatically when user get "UpdateBadgeNotification" name type local notification. 
            @ discussion - Call AddBadges and updatePathColorWhenPushNotification methods
         */
        func updateBadges(_ notification : Notification){
            self.AddBadges()
            self.updatePathColorWhenPushNotification()
            
        }
       
        /*! @brief This method calls automatically when View loads.
         @ discussion - show static Aid images and rotating them after 7 seonds.
         */

        func ShowAdvertismentView()  {
            
            self.view.addSubview(adsview)
            adsview.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height+100, width: UIScreen.main.bounds.size.width, height: 70);
            
            UIView.animate(withDuration: 2.0, animations: {
                self.adsview.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 70, width: UIScreen.main.bounds.size.width, height: 70)
            })
            
            imageArray = NSMutableArray()
            // Add images and linkURL into Array
            let d0 = ["image": "Bliz_Ad.png", "linkUrl": "http://www.blizeyewear.com/", "aidTitle": "Generous Support from:"]
            let d1 = ["image": "trailad-1.png", "linkUrl": "", "aidTitle": "Generous Support from:"]
            let d2 = ["image": "trailad-2.png", "linkUrl": "", "aidTitle": "TrailHUB TIP!"]
            let d3 = ["image": "trailad-3.png", "linkUrl": "", "aidTitle": "TrailHUB TIP!"]
            imageArray.insert(d0, at: imageArray.count)
            imageArray.insert(d1, at: imageArray.count)
            imageArray.insert(d2, at: imageArray.count)
            imageArray.insert(d3, at: imageArray.count)
            
            
            timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(OrgSeachResultVC.ChangeImage), userInfo: nil, repeats: true)
        }
        
        /*! @brief This method calls automatically when View loads.
         @ return - return savedIndexOfImage from UserDefaults and show next image from rotating image.
         */
        func returnIndex () -> Int
        {
            let ImageIndex : Int!
            let userdefaults = UserDefaults.standard
            if userdefaults.object(forKey: "TrailAdvertisementIndex") != nil
            {
                let savedIndex : Int = userdefaults.object(forKey: "TrailAdvertisementIndex") as! Int
                if savedIndex > imageArray.count-1
                {
                    ImageIndex = 0
                }
                else
                {
                    ImageIndex = savedIndex
                    
                }
                
                
            }
            else
            {
                ImageIndex = 0
                
            }
            
            return ImageIndex
            
        }
        
        /*! @brief This method calls automatically when View loads.
         @ discussion - call chageImageAsPerIndex with index.
         */
        func ChangeImage()
        {
            // Add Aidvertisement
            savedIndexOfImage = returnIndex()
            self.chageImageAsPerIndex(indexInt: savedIndexOfImage)
            
        }
       
        /*! @brief This method calls automatically when View loads.
         @ discussion - change image of rotating ads according to saved Index.
         */
        func chageImageAsPerIndex(indexInt : Int)
        {
            savedIndexOfImage = indexInt
            
            // Get a random item
            let randomItem = imageArray[savedIndexOfImage] as! NSDictionary
            adsview.addsImgView.image = UIImage(named: randomItem.object(forKey: "image") as! String)
            adsview.URlStr = randomItem.object(forKey: "linkUrl") as! String
            adsview.addsTextLabel.text = randomItem.object(forKey: "aidTitle") as? String
            
            if savedIndexOfImage >= imageArray.count-1
            {
                savedIndexOfImage = 0
            }
            else
            {
                savedIndexOfImage = savedIndexOfImage + 1
            }
            
            let userdefaults = UserDefaults.standard
            userdefaults.set(savedIndexOfImage, forKey: "TrailAdvertisementIndex")
            userdefaults.synchronize()
            
        }
        /*! @brief This method calls automatically when View loads.
         @ discussion - change Timer for one minute for Aid.
         */
        func updateAdvertisementForOneMinute(_ notification : Notification)
        {
            
            timer.invalidate()
            _ = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(TrailDetailScreenVC.ShowAdvertismentView), userInfo: nil, repeats: false)
        }
        /*! @brief This method calls automatically when View loads.
         @ discussion - change Timer for 15 minute for Aid.
         */
        func updateAdvertisement(_ notification : Notification)
        {
            
            timer.invalidate()
            _ = Timer.scheduledTimer(timeInterval: 900.0, target: self, selector: #selector(TrailDetailScreenVC.ShowAdvertismentView), userInfo: nil, repeats: false)
        }
        
        /*! @brief This method calls automatically when user get "UpdateBadgeNotification" name type local notification.
         @ discussion - get trailID getting from pushnotification time and get usertype and polylinepath corresponding to that ID and change its stroke color
         */
        func updatePathColorWhenPushNotification()
        {
            // add content to cell
            let defaults = UserDefaults.standard
            let showArray = defaults.object(forKey: "trailIDAndStatusArray")
            if showArray != nil
            {
                let trailIDAndStatusArray = defaults.object(forKey: "trailIDAndStatusArray") as! NSMutableArray
                
                for i in stride(from: 0, to: trailIDAndStatusArray.count-1, by: 1){
                    
                    let trailID = (trailIDAndStatusArray.object(at: i) as AnyObject).object(forKey: "trailID") as! String
                    let trailStatus = (trailIDAndStatusArray.object(at: i) as AnyObject).object(forKey: "trailStatus") as! String
                    
                    for j in stride(from: 0, to: self.trailSearchItem.count-1, by: 1){
                     
                        
                        let trailSearchDict:TrailSearchRecord =  self.trailSearchItem.object(at: j) as! TrailSearchRecord
                        if trailSearchDict.trailId == trailID
                        {
                            if trailSearchDict.fileUrl != ""
                            {
                                
                                self.polylineWithPath = pathArray.object(at: j) as! GMSPolyline
                                if (trailStatus == "O")
                                {
                                    
                                    self.polylineWithPath.strokeColor = UIColor(red: 65.0/255, green: 132.0/255, blue: 65.0/255, alpha: 1.0)
                                }
                                if (trailStatus == "CA")
                                {
                                    
                                    self.polylineWithPath.strokeColor = UIColor(red: 242/255, green: 154/255, blue: 51/255, alpha: 1.0)
                                }
                                if (trailStatus == "C")
                                {
                                    
                                    self.polylineWithPath.strokeColor = UIColor(red: 233/255, green: 63/255, blue: 52/255, alpha: 1.0)
                                }
                            }
                        }
                    }
                }
                
                UserDefaults.standard.removeObject(forKey: "trailIDAndStatusArray")
                
            }
            
            
        }
        
        /*! @brief This method calls when pullToRefresh a list.
         @ discussion - Call TrailDetail Api to get all updated trailList.
         */
        func refresh(_ sender:AnyObject)
        {
            // check addShowOptionArray is nil
            let defaults = UserDefaults.standard
            let showArray = defaults.object(forKey: "SavedTrailShowOptionArray")
            let statusArray = defaults.object(forKey: "addedTrailStatusListArray")
            let difficultyArray = defaults.object(forKey: "addedTrailDifficultyListArray")
            
            if showArray != nil || statusArray != nil || difficultyArray != nil
            {
                refreshControl.endRefreshing()
            }
            else
            {
                self.trailDetailSearchApi()
            }
            
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            
            
            /*! @brief Add Screen Tracking.*/
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.set(kGAIDescription, value: "Trail Details Screen")
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker?.send(builder as! [NSObject : AnyObject])
            
            /*! @brief Call checkMapAndListButtonStatus.*/
            self.checkMapAndListButtonStatus()
            
           /*! @brief Add advertisement again after 15 minutes if user closes Adv.*/
            savedIndexOfImage = returnIndex()
            self.ShowAdvertismentView()
            NotificationCenter.default.addObserver(self, selector: #selector(TrailDetailScreenVC.updateAdvertisement(_:)), name: NSNotification.Name(rawValue: "UpdateAdvertisementNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(TrailDetailScreenVC.updateAdvertisementForOneMinute(_:)), name: NSNotification.Name(rawValue: "UpdateAdvertisementNotificationOfOneMinute"), object: nil)
            
            
        }
     
        /*! @brief This method called to determine that we have to show map or tableview
         @discussion If "boolForMAapAndListBool" is true then show tableview and update header and tableview Data othrewise show map with pins and routePath.
         */

        func checkMapAndListButtonStatus ()
        {
            if  boolForMAapAndListBool == true
            {
                mapView.isHidden = true
                tableViewTrailDetail.isHidden = false
                
                if responseDict.count>0
                {
                    self.updateHeader(responseDict)
                    self.updateScreenData(responseDict)
                }
                
            }
            else
            {
                
                tableViewTrailDetail.isHidden = true
                mapView.isHidden = false
                if responseDict.count>0
                {
                    self.updateHeader(responseDict)
                    self.addPath(responseDict)
                }
                
                
            }
            
        }
        /*! @brief Method to create dynamic tableView */
        func createTableView()
        {
            let screenSize: CGRect = UIScreen.main.bounds
            let tableRect : CGRect = CGRect(x: 0, y: 163.0, width: screenSize.width, height: screenSize.height-163.0)
            tableViewTrailDetail = UITableView(frame: tableRect, style: UITableViewStyle.plain)
            tableViewTrailDetail.delegate      =   self
            tableViewTrailDetail.dataSource    =   self
            tableViewTrailDetail.separatorStyle = UITableViewCellSeparatorStyle.none
            self.view.addSubview(tableViewTrailDetail)
            
            
            tableViewTrailDetail.register(UINib(nibName: "TrailDetailTVCell", bundle: nil), forCellReuseIdentifier: "TrailDetailTVCell")
            if (tableViewTrailDetail.contentSize.height < tableViewTrailDetail.frame.size.height) {
                tableViewTrailDetail.alwaysBounceVertical = false
            }
            else {
                tableViewTrailDetail.alwaysBounceVertical = true
            }
            
            
            refreshControl = UIRefreshControl()
            refreshControl.attributedTitle = NSAttributedString(string: "")
            refreshControl.addTarget(self, action: #selector(TrailDetailScreenVC.refresh(_:)), for: UIControlEvents.valueChanged)
            tableViewTrailDetail.addSubview(refreshControl) // not required when using UITableViewControlle
            
            tableViewTrailDetail.isHidden = true
            
        }
        /*! @brief Method to create dynamic MapView(googleMap) */
        func createMap()
        {
            
            let screenSize: CGRect = UIScreen.main.bounds
            
            let mapRect : CGRect = CGRect(x: 0, y: 163.0, width: screenSize.width, height: screenSize.height-163.0)
            
            
            let camera = GMSCameraPosition.camera(withLatitude: Singleton.sharedInstance.currentLocLat,longitude:Singleton.sharedInstance.currentLocLong, zoom:7.0, bearing:0, viewingAngle:0)
            mapView = GMSMapView.map(withFrame: mapRect, camera:camera)
            self.view.addSubview(mapView)
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
            mapView.mapType = kGMSTypeTerrain
            mapView.settings.myLocationButton = true
            mapView.settings.scrollGestures = true
            mapView.settings.zoomGestures = true
            mapView.settings.compassButton = true
            mapView.padding = UIEdgeInsetsMake (0,0,0,0);
            mapView.isHidden = true
        }
       
        /*! @brief This method called To Show Path.
         @discussion Get filters from UserDefaults and filter data accordingly to show on MapView .
         */
        func addPath(_ myDictionary:NSDictionary)
        {
            flagForServerFileIfNotDownloaded = false
            let defaults = UserDefaults.standard
            defaults.set("fileDownload", forKey: "fileDownload")
            
            Belief_ProgressHud.shareInstance()
            Belief_ProgressHud.show()
            // clear markers from GMSMapView
            
            mapView.clear()
            
            self.trailSearchItem = NSMutableArray()
            if myDictionary["records"] != nil
            {
                let dataDic:SearchResult = SearchResult.getTrailSearchDetailFromData(myDictionary)
                trailSearchItem = dataDic.arraySearchTrailRecords
                
                
                // check addShowOptionArray is nil
                
                let showArray = defaults.object(forKey: "SavedTrailShowOptionArray")
                
                let myStr = "2764"
                let str = String(Character(UnicodeScalar(Int(myStr, radix: 16)!)!))
                let favoriteStr = "Favorites " + str
                
                if (showArray != nil)
                {
                    if (showArray as! NSArray).contains(favoriteStr)
                    {
                        let favoriteItems = NSMutableArray()
                        for i in 0..<self.trailSearchItem.count {
                            let trailSearchDict:TrailSearchRecord =  self.trailSearchItem.object(at: i) as! TrailSearchRecord
                            if trailSearchDict.isFavourite == "1"
                            {
                                favoriteItems.add(trailSearchDict)
                            }
                        }
                        self.trailSearchItem = self.StatusFilterMethod(favoriteItems)
                        
                    }
                    else
                    {
                        self.trailSearchItem = self.StatusFilterMethod(self.trailSearchItem)
                    }
                    
                }
                else
                {
                    self.trailSearchItem = self.StatusFilterMethod(self.trailSearchItem)
                }
                
                if self.trailSearchItem.count>0
                {
                    /*!
                     @discussion Call Method to showpath on map with filter array.
                     */
                    self.showPathOnMap(self.trailSearchItem)
                    
                }
                else
                {
                    /*!
                     @discussion if no filter data found, show all list getting from server.
                     */

                    Belief_ProgressHud.remove()
                    
                    let alertController = UIAlertController(title: "Alert", message: "No Results for filter, filters applied will be reset.", preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        
                        
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey: "SavedTrailShowOptionArray")
                        defaults.removeObject(forKey: "addedTrailStatusListArray")
                        defaults.removeObject(forKey: "addedTrailDifficultyListArray")
                        defaults.removeObject(forKey: "addedTrailStatusListArrayTemp")
                        defaults.removeObject(forKey: "addedTrailDifficultyListArrayTemp")
                        defaults.synchronize()
                        
                        
                        
                        // Save default show settings for Trail Detail Screen
                        self.trailDefaultShowListArray = ["Navigation: Show All", "Services: Show All", "Navigation: Parking", "Navigation: Trailheads", "Navigation: Intersections", "Navigation: Difficulty", "Navigation: Features", "Navigation: Scenic", "Navigation: Direction", "Services: Accommodations", "Services: Breweries", "Services: Restaurants", "Services: Bar-Pubs", "Services: Fuel-Gas", "Services: Service-Repairs"]
                        //Save array to user defaults
                        defaults.set(self.trailDefaultShowListArray, forKey: "SavedTrailShowOptionArray")
                        
                        
                        
                        // reload fresh data
                        self.trailSearchItem = dataDic.arraySearchTrailRecords
                        self.showPathOnMap(self.trailSearchItem)
                        
                        
                        
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
            else
            {
                Belief_ProgressHud.remove()
                
                let alert = UIAlertView()
                alert.title = ""
                alert.message = "Organization setup still in progress. Trails not added yet, check back soon."
                alert.addButton(withTitle: "Ok")
                alert.show()
            }
            
        }
        
        /*! @brief - Method called to show pins on mapView
         @discussion get status from filteredArray one by one and add icon on mapview with different -2 image.
         */
        func addOrgPinAndTrailPinsOnMap(_ filteredArray: NSMutableArray)
        {
            
            
            // Adding Trail Pins
            
            for i in 0..<filteredArray.count {
                
                
                let trailSearchDict:TrailSearchRecord = filteredArray.object(at: i) as! TrailSearchRecord
                let latitude : Double = (trailSearchDict.trailLattitude as NSString).doubleValue
                let longitude : Double = (trailSearchDict.trailLongitude as NSString).doubleValue
                
                let  position = CLLocationCoordinate2DMake(latitude, longitude)
                let trailmarker = GMSMarker(position: position)
                if (trailSearchDict.trailStatus == "O")
                {
                    trailmarker?.icon = UIImage(named: "open-pin")
                }
                if (trailSearchDict.trailStatus == "CA")
                {
                    trailmarker?.icon = UIImage(named: "caution-pin")
                    
                }
                if (trailSearchDict.trailStatus == "C")
                {
                    trailmarker?.icon = UIImage(named: "closed-pin")
                    
                }
                trailmarker?.accessibilityLabel = "\(i)"
                trailmarker?.map = mapView
            }
            
            
            
            // check addShowOptionArray is nil - show small pins
            let defaults = UserDefaults.standard
            let showArray = defaults.object(forKey: "SavedTrailShowOptionArray")
            
            if (showArray != nil)
            {
                if((showArray as! NSArray).count>0)
                {
                    let dataDic:SearchResult = SearchResult.pinsFromData(responseDict)
                    self.getPinsOnMap(dataDic.pinsArray)
                    
                    
                }
            }
            
            //Adding org pins
            let dataDic:SearchResult = SearchResult.getTrailSearchRecordFromData(responseDict)
            let latitude : Double = (dataDic.latitude as NSString).doubleValue
            let longitude : Double = (dataDic.longitude as NSString).doubleValue
            
            let  position = CLLocationCoordinate2DMake(latitude, longitude)
            let marker = GMSMarker(position: position)
            if (dataDic.organizationStatus == "O")
            {
                marker?.icon = UIImage(named: "open-pin")
            }
            if (dataDic.organizationStatus == "CA")
            {
                marker?.icon = UIImage(named: "caution-pin")
                
            }
            if (dataDic.organizationStatus == "C")
            {
                marker?.icon = UIImage(named: "closed-pin")
                
            }
            marker?.accessibilityLabel = "\(1000)"
            marker?.map = mapView
            
            
            // Zoom camera animation
            var bounds : GMSCoordinateBounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(position)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds))
            mapView.animate(toZoom: 12)
            
            
        }
        
        
        /*! @brief - Method called to show small pins on mapView
         @discussion get status from filteredArray one by one and add small icon on mapview with different -2 image.
         */
        func getPinsOnMap(_ pinsArrayFromServer: NSMutableArray)
        {
            
            // check addShowOptionArray is nil
            let defaults = UserDefaults.standard
            let showArray = defaults.object(forKey: "SavedTrailShowOptionArray")
            
            if (showArray != nil)
            {
                if((showArray as! NSArray).count>0)
                {
                    for j in 0..<pinsArrayFromServer.count {
                        
                        let pinsDict:PinsData = pinsArrayFromServer.object(at: j) as! PinsData
                        let pinTypeFromServer = returnPinTypeUsingPinTypeID(pinsDict.pinType)
                        if (showArray as! NSArray).contains(pinTypeFromServer)
                        {
                            let latitude : Double = (pinsDict.lat as NSString).doubleValue
                            let longitude : Double = (pinsDict.lon as NSString).doubleValue
                            
                            let  position = CLLocationCoordinate2DMake(latitude, longitude)
                            let pinmarker = GMSMarker(position: position)
                            pinmarker?.icon = getPinImageUsingPinTypeID(pinsDict.pinType, image: pinsDict.img)
                            pinmarker?.accessibilityLabel = "\(j+10000)"
                            pinmarker?.userData = pinsDict
                            pinmarker?.map = mapView
                            
                        }
                        trailDefaultShowListArray = ["Navigation: Show All", "Services: Show All", "Navigation: Parking", "Navigation: Trailheads", "Navigation: Intersections", "Navigation: Difficulty", "Navigation: Features", "Navigation: Scenic", "Navigation: Direction", "Services: Accommodations", "Services: Breweries", "Services: Restaurants", "Services: Bar-Pubs", "Services: Fuel-Gas", "Services: Service-Repairs"]
                        if trailDefaultShowListArray == NSMutableArray.init(array: showArray as! NSArray)
                        {
                            if pinsDict.pinType == "15"
                            {
                                let latitude : Double = (pinsDict.lat as NSString).doubleValue
                                let longitude : Double = (pinsDict.lon as NSString).doubleValue
                                
                                let  position = CLLocationCoordinate2DMake(latitude, longitude)
                                let pinmarker = GMSMarker(position: position)
                                pinmarker?.icon = getPinImageUsingPinTypeID(pinsDict.pinType, image: pinsDict.img)
                                pinmarker?.accessibilityLabel = "\(j+10000)"
                                pinmarker?.userData = pinsDict
                                pinmarker?.map = mapView
                                
                            }
                            
                        }
                        
                    }
                }
                
            }
            Belief_ProgressHud.remove()
            
        }
       
        /*! @brief - Method called to show show path on mapView
         @discussion get polyline and render  all polyline once on mapview.
         */
        func showPathOnMap(_ filteredArray: NSMutableArray)
        {
            do
            {
            if countForDowloading < filteredArray.count
            {
                /*! @brief -  Begin kml or kmz file parsing with fileurl */
                let trailSearchDict:TrailSearchRecord = filteredArray.object(at: countForDowloading) as! TrailSearchRecord
                beginParsing(trailSearchDict.fileUrl, filteredArray: filteredArray, trailStatusString: trailSearchDict.trailStatus, kmlModifiedTime: trailSearchDict.kmlModifiedDateTime)
                
                
            }
            else
            {
                if flagForServerFile == false
                {
                    Belief_ProgressHud.remove()
                    
                    let refreshAlert = UIAlertController(title: "Alert", message: "Trail Maps not found, defaulting to List view.", preferredStyle: UIAlertControllerStyle.alert)
                    present(refreshAlert, animated: true, completion: nil)
                    
                    
                    // Delay the dismissal by 5 seconds
                    let delay = 2.0 * Double(NSEC_PER_SEC)
                    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time, execute: {
                        
                        refreshAlert.dismiss(animated: true, completion: nil)
                        self.boolForMAapAndListBool = true
                        self.mapView.isHidden = true
                        self.tableViewTrailDetail.isHidden = false
                        if self.responseDict.count>0
                        {
                            self.updateHeader(self.responseDict)
                            self.updateScreenData(self.responseDict)
                        }
                        self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn"), for: UIControlState())
                        self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn-sel"), for: .highlighted)
                        self.mapAndListBtn.setBackgroundImage(UIImage(named: "list-menu-unselected"), for: .selected)
                    })
                    
                }
                else
                {
                    
                    Belief_ProgressHud.remove()
                    
                    flagForServerFileIfNotDownloaded = false
                    let defaults = UserDefaults.standard
                    defaults.set("fileDownload", forKey: "fileDownload")
                    
                    self.polylineWithPath.map.isHidden = false
                    
                    countForDowloading = 0
                    self.addOrgPinAndTrailPinsOnMap(self.trailSearchItem)
                }
            }
            }
            catch {
                Belief_ProgressHud.remove()
                let refreshAlert = UIAlertController(title: "TrailHUB", message: "Invalid GPS Tracking Format detected, defaulting to List View.", preferredStyle: UIAlertControllerStyle.alert)
                present(refreshAlert, animated: true, completion: nil)
                
                
                // Delay the dismissal by 5 seconds
                let delay = 2.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    
                    refreshAlert.dismiss(animated: true, completion: nil)
                    if (self.directionsButton != nil) && (self.googleMapsButton != nil)
                    {
                        self.directionsButton.removeFromSuperview()
                        self.googleMapsButton.removeFromSuperview()
                    }
                    self.boolForMAapAndListBool = true
                    self.mapView.isHidden = true
                    self.tableViewTrailDetail.isHidden = false
                    if self.responseDict.count>0
                    {
                        self.updateHeader(self.responseDict)
                        self.updateScreenData(self.responseDict)
                    }
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn"), for: UIControlState())
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn-sel"), for: .highlighted)
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "list-menu-unselected"), for: .selected)
                    
                    
                })

            }
            

        }
        /*! @brief - Method called to update navigation header content
         @discussion set all label values of header getting from server response from api.
         */
        func updateHeader(_ myDictionary:NSDictionary)
        {
            let dataDic : SearchResult = SearchResult.getTrailSearchRecordFromData(myDictionary)
            activityNameTrailSearchLabel.text = dataDic.organizationName.uppercased()
            totalTrailSearchLabel.text = "(" + dataDic.totalRecords + ")"
            totalOpenTrailSearchLabel.text = "(" + dataDic.openTotalTrailLenght + ")"
            stateCountryTrailSearchLabel.text = (dataDic.stateName + "," + dataDic.countryName).uppercased()
            openMeasure = dataDic.openMeasure
           
            if openMeasure == "Mi"
            {
                 openMilesLabel.text = "OPEN MILES"
            }
            else
            {
                openMilesLabel.text = "OPEN " + openMeasure
            }
            
            // Add text to marqueeLabel
            let orgInfo = dataDic.organizationInfo
            if orgInfo == ""
            {
                labelMovableInfo.text = "NO INFORMATION ALERTS FOUND FOR THIS ORGANIZATION."
            }
            else
            {
                let aux = "<span style=\"font-family: Calibri; color: #00608D; font-size: 14.0\">\(orgInfo.uppercased())</span>"
                let attrString3 = aux.html2AttributedString
                labelMovableInfo.attributedText = attrString3
                
            }
            // Add Target To Org url
            if dataDic.strAlertUrl == ""
            {
                
            }
            else
            {
                orgInfoBtn.addTarget(self, action: #selector(TrailDetailScreenVC.openURL(_:)), for:.touchUpInside)
            }
            
            // Add badges to all three buttons
            self.AddBadges()
            
        }
        /*! @brief - Method called to Add Badges on MIBadgeButton
         @discussion get count saved in UserDefaults and show on MIBadgeButton.
         */
        func AddBadges()
        {
            let defaults = UserDefaults.standard
            let unReadInviteAlert = defaults.object(forKey: "unReadInviteAlert")
            let unReadInfoAlert = defaults.object(forKey: "unReadInfoAlert")
            let unReadTrailAlert = defaults.object(forKey: "unReadTrailAlert")
            
            
            if unReadInviteAlert != nil
            {
                if unReadInviteAlert as? String == "0"
                {
                     addBadgeToButton(msgHeaderBtn, value: "")
                }
                else
                {
                    let num:Int? = Int((unReadInviteAlert as? String)!);
                    let t:Int? = num! / 10
                    if(t == 0){
                        addBadgeToButton(msgHeaderBtn, value: (unReadInviteAlert as? String)!)
                    }else{
                        let msg = "\(t!)0+"
                        addBadgeToButton(msgHeaderBtn, value: msg)
                    }
                    
                }
                
            }
            else
            {
                clearBadgeOfButton(msgHeaderBtn)
                
            }
            
            if unReadInfoAlert != nil
            {
                if unReadInfoAlert as? String == "0"
                {
                     addBadgeToButton(infoHeaderBtn, value: "")
                }
                else
                {
                    let num:Int? = Int((unReadInfoAlert as? String)!);
                    let t:Int? = num! / 10
                    if(t == 0){
                        addBadgeToButton(infoHeaderBtn, value: (unReadInfoAlert as? String)!)
                    }else{
                        let msg = "\(t!)0+"
                        addBadgeToButton(infoHeaderBtn, value: msg)
                    }
                    
                    
                }
            }
            else
            {
                clearBadgeOfButton(infoHeaderBtn)
            }
            if unReadTrailAlert != nil
            {
                if unReadTrailAlert as? String == "0"
                {
                    addBadgeToButton(trailHeaderBtn, value: "")
                }
                else
                {
                    
                    let num:Int? = Int((unReadTrailAlert as? String)!);
                    let t:Int? = num! / 10
                    if(t == 0){
                        addBadgeToButton(trailHeaderBtn, value: (unReadTrailAlert as? String)!)
                    }else{
                        let msg = "\(t!)0+"
                        addBadgeToButton(trailHeaderBtn, value: msg)
                    }
                    
                    
                    
                }
            }
            else
            {
                clearBadgeOfButton(trailHeaderBtn)
                
            }
            
            self.view.layoutSubviews()
        }
        
        /*! @brief - Method called to update data on tableView
         @discussion get filtered values saved in UserDefaults and filter server response accordingly and reload tableView data.
         */

        func updateScreenData(_ myDictionary:NSDictionary)
        {
            
            self.trailSearchItem = NSMutableArray()
            if myDictionary["records"] != nil
            {
                let dataDic:SearchResult = SearchResult.getTrailSearchDetailFromData(myDictionary)
                trailSearchItem = dataDic.arraySearchTrailRecords
                
                
                // check addShowOptionArray is nil
                let defaults = UserDefaults.standard
                let showArray = defaults.object(forKey: "SavedTrailShowOptionArray")
                
                let myStr = "2764"
                let str = String(Character(UnicodeScalar(Int(myStr, radix: 16)!)!))
                let favoriteStr = "Favorites " + str
                
                if (showArray != nil)
                {
                    if (showArray as! NSArray).contains(favoriteStr)
                    {
                        let favoriteItems = NSMutableArray()
                        for i in 0..<self.trailSearchItem.count {
                            let trailSearchDict:TrailSearchRecord =  self.trailSearchItem.object(at: i) as! TrailSearchRecord
                            if trailSearchDict.isFavourite == "1"
                            {
                                favoriteItems.add(trailSearchDict)
                            }
                        }
                        self.trailSearchItem = self.StatusFilterMethod(favoriteItems)
                        
                    }
                    else
                    {
                        self.trailSearchItem = self.StatusFilterMethod(self.trailSearchItem)
                    }
                    
                }
                else
                {
                    self.trailSearchItem = self.StatusFilterMethod(self.trailSearchItem)
                }
                
                if self.trailSearchItem.count>0
                {
                    refreshControl.endRefreshing()
                    self.tableViewTrailDetail.reloadData()
                }
                else
                {
                    let alertController = UIAlertController(title: "Alert", message: "No Results for filter, filters applied will be reset.", preferredStyle: .alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        
                        
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey: "SavedTrailShowOptionArray")
                        defaults.removeObject(forKey: "addedTrailStatusListArray")
                        defaults.removeObject(forKey: "addedTrailDifficultyListArray")
                        defaults.removeObject(forKey: "addedTrailStatusListArrayTemp")
                        defaults.removeObject(forKey: "addedTrailDifficultyListArrayTemp")
                        defaults.synchronize()
                        
                        
                        // Save default show settings for Trail Detail Screen
                        self.trailDefaultShowListArray = ["Navigation: Show All", "Services: Show All", "Navigation: Parking", "Navigation: Trailheads", "Navigation: Intersections", "Navigation: Difficulty", "Navigation: Features", "Navigation: Scenic", "Navigation: Direction", "Services: Accommodations", "Services: Breweries", "Services: Restaurants", "Services: Bar-Pubs", "Services: Fuel-Gas", "Services: Service-Repairs"]
                        //Save array to user defaults
                        defaults.set(self.trailDefaultShowListArray, forKey: "SavedTrailShowOptionArray")
                        
                        // reload fresh data
                        self.trailSearchItem = dataDic.arraySearchTrailRecords
                        self.refreshControl.endRefreshing()
                        self.tableViewTrailDetail.reloadData()
                        
                        
                        
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                
                
            }
            else
            {
                let alert = UIAlertView()
                alert.title = ""
                alert.message = "Organization setup still in progress. Trails not added yet, check back soon."
                alert.addButton(withTitle: "Ok")
                alert.show()
            }
        }
       
        /*! @brief - Method called to filter status ie open closed and caution
            @return filtered array according to status
         */
        func StatusFilterMethod (_ inputArray : NSMutableArray) -> NSMutableArray
        {
            
            var finalfilteredArray = NSMutableArray()
            let filteredStatusArray = NSMutableArray()
            
            // Get Saved data to userdefaults
            let defaults = UserDefaults.standard
            let statusArray = defaults.object(forKey: "addedTrailStatusListArray")
            
            if (statusArray != nil)
            {
                if (statusArray as! NSArray).count>0
                {
                    for i in 0..<inputArray.count {
                        
                        let trailSearchDict:TrailSearchRecord =  self.trailSearchItem.object(at: i) as! TrailSearchRecord
                        
                        for index in 0..<(statusArray as! NSArray).count {
                            
                            let statusString = (statusArray as! NSArray).object(at: index) as! String
                            if statusString == organistaionStatus(trailSearchDict.trailStatus)
                            {
                                filteredStatusArray.add(trailSearchDict)
                            }
                            else
                            {
                                
                            }
                            
                        }
                    }
                    
                    // check filtered Status array contains object or not
                    if filteredStatusArray.count>0
                    {
                        finalfilteredArray = self.difficultyFilterMethod(filteredStatusArray)
                    }
                    else
                    {
                        
                    }
                }
                else
                {
                    finalfilteredArray = self.difficultyFilterMethod(inputArray)
                }
                
            }
            else
            {
                finalfilteredArray = self.difficultyFilterMethod(inputArray)
            }
            
            
            
            return finalfilteredArray
        }
        /*! @brief - Method called to filter difficulty ie Beginner, intermediate, Intersections etc
            @return filtered array according to difficulty
         */
        func difficultyFilterMethod (_ inputRegionArray : NSMutableArray) -> NSMutableArray
        {
            
            var filteredArray = NSMutableArray()
            
            // Get Saved data to userdefaults
            let defaults = UserDefaults.standard
            let difficultyArray = defaults.object(forKey: "addedTrailDifficultyListArray")
            
            
            if (difficultyArray != nil)
            {
                if (difficultyArray as! NSArray).count>0
                {
                    for i in 0..<inputRegionArray.count {
                        
                        let trailSearchDict:TrailSearchRecord =  self.trailSearchItem.object(at: i) as! TrailSearchRecord
                        for index in 0..<(difficultyArray as! NSArray).count {
                            
                            let difficultyString = (difficultyArray as! NSArray).object(at: index) as! String
                            if difficultyString == difficultyType(trailSearchDict.trailDifficultyId)
                            {
                                filteredArray.add(trailSearchDict)
                            }
                            else
                            {
                            }
                            
                        }
                        
                    }
                }
            }
            else
            {
                filteredArray = inputRegionArray
            }
            
            return filteredArray
        }
        
        /*! @brief - Method automatically called when view disappears.
            @discussion Remove all stored values in UserDefaults and remove observer for local NotificationCenter
         */
        
        override func viewWillDisappear(_ animated: Bool)
        {
            if boolForPresentingView == true
            {
                boolForPresentingView = false
            }
            else
            {
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "SavedTrailShowOptionArray")
                defaults.removeObject(forKey: "addedTrailStatusListArray")
                defaults.removeObject(forKey: "addedTrailDifficultyListArray")
                defaults.removeObject(forKey: "addedTrailStatusListArrayTemp")
                defaults.removeObject(forKey: "addedTrailDifficultyListArrayTemp")
                mapView.removeFromSuperview()
                if (directionsButton != nil) && (googleMapsButton != nil)
                {
                    directionsButton.removeFromSuperview()
                    googleMapsButton.removeFromSuperview()
                }
                
                if tableViewTrailDetail != nil
                {
                    tableViewTrailDetail.removeFromSuperview()
                }
                
                // Stop File Downloading
                let fileDownLoad = FileDownloadingAndXMLParsing()
                fileDownLoad.stopDownloading()
                
                
                // Remove aidView when view is disappearing.
                adsview.removeFromSuperview()
                timer.invalidate()
                NotificationCenter.default.removeObserver(self)
            }
            
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        /*! @brief - GMSMapViewDelegate methods.
         @discussion - when user tap on custom window with dynamic data getting from server response.
         */

        func mapView(_ mapView: GMSMapView!, didTapInfoWindowOf marker: GMSMarker!) {
            
            let index:Int! = Int(marker.accessibilityLabel!)
            
            if index>=10000
            {
                
                let pinsDict:PinsData = marker.userData as! PinsData
                if (pinsDict.pinType == "1") || (pinsDict.pinType == "5") || (pinsDict.pinType == "8") || (pinsDict.pinType == "12") || (pinsDict.pinType == "13") || (pinsDict.pinType == "14") || (pinsDict.pinType == "15")
                {
                    if pinsDict.website == ""
                    {
                        
                    }
                    else
                    {
                        UIApplication.shared.openURL(URL(string: pinsDict.website)!)
                    }
                }
                else
                {
                    
                }
            }
            else if (index == 1000)
            {
            }
            else
            {
                let trailSearchDict:TrailSearchRecord = self.trailSearchItem.object(at: index) as! TrailSearchRecord
                let aux = "<span style=\"font-family: Calibri; color: #000000; font-size: 13.0\">\(trailSearchDict.trailNote)</span>"
                let attrString3 = aux.html2AttributedString
                
                let text = attrString3!.string
                let types: NSTextCheckingResult.CheckingType = .link
                
                do {
                    let detector = try NSDataDetector(types: types.rawValue)
                    let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.characters.count))
                    if matches.count > 0 {
                        
                        let url = matches[0].url!
                        
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }}
                    else
                    {
                        
                    }
                }
                catch {
                    // none found or some other issue
                    print ("error in findAndOpenURL detector")
                }
                
                
            }
            mapView.selectedMarker = nil
            mapView.delegate = self
        }
        
        /*! @brief - GMSMapViewDelegate methods.
         @discussion - when user tap on pins added on map shows custom window with dynamic data getting from server response.
         */
        func mapView(_ mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
            // Get a reference for the custom overlay
            
            
            
            let screenSize = UIScreen.main.bounds.size
            
            directionsButton = MyButton()
            directionsButton.setTitle("", for: UIControlState())
            directionsButton.setImage(UIImage(named: "direction"), for: UIControlState())
            directionsButton.setTitleColor(UIColor.blue, for: UIControlState())
            directionsButton.frame = CGRect(x: screenSize.width/2+5, y: screenSize.height - 65, width: 60, height: 60)
            directionsButton.addTarget(self, action: #selector(TrailDetailScreenVC.markerClick(_:)), for: .touchUpInside)
            directionsButton.gps = String(marker.position.latitude) + "," + String(marker.position.longitude)
            directionsButton.title = marker.title
            directionsButton.tag = 1
            self.view.addSubview(directionsButton)
            
            googleMapsButton = MyButton()
            googleMapsButton.setTitle("", for: UIControlState())
            googleMapsButton.setImage(UIImage(named: "GoogleMaps"), for: UIControlState())
            googleMapsButton.setTitleColor(UIColor.blue, for: UIControlState())
            if screenSize.width>320
            {
                googleMapsButton.frame = CGRect(x: directionsButton.frame.origin.x+50, y: screenSize.height - 65, width: 60, height: 60)
            }
            else
                
            {
                googleMapsButton.frame = CGRect(x: directionsButton.frame.origin.x+43, y: screenSize.height - 65, width: 60, height: 60)
            }
            
            googleMapsButton.addTarget(self, action: #selector(TrailDetailScreenVC.markerClick(_:)), for: .touchUpInside)
            googleMapsButton.gps = String(marker.position.latitude) + "," + String(marker.position.longitude)
            googleMapsButton.title = marker.title
            googleMapsButton.tag = 0
            self.view.addSubview(googleMapsButton)
            
            self.view.bringSubview(toFront: adsview)
            
            
            let index:Int! = Int(marker.accessibilityLabel!)
            
            
            if index>=10000
            {
                
                let pinsDict:PinsData = marker.userData as! PinsData
                if (pinsDict.pinType == "1") || (pinsDict.pinType == "5") || (pinsDict.pinType == "8") || (pinsDict.pinType == "12") || (pinsDict.pinType == "13") || (pinsDict.pinType == "14")
                {
                    let customInfoWindow = Bundle.main.loadNibNamed("PinsViewCell", owner: self, options: nil)?[0] as! PinsViewCell
                    
                    
                    customInfoWindow.businessNameLbl.text = pinsDict.businessName
                    if pinsDict.description == ""
                    {
                        customInfoWindow.descriptionLbl.text = "NA"
                    }
                    else
                    {
                        customInfoWindow.descriptionLbl.text = pinsDict.descriptio
                    }
                    if pinsDict.website == ""
                    {
                        customInfoWindow.websiteLbl.text = "NA"
                    }
                    else
                    {
                        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
                        let underlineAttributedString = NSAttributedString(string: pinsDict.website, attributes: underlineAttribute)
                        customInfoWindow.websiteLbl.attributedText = underlineAttributedString
                        
                    }
                    if pinsDict.operation == ""
                    {
                        customInfoWindow.operationLbl.text = "NA"
                    }
                    else
                    {
                        customInfoWindow.operationLbl.text = pinsDict.operation
                    }
                    if pinsDict.address == ""
                    {
                        customInfoWindow.addressLbl.text = "NA"
                    }
                    else
                    {
                        customInfoWindow.addressLbl.text = pinsDict.address
                    }
                    if pinsDict.phone == ""
                    {
                        customInfoWindow.phoneLbl.text = "NA"
                    }
                    else
                    {
                        customInfoWindow.phoneLbl.text = pinsDict.phone
                    }
                    
                    if pinsDict.descriptio == ""
                    {
                        
                    }
                    else
                        
                    {
                        let screenSize = UIScreen.main.bounds.size
                        
                        let newSize = self.rectForText(pinsDict.descriptio, font: UIFont(name: "Calibri", size: 14.0)!, maxSize: CGSize(width: (screenSize.width - 40),height: 21))
                        let newSize1 = self.rectForText(pinsDict.website, font: UIFont(name: "Calibri", size: 14.0)!, maxSize: CGSize(width: (screenSize.width - 40),height: 21))
                        let newSize2 = self.rectForText(pinsDict.address, font: UIFont(name: "Calibri", size: 14.0)!, maxSize: CGSize(width: (screenSize.width - 40),height: 21))
                        let newSize3 = self.rectForText(pinsDict.operation, font: UIFont(name: "Calibri", size: 14.0)!, maxSize: CGSize(width: (screenSize.width - 40),height: 21))
                        
                        let array  = [newSize.width,newSize1.width, newSize2.width,newSize3.width]
                        let finalwidth =  array.max()
                        
                        customInfoWindow.frame.size.width = finalwidth!+50
                    }
                    
                    return customInfoWindow
                    
                }
                else
                {
                    if (pinsDict.pinType == "7")
                    {
                        adsview.removeFromSuperview()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateAdvertisementNotificationOfOneMinute"), object: nil)
                    }
                
                    let customInfoWindow = Bundle.main.loadNibNamed("PinsServicesViewCell", owner: self, options: nil)?[0] as! PinsServicesViewCell
                    customInfoWindow.businessNameLbl.text = pinsDict.businessName
                    if pinsDict.description == ""
                    {
                        customInfoWindow.descriptionLbl.text = "NA"
                    }
                    else
                    {
                        customInfoWindow.descriptionLbl.text = pinsDict.descriptio
                    }
                    
                    let screenSize = UIScreen.main.bounds.size
                    let newSize = self.rectForText(pinsDict.descriptio, font: UIFont(name: "Calibri", size: 14.0)!, maxSize: CGSize(width: (screenSize.width - 40),height: 22))
                    let newSize1 = self.rectForText(pinsDict.businessName, font: UIFont(name: "Calibri-Bold", size: 14.0)!, maxSize: CGSize(width: (screenSize.width - 40),height: 21))
                    
                    let array  = [newSize.width,newSize1.width]
                    let finalwidth =  array.max()

                    customInfoWindow.frame.size.width = finalwidth!+50
                    return customInfoWindow
                }
                
            }
            else if (index == 1000)
            {
                let dataDic:SearchResult = SearchResult.getTrailSearchRecordFromData(responseDict)
                
                let customInfoWindow = Bundle.main.loadNibNamed("OrgInfoCell", owner: self, options: nil)?[0] as! OrgInfoCell
                customInfoWindow.orgNameLabel.text = dataDic.organizationName
                
                let screenSize = UIScreen.main.bounds.size
                let newSize = self.rectForText(dataDic.organizationName, font: UIFont(name: "Calibri-Bold", size: 15.0)!, maxSize: CGSize(width: (screenSize.width - 40),height: 22))
                
                customInfoWindow.frame.size.width = newSize.width+20
                
                return customInfoWindow
            }
            else
            {
                
                
                // add content to cell
                let trailSearchDict:TrailSearchRecord = self.trailSearchItem.object(at: index) as! TrailSearchRecord
                
                let customInfoWindow = Bundle.main.loadNibNamed("TrailDetailCell", owner: self, options: nil)?[0] as! TrailDetailCell
                
                
                //Set organisation favorite/unfavorite image and action
                if Singleton.sharedInstance.userInfo.userType == "O"
                {
                    customInfoWindow.favButton.isHidden = true
                    customInfoWindow.trailDescLabelxPosition.constant = -2
                    customInfoWindow.dateLabelxPosition.constant = 8
                    customInfoWindow.trailNameLabelxPosition.constant = 5
                    
                }
                else
                {
                    customInfoWindow.favButton.isHidden = false
                    
                }
                
                if (trailSearchDict.isFavourite == "1")
                {
                    
                    customInfoWindow.favButton.isSelected = true
                }
                else
                {
                    
                    customInfoWindow.favButton.isSelected = false
                }
                
                
                // set Trail Name
                customInfoWindow.trailNameLbl.text = trailSearchDict.trailName
                
                // set Trail Note
                let screenSize = UIScreen.main.bounds.size
                let newSize = self.rectForText(trailSearchDict.trailNote, font: UIFont(name: "Calibri", size: 14.0)!, maxSize: CGSize(width: (screenSize.width - 56),height: 30))
                if newSize.width > screenSize.width - 80
                {
                    customInfoWindow.trailDescLabelheightConstraints.constant = 56
                    customInfoWindow.trailDescLbl.textContainer.maximumNumberOfLines = 2
                }
                else
                {
                    customInfoWindow.trailDescLabelheightConstraints.constant = 28
                    customInfoWindow.trailDescLbl.textContainer.maximumNumberOfLines = 1
                }
                let aux = "<span style=\"font-family: Calibri; color: #000000; font-size: 13.0\">\(trailSearchDict.trailNote)</span>"
                let attrString3 = aux.html2AttributedString
                
                let text = attrString3!.string
                let types: NSTextCheckingResult.CheckingType = .link
                
                do {
                    let detector = try NSDataDetector(types: types.rawValue)
                    let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.characters.count))
                    if matches.count > 0 {
                        
                        let url = matches[0].url!
                        let linkTextWithColor = "\(url)"
                        
                        let textRange = (text as NSString).range(of: linkTextWithColor)
                        
                        let myMutableString = NSMutableAttributedString(string:text)
                        
                        
                        myMutableString.addAttribute(
                            NSFontAttributeName,
                            value: UIFont(
                                name: "Calibri",
                                size: 14.0)!,
                            range: NSRange(
                                location: 0,
                                length: text.characters.count))
                        
                        myMutableString.addAttribute(
                            NSForegroundColorAttributeName,
                            value: UIColor.blue,
                            range: textRange)
                        
                        customInfoWindow.trailDescLbl.attributedText = myMutableString
                    }
                    else
                        
                    {
                        customInfoWindow.trailDescLbl.attributedText = attrString3
                    }
                    
                } catch {
                    // none found or some other issue
                    print ("error in findAndOpenURL detector")
                }
                
                // set date
                if trailSearchDict.statusLastUpdate == ""
                {
                    customInfoWindow.DateLabel.text = trailSearchDict.statusLastUpdate
                }
                else
                {
                    customInfoWindow.DateLabel.text = convertDateFormater(trailSearchDict.statusLastUpdate)
                }
                
                // set trailLength
                customInfoWindow.trailLengthLabel.text = trailSearchDict.trailLength + openMeasure + "."
                
                // set image as per trail status
                if (trailSearchDict.trailStatus == "O")
                {
                    let image = UIImage(named: "big-open-status-icon")! as UIImage
                    customInfoWindow.trailStatusImgview.image = image
                    customInfoWindow.trailStatusLabel.text = "Open"
                    customInfoWindow.trailStatusLabel?.textColor = UIColor(red: 65.0/255, green: 132.0/255, blue: 65.0/255, alpha: 1.0)
                }
                if (trailSearchDict.trailStatus == "CA")
                {
                    let image = UIImage(named: "big-caution-status-icon")! as UIImage
                    customInfoWindow.trailStatusImgview.image = image
                    customInfoWindow.trailStatusLabel.text = "Caution"
                    customInfoWindow.trailStatusLabel?.textColor = UIColor(red: 242/255, green: 154/255, blue: 51/255, alpha: 1.0)
                }
                if (trailSearchDict.trailStatus == "C")
                {
                    let image = UIImage(named: "big-closed-status-icon")! as UIImage
                    customInfoWindow.trailStatusImgview.image = image
                    customInfoWindow.trailStatusLabel.text = "Closed"
                    customInfoWindow.trailStatusLabel?.textColor = UIColor(red: 233/255, green: 63/255, blue: 52/255, alpha: 1.0)
                }
                // Set difficulty image
                if (trailSearchDict.trailDifficultyId == "1")
                {
                    let image = UIImage(named: "difficulty-icon Beginner")! as UIImage
                    customInfoWindow.trailDifficultyButton.setImage(image, for: UIControlState())
                }
                else if (trailSearchDict.trailDifficultyId == "2")
                {
                    let image = UIImage(named: "difficulty-icon intermediate")! as UIImage
                    customInfoWindow.trailDifficultyButton.setImage(image, for: UIControlState())
                }
                else if (trailSearchDict.trailDifficultyId == "3")
                {
                    let image = UIImage(named: "difficulty-icon Expert")! as UIImage
                    customInfoWindow.trailDifficultyButton.setImage(image, for: UIControlState())
                }
                else if (trailSearchDict.trailDifficultyId == "4")
                {
                    let image = UIImage(named: "difficulty-icon ExpertOnly")! as UIImage
                    customInfoWindow.trailDifficultyButton.setImage(image, for: UIControlState())
                }
                else if (trailSearchDict.trailDifficultyId == "5")
                {
                    let image = UIImage(named: "difficulty-icon TerrianPark")! as UIImage
                    customInfoWindow.trailDifficultyButton.setImage(image, for: UIControlState())
                }
                else
                {
                    
                }
               
                let newSize1 = self.rectForText(trailSearchDict.trailName, font: UIFont(name: "Calibri-Bold", size: 15.0)!, maxSize: CGSize(width: (screenSize.width - 40),height: 21))
                let newSize2 = self.rectForText(trailSearchDict.trailNote, font: UIFont(name: "Calibri", size: 14.0)!, maxSize: CGSize(width: (screenSize.width - 56),height: 30))
                let array  = [newSize1.width,newSize2.width]
                let finalwidth =  array.max()
                
                if finalwidth<230
                {
                     customInfoWindow.frame.size.width = 250
                }
                else
                {
                    customInfoWindow.frame.size.width = finalwidth!+60
                }
               
                if newSize2.width > screenSize.width - 80
                {
                     customInfoWindow.frame.size.height = 125
                }
                else
                {
                     customInfoWindow.frame.size.height = 102
                }

                return customInfoWindow
                
                
            }
            
            
            
        }
        /*! @brief - GMSMapViewDelegate methods.
         @discussion - when closing popup window, remove google map and direction button.
         */
        func mapView(_ mapView: GMSMapView!, didCloseInfoWindowOf marker: GMSMarker!)
        {
            directionsButton.removeFromSuperview()
            googleMapsButton.removeFromSuperview()
        }
        func markerClick(_ sender: MyButton) {
            let fullGPS = sender.gps
            let fullGPSArr = fullGPS!.characters.split{$0 == ","}.map(String.init)
            
            let lat1 : NSString = fullGPSArr[0] as NSString
            let lng1 : NSString = fullGPSArr[1] as NSString
            
            
            let latitude:CLLocationDegrees =  lat1.doubleValue
            let longitude:CLLocationDegrees =  lng1.doubleValue
            
            if (sender.tag == 0) {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    UIApplication.shared.openURL(URL(string:
                        "comgooglemaps://?q=\(latitude),\(longitude)&center=\(latitude),\(longitude)&zoom=12")!)
                } else {
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Please install Google Maps first."
                    alert.addButton(withTitle: "Ok")
                    alert.show()
                }
            }
            if (sender.tag == 1) {
                if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    UIApplication.shared.openURL(URL(string:
                        "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&center=\(latitude),\(longitude)&directionsmode=driving&zoom=12")!)
                } else {
                    let alert = UIAlertView()
                    alert.title = "Alert"
                    alert.message = "Please install Google Maps first."
                    alert.addButton(withTitle: "Ok")
                    alert.show()
                }
            }
            
        }
        
        /*! @brief - Custom button actions.
         @discussion -cliking on info button and show  info screen.
         */
        @IBAction func infoAlertButtonAction(_ sender: AnyObject) {
            
            boolForPresentingView = true
            
            clearBadgeOfButton(infoHeaderBtn)
            
            let menuInfoAlertVC = MenuInfoAlertVC(nibName: "MenuInfoAlertVC", bundle: nil)
            self.navigationController?.pushViewController(menuInfoAlertVC, animated: false)
            
        }
        /*! @brief - Custom button actions.
         @discussion -cliking on trail button and show trail alert screen.
         */
        @IBAction func trailAlertButtonAction(_ sender: AnyObject) {
            
            boolForPresentingView = true
        
            clearBadgeOfButton(trailHeaderBtn)
            
            let trailAlertVC = TrailAlertVC(nibName: "TrailAlertVC", bundle: nil)
            self.navigationController?.pushViewController(trailAlertVC, animated: false)
        }
        
        /*! @brief - Custom button actions.
         @discussion -cliking on messagebutton button and show Trustee assignment screen.
         */
        @IBAction func trusteeAssignmentButtonAction(_ sender: AnyObject) {
            
            boolForPresentingView = true
   
            clearBadgeOfButton(msgHeaderBtn)
            
            let trusteeAssignmentVC = TrusteeAssignmentVC(nibName: "TrusteeAssignmentVC", bundle: nil)
            self.navigationController?.pushViewController(trusteeAssignmentVC, animated: false)
        }
        
        /*! @brief - Custom button actions.
         @discussion -cliking on cancel button on custom popup window and remove popup view
         */
        @IBAction func ConnectButtonAction(_ sender: AnyObject)
        {
            boolForPresentingView = true
            let connectVC = ConnectVC(nibName: "ConnectVC", bundle: nil)
            connectVC.organistionID = organizationId
            let dict : NSDictionary = responseDict.object(forKey: "connect") as! NSDictionary
            connectVC.connectDict = NSMutableDictionary.init(dictionary: dict)
            self.navigationController?.pushViewController(connectVC, animated: false)
        }
        
        /*! @brief - Custom button actions.
         @discussion -cliking on menu button and open menuscreen according to user Type
         */
        @IBAction func MenuButtonAction(_ sender: AnyObject) {
            
            if Singleton.sharedInstance.userInfo.userType == "T"
            {
                let trusteeVC = LogoutTrusteeViewController(nibName: "LogoutTrusteeViewController", bundle: nil)
                trusteeVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.view.addSubview(trusteeVC.view)
                self.addChildViewController(trusteeVC)
                trusteeVC.didMove(toParentViewController: self)
            }
            if Singleton.sharedInstance.userInfo.userType == "O"
            {
                
                
                let orgVC = OrgMenuVC(nibName: "OrgMenuVC", bundle: nil)
                orgVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.view.addSubview(orgVC.view)
                self.addChildViewController(orgVC)
                orgVC.didMove(toParentViewController: self)
                
            }
            if Singleton.sharedInstance.userInfo.userType == "M"
            {
                let memberVC = MemberMenuVC(nibName: "MemberMenuVC", bundle: nil)
                memberVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.view.addSubview(memberVC.view)
                self.addChildViewController(memberVC)
                memberVC.didMove(toParentViewController: self)
                
            }
            boolForMenuView = true
            boolForPresentingView = true
        }
        
        /*! @brief - Custom button actions.
         @discussion -cliking on Filet button and open TrailDetailFilterVC
         */
        @IBAction func filterButtonAction(_ sender: AnyObject) {
            
            boolForPresentingView = true
            let trailfilterVC = TrailDetailFilterVC(nibName: "TrailDetailFilterVC", bundle: nil)
            self.navigationController?.pushViewController(trailfilterVC, animated: false)
            
        }
        /*! @brief - Custom button actions.
         @discussion -cliking on show button and open TrailDetailShowVC
         */
        @IBAction func showButtonAction(_ sender: AnyObject) {
            
            boolForPresentingView = true
            trailDetailVC = TrailDetailShowVC(nibName: "TrailDetailShowVC", bundle: nil)
            if boolForMAapAndListBool == true
            {
                trailDetailVC.viewIsSelected = "List"
            }
            else
            {
                trailDetailVC.viewIsSelected = "Map"
            }
            self.navigationController?.pushViewController(trailDetailVC, animated: false)
            
        }
        /*! @brief - Custom button actions.
         @discussion -cliking on share button and open popup
         */
        @IBAction func shareButtonAction(_ sender: AnyObject) {
            
            let alert = UIAlertView()
            alert.title = "Share"
            alert.message = "Coming Soon"
            alert.addButton(withTitle: "Ok")
            alert.show()
            
        }
        /*! @brief - Custom button actions.
         @discussion -cliking on map button button and switch list and map
         */
        @IBAction func mapAndListButtonAction(_ sender: AnyObject)
        {
            if (directionsButton != nil) && (googleMapsButton != nil)
            {
                directionsButton.removeFromSuperview()
                googleMapsButton.removeFromSuperview()
            }
            if  boolForMAapAndListBool == false
            {
                
                boolForMAapAndListBool = true
                mapView.isHidden = true
                tableViewTrailDetail.isHidden = false
                if responseDict.count>0
                {
                    self.updateHeader(responseDict)
                    self.updateScreenData(responseDict)
                }
                mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn"), for: UIControlState())
                mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn-sel"), for: .highlighted)
                mapAndListBtn.setBackgroundImage(UIImage(named: "list-menu-unselected"), for: .selected)
                
                
            }
            else
            {
                
                let defaults = UserDefaults.standard
                if defaults.object(forKey: "fileDownload") != nil
                {
                    boolForMAapAndListBool = false
                    tableViewTrailDetail.isHidden = true
                    mapView.isHidden = false
                    if responseDict.count>0
                    {
                        self.updateHeader(responseDict)
                        self.addPath(responseDict)
                    }
                    
                    mapAndListBtn.setBackgroundImage(UIImage(named: "list-menu-unselected"), for: UIControlState())
                    mapAndListBtn.setBackgroundImage(UIImage(named: "list_menu_selected"), for: .highlighted)
                    mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn"), for: .selected)
                }
                else
                {
                    let refreshAlert = UIAlertController(title: "Alert", message: "Maps downloading - click MAP menu shortly.", preferredStyle: UIAlertControllerStyle.alert)
                    present(refreshAlert, animated: true, completion: nil)
                    
                    
                    // Delay the dismissal by 5 seconds
                    let delay = 2.0 * Double(NSEC_PER_SEC)
                    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time, execute: {
                        
                        refreshAlert.dismiss(animated: true, completion: nil)
                    })
                }
                
                
            }
            
        }
       
        /*! @brief - Custom button actions.
         @discussion -cliking onfavorite button button and open custom popup view
         */

        @IBAction func favoriteButtonAction(_ sender: AnyObject) {
            if Singleton.sharedInstance.userInfo.userType == "O"
            {
                DTIToastCenter.defaultCenter.makeText("Favorites not allowed for Org Admin Role.\nFavorites are a feature for TrailHUB Members.")
            }
            else
            {
                tableViewTrailDetail.isHidden=true
                mapView.isHidden=true
                
                favoritepopUpView.isHidden = false
                favoritepopUpView.bringSubview(toFront: self.view)
            }
        }
     
        /*! @brief - Custom button actions.
         @discussion -cliking onfavorite button icon and make all trail favorite
         */
        
        @IBAction func setFavoriteButtonAction(_ sender: AnyObject) {
            
            
            if boolForMAapAndListBool == false
            {
                
                mapView.isHidden=false
            }
            else
            {
                tableViewTrailDetail.isHidden=false
                
            }
            favoritepopUpView.isHidden = true
            
            
            var trailIDs : String = ""
            for recItem in self.trailSearchItem {
                
                let dict = recItem as! TrailSearchRecord
                let index = self.trailSearchItem.index(of: dict)
                if (index == self.trailSearchItem.count-1)
                {
                    trailIDs = trailIDs + dict.trailId
                }
                else
                {
                    trailIDs = trailIDs + dict.trailId + ","
                }
                
            }
            
            let paramDict : NSMutableDictionary = ["authToken" : Singleton.sharedInstance.userInfo.authToken,
                                                   "trailId" : trailIDs,
                                                   "checkFavorite" : "1",
                                                   "activityId" : activityId,
                                                   "organizationId" : organizationId,
                                                   "userId" : Singleton.sharedInstance.userInfo.userId
            ]
            
            getAppEngine().callPOSTMethod(withData: paramDict, andMethodName:WebMethodType_saveFavoriteTrail, andController: self)
            
        }
        /*! @brief - Custom button actions.
         @discussion -cliking cross button icon and remove popup view
         */

        @IBAction func crossButtonAction(_ sender: AnyObject) {
            
            if boolForMAapAndListBool == false
            {
                
                mapView.isHidden=false
            }
            else
            {
                tableViewTrailDetail.isHidden=false
                
            }
            favoritepopUpView.isHidden = true
            
            
        }
        
        @IBAction func backButtonAction(_ sender: AnyObject) {
            
            self.navigationController!.popViewController(animated: true)
        }
        
        
        /*! @brief - Custom button actions.
         @return - return dynamic size of particular string
         */
        func rectForText(_ text: String, font: UIFont, maxSize: CGSize) -> CGSize {
            let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:font])
            let rect = attrString.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            let size = CGSize(width: rect.size.width, height: rect.size.height)
            return size
        }
     
        /*! @brief TableViewDataSource Method.*/
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return trailSearchItem.count
            
        }
        /*! @brief TableViewDataSource Method.*/
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            let screenSize = UIScreen.main.bounds.size
            
            let textView = UITextView()
            textView.frame = CGRect(x: 20, y: 10, width: screenSize.width - 40, height: 16)
            let trailSearchDict:TrailSearchRecord = self.trailSearchItem.object(at: (indexPath as NSIndexPath).row) as! TrailSearchRecord
            let aux = "<span style=\"font-family: Calibri; color: #000000; font-size: 14.0\">\(trailSearchDict.trailNote)</span>"
            let attrString3 = aux.html2AttributedString
            textView.attributedText = attrString3
            textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            let contentSize = textView.sizeThatFits((textView.bounds.size))
           
            return contentSize.height + 58.0
            
        }
        /*! @brief TableViewDataSource Method.*/
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            var cell : TrailDetailTVCell? = tableView.dequeueReusableCell(withIdentifier: "TrailDetailTVCell") as? TrailDetailTVCell
            if(cell == nil)
            {
                cell = TrailDetailTVCell(style: UITableViewCellStyle.default, reuseIdentifier: "TrailDetailTVCell")
                
            }
            cell!.selectionStyle = UITableViewCellSelectionStyle.none
            
            if((indexPath as NSIndexPath).row % 2 == 0){
                cell!.backgroundColor = UIColor.clear
            }else {
                cell!.backgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1.0)
            }
            
            // add content to cell
            let trailSearchDict:TrailSearchRecord = self.trailSearchItem.object(at: (indexPath as NSIndexPath).row) as! TrailSearchRecord
            
            
            
            //Set organisation favorite/unfavorite image and action
            if Singleton.sharedInstance.userInfo.userType == "O"
            {
                cell?.favButton.isHidden = true
                cell?.trailDescLabelxPosition.constant = 2
                cell?.dateLabelxPosition.constant = 15
                cell?.trailNameLabelxPosition.constant = 5
                
            }
            else
            {
                cell?.favButton.isHidden = false
                
            }
            
            if (trailSearchDict.isFavourite == "1")
            {
                
                cell?.favButton.isSelected = true
                cell?.favButton.tag = (indexPath as NSIndexPath).row
                cell?.favButton.addTarget(self, action: #selector(TrailDetailScreenVC.AddTrailFav(_:)), for:.touchUpInside)
            }
            else
            {
                
                cell?.favButton.isSelected = false
                cell?.favButton.tag = (indexPath as NSIndexPath).row
                cell?.favButton.addTarget(self, action: #selector(TrailDetailScreenVC.AddTrailFav(_:)), for:.touchUpInside)
                
            }
            
            
            // set Trail Name
            cell?.trailNameLbl.text = trailSearchDict.trailName
            
            // set Trail Note
            
            let aux = "<span style=\"font-family: Calibri; color: #000000; font-size: 14.0\">\(trailSearchDict.trailNote)</span>"
            let attrString3 = aux.html2AttributedString
          
            cell?.trailDescTextView.attributedText = attrString3
            cell?.trailDescTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            let contentSize = cell?.trailDescTextView.sizeThatFits((cell?.trailDescTextView.bounds.size)!)
            cell?.trailDetailHeightConst.constant = (contentSize?.height)!
            
            
            
            // set date
            if trailSearchDict.statusLastUpdate == ""
            {
                cell?.DateLabel.text = trailSearchDict.statusLastUpdate
            }
            else
            {
                cell?.DateLabel.text = convertDateFormater(trailSearchDict.statusLastUpdate)
            }
            
            // set trailLength
            cell?.trailLengthLabel.text = trailSearchDict.trailLength + openMeasure + "."
            
            // set image as per trail status
            if (trailSearchDict.trailStatus == "O")
            {
                let image = UIImage(named: "big-open-status-icon")! as UIImage
                cell?.trailStatusImgview.image = image
                cell?.trailStatusLabel.text = "Open"
                cell?.trailStatusLabel?.textColor = UIColor(red: 65.0/255, green: 132.0/255, blue: 65.0/255, alpha: 1.0)
            }
            if (trailSearchDict.trailStatus == "CA")
            {
                let image = UIImage(named: "big-caution-status-icon")! as UIImage
                cell?.trailStatusImgview.image = image
                cell?.trailStatusLabel.text = "Caution"
                cell?.trailStatusLabel?.textColor = UIColor(red: 242/255, green: 154/255, blue: 51/255, alpha: 1.0)
            }
            if (trailSearchDict.trailStatus == "C")
            {
                let image = UIImage(named: "big-closed-status-icon")! as UIImage
                cell?.trailStatusImgview.image = image
                cell?.trailStatusLabel.text = "Closed"
                cell?.trailStatusLabel?.textColor = UIColor(red: 233/255, green: 63/255, blue: 52/255, alpha: 1.0)
            }
            // Set difficulty image
            if (trailSearchDict.trailDifficultyId == "1")
            {
                let image = UIImage(named: "difficulty-icon Beginner")! as UIImage
                cell?.trailDifficultyButton.setImage(image, for: UIControlState())
            }
            else if (trailSearchDict.trailDifficultyId == "2")
            {
                let image = UIImage(named: "difficulty-icon intermediate")! as UIImage
                cell?.trailDifficultyButton.setImage(image, for: UIControlState())
            }
            else if (trailSearchDict.trailDifficultyId == "3")
            {
                let image = UIImage(named: "difficulty-icon Expert")! as UIImage
                cell?.trailDifficultyButton.setImage(image, for: UIControlState())
            }
            else if (trailSearchDict.trailDifficultyId == "4")
            {
                let image = UIImage(named: "difficulty-icon ExpertOnly")! as UIImage
                cell?.trailDifficultyButton.setImage(image, for: UIControlState())
            }
            else if (trailSearchDict.trailDifficultyId == "5")
            {
                let image = UIImage(named: "difficulty-icon TerrianPark")! as UIImage
                cell?.trailDifficultyButton.setImage(image, for: UIControlState())
            }
            else
            {
                
            }
            
            return cell!
        }
        
        /*! @brief TableViewDelegate Method.*/
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        }
        
         /*! @brief open url in browser with cliking on any cell information.*/
        func openURL(_ sender:UIButton!)
        {
            let dataDic : SearchResult = SearchResult.getTrailSearchRecordFromData(responseDict)
            
            if let url = URL(string: dataDic.strAlertUrl) {
                
                // Stop File Downloading
                let fileDownLoad = FileDownloadingAndXMLParsing()
                fileDownLoad.stopDownloading()
                
                UIApplication.shared.openURL(url)
            }
            
        }
       
        /*! @brief - Custom button actions.
         @discussion -cliking onfavorite button icon and make particular trail favorite
         */

        func AddTrailFav(_ sender:UIButton!)
        {
            
            favoriteTrailSender = sender
            favoriteTrailTag = sender.tag
            let trailSearchDict:TrailSearchRecord = self.trailSearchItem.object(at: sender.tag) as! TrailSearchRecord
            var favoriteStr:String = ""
            if trailSearchDict.isFavourite == "1"
            {
                
                favoriteStr = "0"
            }
            else
            {
                
                favoriteStr = "1"
            }
            
            let paramDict : NSMutableDictionary = ["authToken" : Singleton.sharedInstance.userInfo.authToken,
                                                   "trailId" : trailSearchDict.trailId,
                                                   "checkFavorite" : favoriteStr,
                                                   "activityId" : activityId,
                                                   "userId" : Singleton.sharedInstance.userInfo.userId
            ]
            
            getAppEngine().callPOSTMethod(withData: paramDict, andMethodName:WebMethodType_saveFavoriteTrail, andController: self)
            
            
        }
        
        /*! @brief - Call Api to get trail detail listing.*/
        func trailDetailSearchApi ()
        {
            let paramDict : NSMutableDictionary = ["authToken" : Singleton.sharedInstance.userInfo.authToken,
                                                   "activityId" : activityId,
                                                   "stateId" : stateId,
                                                   "countryId" : countryId,
                                                   "organizationId" : organizationId,
                                                   "userId" : Singleton.sharedInstance.userInfo.userId,
                                                   "userType" : Singleton.sharedInstance.userInfo.userType,
                                                   "enmMirrorActivity":enmMirrorActivity,
                                                   "strActivityName": activityName

                
            ]
            
            getAppEngine().callPOSTMethod(withData: paramDict, andMethodName:WebMethodType_getSearchOrganizationTrails, andController: self)
            
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
                
            case 9:     //WebMethodType_getSearchOrganizationTrails
                
                if let myDictionary = response as? [String : AnyObject]
                {
                    responseDict = myDictionary as NSDictionary
                
                    if myDictionary["records"] != nil
                    {
                        self.checkMapAndListButtonStatus()
                    }
                    else
                    {
                        let alertController = UIAlertController(title: "", message: "Organization setup still in progress. Trails not added yet, check back soon.", preferredStyle: .alert)
                        
                        // Create the actions
                        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            
                            // perform action
                            _ = self.navigationController?.popViewController(animated: true)
                            
                            
                        }
                        
                        // Add the actions
                        alertController.addAction(okAction)
                        
                        // Present the controller
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                    
                    
                }
                
                break
                
            case 11:     //WebMethodType_saveFavoriteTrail
                
                if let myDictionary = response as? [String : AnyObject]
                {
                    if (favoriteTrailSender == nil && favoriteTrailTag == 0)
                    {
                        self.trailDetailSearchApi()
                        
                    }
                    else
                    {
                        
                        let trailSearchDict:TrailSearchRecord = self.trailSearchItem.object(at: favoriteTrailTag) as! TrailSearchRecord
                        if trailSearchDict.isFavourite == "1"
                        {
                            trailSearchDict.setValue("0", forKey:"isFavourite")
                            
                        }
                        else
                        {
                            trailSearchDict.setValue("1", forKey:"isFavourite")
                            
                        }
                        self.trailSearchItem.replaceObject(at: favoriteTrailTag, with: trailSearchDict)
                        let point : CGPoint = favoriteTrailSender.convert(CGPoint.zero, to:tableViewTrailDetail)
                        let indexPath = tableViewTrailDetail!.indexPathForRow(at: point)
                        tableViewTrailDetail.beginUpdates()
                        tableViewTrailDetail.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
                        tableViewTrailDetail.endUpdates()
                        
                        favoriteTrailTag = 0
                        favoriteTrailSender = nil
                    }
                    
                    DTIToastCenter.defaultCenter.makeText(myDictionary["message"] as! String)
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
        
        /*! @brief Call Parsing method.
         @discussion send kml or KMZ url and parse it using NSXML to get coordinates list
         */
        func beginParsing(_ serverFileName : String, filteredArray : NSMutableArray, trailStatusString : String,  kmlModifiedTime : String)
        {
            
            if serverFileName == ""
            {
                
                countForDowloading = countForDowloading + 1
                self.pathArray.insert("", at: self.pathArray.count)
                self.showPathOnMap(self.trailSearchItem)
            }
            else
            {
                
                countForDowloading = countForDowloading + 1
                flagForServerFile = true
                let url:String = KML_BASE_URL + serverFileName
                let fileDownLoad = FileDownloadingAndXMLParsing()
                fileDownLoad.delegate = self
                fileDownLoad.startDownload(url,statusType: trailStatusString, fileCount: countForDowloading, filename: serverFileName, modfiedDateAndTime: kmlModifiedTime)
                
            }
            
            
        }
        

        /*! @brief Call getPathFormCoordinatesArrayifGXCoordinate method if GooglePath is finding "GX Coord" tag.
            @discussion  get one by one coordinates and add them to GMSMutablePath and GMSCoordinateBounds
            @return GMSMutablePath and GMSCoordinateBounds
         */
        func getPathFormCoordinatesArrayifGXCoordinate(_ coordinateArray: NSMutableArray,completionHandler: CompletionHandler) {
            
            do
            {
            // download code.
            let routePath = GMSMutablePath()
            var bounds : GMSCoordinateBounds = GMSCoordinateBounds()
            for (_, element) in coordinateArray.enumerated() {
                
                
                let coordinatesString = (element as AnyObject) as! NSString
                
                // If the parenthesis are present you can remove them:
                var stringElmt = coordinatesString.replacingOccurrences(of: "\n", with: "")
                stringElmt = stringElmt.replacingOccurrences(of: "\t", with: "")
                var elmtArray = stringElmt.components(separatedBy: " ")
                
                if elmtArray.count >= 2 {
                    let latitude = Double(elmtArray[1])
                    let longitude = Double(elmtArray[0])
                    
                    routePath.add(CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                    
                    let  position = CLLocationCoordinate2DMake(latitude!, longitude!)
                    bounds = bounds.includingCoordinate(position)
                    
                }
            }
            let polylineWithPath : GMSPolyline = GMSPolyline()
            polylineWithPath.path = routePath
            
            let flag = true // true if download succeed,false otherwise
            
            completionHandler(bounds ,polylineWithPath ,flag)
        }
            catch {
                
                Belief_ProgressHud.remove()
                let refreshAlert = UIAlertController(title: "TrailHUB", message: "Invalid GPS Tracking Format detected, defaulting to List View.", preferredStyle: UIAlertControllerStyle.alert)
                present(refreshAlert, animated: true, completion: nil)
                
                
                // Delay the dismissal by 5 seconds
                let delay = 2.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    
                    refreshAlert.dismiss(animated: true, completion: nil)
                    if (self.directionsButton != nil) && (self.googleMapsButton != nil)
                    {
                        self.directionsButton.removeFromSuperview()
                        self.googleMapsButton.removeFromSuperview()
                    }
                    self.boolForMAapAndListBool = true
                    self.mapView.isHidden = true
                    self.tableViewTrailDetail.isHidden = false
                    if self.responseDict.count>0
                    {
                        self.updateHeader(self.responseDict)
                        self.updateScreenData(self.responseDict)
                    }
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn"), for: UIControlState())
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn-sel"), for: .highlighted)
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "list-menu-unselected"), for: .selected)
                    

                })

            }
        }
        
        /*! @brief Call getPathFormCoordinatesArrayifGXCoordinate method if GooglePath is finding "Coordinates" tag.
         @discussion  get one by one coordinates and add them to GMSMutablePath and GMSCoordinateBounds
         @return GMSMutablePath and GMSCoordinateBounds
         */
        func getPathFormCoordinatesArrayifCoordinates(_ coordinatesString: NSString,completionHandler: CompletionHandler) {
            do{
            // download code.
            let routePath = GMSMutablePath()
            var bounds : GMSCoordinateBounds = GMSCoordinateBounds()
            
            // If the parenthesis are present you can remove them:
            var stringElmt = coordinatesString.replacingOccurrences(of: "\n", with: "")
            stringElmt = stringElmt.replacingOccurrences(of: "\t", with: "")
            let coordArray = stringElmt.components(separatedBy: " ") as NSArray
            if coordArray.count>0
            {
                for i in stride(from: 0, to: coordArray.count, by: 1)
                {
                    
                    let coordinatesString = coordArray.object(at: i) as! NSString
                    var stringElmt = coordinatesString.replacingOccurrences(of: "\n", with: "")
                    stringElmt = stringElmt.replacingOccurrences(of: "\t", with: "")
                    var elmtArray = stringElmt.components(separatedBy: ",")
                    
                    if elmtArray.count >= 2 {
                        let latitude = Double(elmtArray[1])
                        let longitude = Double(elmtArray[0])
                        
                        routePath.add(CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
                        
                        let  position = CLLocationCoordinate2DMake(latitude!, longitude!)
                        bounds = bounds.includingCoordinate(position)
                        
                        
                    }
                    
                    
                }
            }
            let polylineWithPath : GMSPolyline = GMSPolyline()
            polylineWithPath.path = routePath
            
            let flag = true // true if download succeed,false otherwise
            
            completionHandler(bounds ,polylineWithPath ,flag)
        }
        
        catch {
            Belief_ProgressHud.remove()
            let refreshAlert = UIAlertController(title: "TrailHUB", message: "Invalid GPS Tracking Format detected, defaulting to List View.", preferredStyle: UIAlertControllerStyle.alert)
            present(refreshAlert, animated: true, completion: nil)
            
            
            // Delay the dismissal by 5 seconds
            let delay = 2.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                
                refreshAlert.dismiss(animated: true, completion: nil)
                if (self.directionsButton != nil) && (self.googleMapsButton != nil)
                {
                    self.directionsButton.removeFromSuperview()
                    self.googleMapsButton.removeFromSuperview()
                }
                self.boolForMAapAndListBool = true
                self.mapView.isHidden = true
                self.tableViewTrailDetail.isHidden = false
                if self.responseDict.count>0
                {
                    self.updateHeader(self.responseDict)
                    self.updateScreenData(self.responseDict)
                }
                self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn"), for: UIControlState())
                self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn-sel"), for: .highlighted)
                self.mapAndListBtn.setBackgroundImage(UIImage(named: "list-menu-unselected"), for: .selected)
                
                
            })

        }
    }

        
        
        /*! @brief Method called by Delegate when NSXMLPArser parse one file by one send file to this method.
         @return NSMutableArray containing coordinates and and path color
         */
        func passLocationarray(_ locationArray: NSMutableArray, statusForColor : String)
        {
            do{

          
    
            var checkCount : Int = 0
            for (_, element) in locationArray.enumerated()
            {
                checkCount = checkCount + 1
                if (element as AnyObject).object(forKey: "gx:coord") != nil
                {
                  
                    let gxCoordinateArray = (element as AnyObject).object(forKey: "gx:coord") as! NSMutableArray
                    self.getPathFormCoordinatesArrayifGXCoordinate(gxCoordinateArray) { (gmsBounds, polyline, success) in
                        
                        self.polylineWithPath = polyline
                        self.coordinatesBound = gmsBounds
                        self.polylineWithPath.strokeWidth = 4
                        
                        // set image as per trail status
                        if (statusForColor == "O")
                        {
                            
                            self.polylineWithPath.strokeColor = UIColor(red: 65.0/255, green: 132.0/255, blue: 65.0/255, alpha: 1.0)
                        }
                        if (statusForColor == "CA")
                        {
                            
                            self.polylineWithPath.strokeColor = UIColor(red: 242/255, green: 154/255, blue: 51/255, alpha: 1.0)
                        }
                        if (statusForColor == "C")
                        {
                            
                            self.polylineWithPath.strokeColor = UIColor(red: 233/255, green: 63/255, blue: 52/255, alpha: 1.0)
                        }
                        
                        self.polylineWithPath.map = self.mapView
                        
                        self.polylineWithPath.map.isHidden = true
                        
                        self.pathArray.insert(self.polylineWithPath, at: self.pathArray.count)
                        
                        if checkCount == locationArray.count
                        {
                            self.showPathOnMap(self.trailSearchItem)
                        }
                        
                }
                    
                }
                if (element as AnyObject).object(forKey: "coordinates") != nil
                {
                 
                    let coordinatesString = (element as AnyObject).object(forKey: "coordinates") as! NSString
                    self.getPathFormCoordinatesArrayifCoordinates(coordinatesString) { (gmsBounds, polyline, success) in
                        
                       
                        self.polylineWithPath = polyline
                        self.coordinatesBound = gmsBounds
                        self.polylineWithPath.strokeWidth = 4
                        
                        // set image as per trail status
                        if (statusForColor == "O")
                        {
                            
                            self.polylineWithPath.strokeColor = UIColor(red: 65.0/255, green: 132.0/255, blue: 65.0/255, alpha: 1.0)
                        }
                        if (statusForColor == "CA")
                        {
                            
                            self.polylineWithPath.strokeColor = UIColor(red: 242/255, green: 154/255, blue: 51/255, alpha: 1.0)
                        }
                        if (statusForColor == "C")
                        {
                            
                            self.polylineWithPath.strokeColor = UIColor(red: 233/255, green: 63/255, blue: 52/255, alpha: 1.0)
                        }
                        
                        self.polylineWithPath.map = self.mapView
                        
                        self.polylineWithPath.map.isHidden = true
                        
                        self.pathArray.insert(self.polylineWithPath, at: self.pathArray.count)
                        if checkCount == locationArray.count
                        {
                            self.showPathOnMap(self.trailSearchItem)
                        }
                        
                    }
                    
                }
                
                
            }
            }
            catch {
                Belief_ProgressHud.remove()
                let refreshAlert = UIAlertController(title: "TrailHUB", message: "Invalid GPS Tracking Format detected, defaulting to List View.", preferredStyle: UIAlertControllerStyle.alert)
                present(refreshAlert, animated: true, completion: nil)
                
                
                // Delay the dismissal by 5 seconds
                let delay = 2.0 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time, execute: {
                    
                    refreshAlert.dismiss(animated: true, completion: nil)
                    if (self.directionsButton != nil) && (self.googleMapsButton != nil)
                    {
                        self.directionsButton.removeFromSuperview()
                        self.googleMapsButton.removeFromSuperview()
                    }
                    self.boolForMAapAndListBool = true
                    self.mapView.isHidden = true
                    self.tableViewTrailDetail.isHidden = false
                    if self.responseDict.count>0
                    {
                        self.updateHeader(self.responseDict)
                        self.updateScreenData(self.responseDict)
                    }
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn"), for: UIControlState())
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn-sel"), for: .highlighted)
                    self.mapAndListBtn.setBackgroundImage(UIImage(named: "list-menu-unselected"), for: .selected)
                    
                    
                })

            }

            
        }
        /*! @brief Method called to check that all KML or KMz file downloaded or not.  */
        func passBoolIfFileIsNotDownloaded (_ boolValue : Bool)
        {
            
            if flagForServerFileIfNotDownloaded == false
            {
                if boolValue == true
                {
                    
                    
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "fileDownload")
                    
                    flagForServerFileIfNotDownloaded = true
                    
                    Belief_ProgressHud.remove()
                    
                    let refreshAlert = UIAlertController(title: "Alert", message: "Maps downloading - click MAP menu shortly.", preferredStyle: UIAlertControllerStyle.alert)
                    present(refreshAlert, animated: true, completion: nil)
                    
                    
                    // Delay the dismissal by 5 seconds
                    let delay = 2.0 * Double(NSEC_PER_SEC)
                    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time, execute: {
                        
                        refreshAlert.dismiss(animated: true, completion: nil)
                        self.boolForMAapAndListBool = true
                        self.mapView.isHidden = true
                        self.tableViewTrailDetail.isHidden = false
                        if self.responseDict.count>0
                        {
                            self.updateHeader(self.responseDict)
                            self.updateScreenData(self.responseDict)
                        }
                        self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn"), for: UIControlState())
                        self.mapAndListBtn.setBackgroundImage(UIImage(named: "map-btn-sel"), for: .highlighted)
                        self.mapAndListBtn.setBackgroundImage(UIImage(named: "list-menu-unselected"), for: .selected)
                    })
                    
                    
                }
            }
            
        }
        
    }
