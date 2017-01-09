//
//  BlogsViewController.swift
//  RTM
//
//  Created by NehaMishra on 24/06/16.
//  Copyright © 2016 Classic. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO

class BlogsViewController:BaseViewController ,UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout  {
    
    @IBOutlet weak var blogsCollectionView: UICollectionView!          /*! This property is declear for UICollectionView. */
    var newsType : String = ""                                         /*! This property is declear for newsType string value. */
    var newListDict = NSMutableDictionary()                            /*! This property is declear for NewsDictionary */
    var newsArr = NSMutableArray()                                     /*! This property is declear for News Array */
    var BigAdvertismentimage_URL : String = ""                         /*! This property is declear for get Image URL in String */
    var BigAdvertisment_url : String = ""                              /*! This property is declear for URL in String */
    var banerAdController : BanerAdViewController!                     /*! This object is declared of BanerAdViewController*/
    var PageNo : Int = 1                                               /*! This property is declear PageNo*/
    var refreshControl: UIRefreshControl!                              /*! This object is declared for UIRefreshControl*/
    var Directionstr : String = "down"                                 /*!This property is declear for checking direction of UIScrollView*/

    var advertismentArr = NSArray()                                    /*! This property is declear for storing advertismentArr*/
    var timer = Timer()                                                /*! This property is declear for Timer*/
    var adsview = AdsView()                                            /*! This object is declared of AdsView*/

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*! @brief Do any additional setup after loading the view, typically from a nib. !*/
        
        /*!
         @brief It checks this viewController coming from MenuViewController or any other ViewController.
         
         */
        let ViewControllerArr = (self.navigationController?.viewControllers)! as NSArray
        if(ViewControllerArr.count>1)
        {
            self.menuFound = false
            self.backFound = true
            
        }
        else
            
        {
            self.menuFound = true
            self.backFound = false
        }
        
        self.title = globalData.setLanguageForKey("Blogs") as String /*! @brief This method set title of the viewController! */

        NotificationCenter.default.addObserver(self, selector: #selector(BlogsViewController.changeFont(_:)), name: NSNotification.Name(rawValue: "ChangeFont"), object: nil) /*! @brief This method set font of viewControllers! */
        /*!
         @brief It set CollectionView UI Setup
         
         */
        self.setupCollectionView()
        
        /*!
         @brief Here we set the notification for Banner add
         
         */
        NotificationCenter.default.addObserver(self, selector: #selector(BlogsViewController.AddBanner(_:)), name: NSNotification.Name(rawValue: "ShowbannerAd"), object: nil)
        
        /*!
         @brief Here we register BlogsCollectionViewCell
         
         */
        self.blogsCollectionView!.register(UINib(nibName: "BlogsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BlogsCollectionViewCell")
        
        /*! @brief  Added UIRefreshControl in UICollectionView! */

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(BlogsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        blogsCollectionView.addSubview(refreshControl)
        
        /*!
         @brief Here we added activityView and call API in background thread.
         
         */
        activityView.showActivityIndicator(self.view)
        UIApplication.shared.isNetworkActivityIndicatorVisible=true
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { () -> Void in
            // Code to refresh table view
            self.PageNo = 1
            self.ParseNewsListData(self.PageNo , last_id: "",direction: self.Directionstr )
            DispatchQueue.main.async { () -> Void in
                if(self.advertismentArr.count>0)
                {
                    self.view.addSubview(self.adsview)
                    self.adsview.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height+100, width: UIScreen.main.bounds.size.width, height: 44);
                    
                    self.ShowAdvertismentView()
                    self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(EventListingViewController.ChangeImage), userInfo: nil, repeats: true)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible=false
                self.activityView.hideActivityIndicator(self.view)
                self.blogsCollectionView.reloadData()/*!@brief After get data from server reload UICollectionView */
                
            }
        }
    }
    
    /*!
     @brief this method is used for, if app font will change then this notification will change the font this viewController
     
     */
    func changeFont(_ notification: Notification) {
        globalFont.setFont()
        blogsCollectionView.reloadData()
    }
    /*!
     @brief this method is used to add new records in UICollectionView
     */
    func refresh(_ sender:AnyObject) {
        if(newsArr.count>0)
        {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
                self.Directionstr="up"
                // Code to refresh table view
                self.ParseNewsListData(self.PageNo,last_id: (self.newsArr.object(at: 0) as AnyObject).object(forKey: "id") as! String,direction: self.Directionstr)
                DispatchQueue.main.async { () -> Void in
                    self.blogsCollectionView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    /*!
     @brief if app coming from background then this notofcation method  will add BanerAdViewController on this controller
     */
    func AddBanner(_ notification: Notification) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let presentedViewController = appDelegate.mainNavigationController?.visibleViewController
        if  presentedViewController!.isKind(of: BlogsViewController.self)
        {
            appDelegate.bigAdvtImageURL = BigAdvertisment_image as NSString
            appDelegate.bigAdvtURL = BigAdvertisment_url as NSString
            if( appDelegate.bigAdvtImageURL.isEqual(to: "")){
            }
            else
            {
                banerAdController = BanerAdViewController(nibName: "BanerAdViewController", bundle: nil)
                banerAdController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
                
                appDelegate.window?.addSubview(banerAdController.view)
            }
        }
    }
    /*!
     @brief this method used to small adbanner view in viewController
     */
    func ShowAdvertismentView()  {
        
        UIView.animate(withDuration: 3.0, animations: {
            self.adsview.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 44.0, width: UIScreen.main.bounds.size.width, height: 44)
        })
        
    }
    /*!
     @brief this method  ChangeImages in AdsView
     */
    func ChangeImage()
    {
        if(advertismentArr.count>0)
        {
            let randomIndex = Int(arc4random_uniform(UInt32(advertismentArr.count)))
            // Get a random item
            let randomItem = advertismentArr[randomIndex] /*!@brief  get random images from advertismentArr */
            LazyImage.showForImageView(adsview.addsImgView, url: (randomItem as AnyObject).object(forKey: "image") as? String)
            adsview.URlStr = (randomItem as AnyObject).object(forKey: "url") as! String
        }
    }
    /*!
     @brief this method  is called when view will viewWillDisappear
     */
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    /*!
     @brief this method  is called for CollectionView UI Setup
     */
    func setupCollectionView(){
        // Create a waterfall layout
        let layout = CHTCollectionViewWaterfallLayout()
        // Change individual layout attributes for the spacing between cells
        layout.minimumColumnSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        // Collection view attributes
        blogsCollectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        blogsCollectionView.alwaysBounceVertical = true
        // Add the waterfall layout to your collection view
        blogsCollectionView.collectionViewLayout = layout
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*!
     @brief this method  is use to call API and parse data
     */
    func ParseNewsListData(_ pageNo:Int, last_id:String , direction :String)
    {
        let x : Int = PageNo
        let eng :NSString = "en"
        let PageString = String(x)
        let lang = String(eng)
        let reachability : Reachability = Reachability.forInternetConnection()
        let internetStatus : NetworkStatus
        internetStatus = (reachability.currentReachabilityStatus)()
        if  internetStatus != NotReachable {
            //let pareser : NSMutableDictionary
            if let newListDict=WebParser.blogsList(PageString,language: lang, last_ID: last_id, dire: direction)
            {
                if(((newListDict.object(forKey: "data") as! NSDictionary).object(forKey: "status"))! as! String == "200")
                {
                    advertismentArr = ((newListDict.object(forKey: "data") as! NSDictionary).object(forKey: "advertisement")) as! NSArray
                    BigAdvertisment_url = ((newListDict.object(forKey: "data") as! NSDictionary).object(forKey: "big_advertisement_url")) as! String
                    BigAdvertisment_image = ((newListDict.object(forKey: "data") as! NSDictionary).object(forKey: "big_advertiesment")) as! String
                    if(newsArr.count>0){
                        let tempArr = NSMutableArray.init(array: (newListDict.object(forKey: "data")as! NSDictionary).object(forKey: "result") as! NSArray)
                        let commonArray = NSMutableArray()
                        if(direction == "down")
                        {
                            commonArray.addObjects(from: newsArr as [AnyObject])
                            commonArray.addObjects(from: tempArr as [AnyObject])
                            print("commonArray=%@", commonArray)
                            PageNo=PageNo+1
                            newsArr = commonArray
                            print(newsArr.count)
                            blogsCollectionView.reloadData()
                        }
                        else
                        {
                            for i in 0 ..<  tempArr.count
                            {
                                commonArray.insert(tempArr.object(at: i), at: 0)
                            }
                            newsArr = commonArray
                            newsArr = commonArray
                            blogsCollectionView.reloadData()
                        }
                    }
                    else{
                        newsArr =  NSMutableArray.init(array:(newListDict.object(forKey: "data") as! NSDictionary).object(forKey: "result") as! NSArray)
                        PageNo=PageNo+1
                    }
                }
                else
                {
                    DispatchQueue.main.async { () -> Void in
                        self.view.makeToast(newListDict.object(forKey: "message") as! String, duration:1.0, position: CSToastPositionCenter)
                    }
                }
                
            }
            else{
                DispatchQueue.main.async { () -> Void in
                    self.view.makeToast("No response data", duration:1.0, position: CSToastPositionCenter)
                }
            }
        }
        else{
            self.view.makeToast(self.networkErrorMsg, duration:1.0, position: CSToastPositionCenter)
            
        }
    }
    /*!
     @brief UICollectionView delegate
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return newsArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell: BlogsCollectionViewCell = (blogsCollectionView.dequeueReusableCell(withReuseIdentifier: "BlogsCollectionViewCell", for: indexPath) as! BlogsCollectionViewCell)
        cell.shortdescription.text = (newsArr.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "short_description") as? String
        cell.shortdescription?.font = globalFont.fontRegular11
        cell.shortdescription.numberOfLines = 3
        cell.shortdescription.sizeToFit()
        cell.publish_time.text = (newsArr.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "publish_date") as? String
        cell.publish_time?.font = globalFont.fontRegular9
        cell.ImageTitle.text = (newsArr.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "title") as? String
        cell.ImageTitle?.font = globalFont.fontBoldQueen
        cell.ImageTitle.numberOfLines = 2
        cell.ImageTitle.sizeToFit()
        cell.author_name.text = (newsArr.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "author_name") as? String
        cell.author_name.font = globalFont.fontRegular9
        LazyImage .showForImageView(cell.auhor_image, url: ((newsArr .object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "author_image") as?String))
        LazyImage.showForImageView(cell.descrption_Image, url: ((newsArr .object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "featured_image")) as? String)
        return cell
    }
    
    /*!
     @brief  This is UIScrollView delegate which is called when we scroll UICollectionView
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            Directionstr="down"
            print("came to last row")
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
                self.ParseNewsListData(self.PageNo,last_id: (self.newsArr.lastObject as! NSDictionary).object(forKey: "id") as! String,direction: self.Directionstr)
            }
            DispatchQueue.main.async { () -> Void in
            }
        }
        
    }
    
    /*!
     @brief  CollectionView Waterfall Layout Delegate Methods (Required). We get Size for the cells in the Waterfall Layout
     */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        var imageSize = CGSize()
        imageSize.width = (newsArr.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "w") as! CGFloat
        imageSize.height = (newsArr.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "h") as! CGFloat
        return imageSize
    }
    /*!
     @brief  CollectionView  didselect method     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let contentDict = NSMutableDictionary.init(dictionary:((newsArr .object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "post_restriction") as? NSDictionary)!)
        /*!
         @brief  here we checked content is available for logged  user or non login user
         */
        if((contentDict.object(forKey: "logged_id")) as! String == "1")
        {
            let prefs = UserDefaults.standard
            /*!
             @brief  if user logged in then check the Auth_key of user exist or not. if Auth_key not exist then go to LoginViewController
             */
            if((prefs.object(forKey: "Auth_key")) == nil)
            {
                
                let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
                vc.contentDict = contentDict
                appDelegate.ViewController_type = "blog"
                appDelegate.detail_ID = (newsArr .object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "id") as! String
                self.navigationController?.pushViewController(vc, animated: false)
                
            }
            else
            {
                /*!
                 @brief  if user logged in then check user subscription plan if user is free type user thengo to BlogDetailViewController else on VIPMembershipVC for upgrade your plan for this blog.                */
                if((prefs.object(forKey: "subscription_plan")) as! String == "free_plan")
                {
                    if(((contentDict.object(forKey: "subscription") as! NSDictionary).object(forKey: "free_plan"))! as! String == "1")
                    {
                        let blogdetailVC = BlogDetailViewController(nibName: "BlogDetailViewController", bundle: nil)
                        blogdetailVC.title=globalData.setLanguageForKey("blog_Detail") as String
                        blogdetailVC.blog_ID = (newsArr .object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "id") as! String
                        self.navigationController?.pushViewController(blogdetailVC, animated: true)
                    }
                    else
                    {
                        let rtmQuickLinkVC = VIPMembershipVC(nibName: "VIPMembershipVC", bundle: nil)
                        appDelegate.ViewController_type = "blog"
                        appDelegate.detail_ID = (newsArr .object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "id") as! String
                        self.navigationController?.pushViewController(rtmQuickLinkVC, animated: true)
                    }
                    
                    
                }
                    /*!
                     @brief  if user logged in then check user subscription plan if user is soft_copy type user then go to BlogDetailViewController else on VIPMembershipVC for upgrade your plan for this blog.                */
                else if((prefs.object(forKey: "subscription_plan")) as! String == "soft_copy")
                {
                    if(((contentDict.object(forKey: "subscription") as! NSDictionary).object(forKey: "soft_copy"))! as! String == "1")
                    {
                        let blogdetailVC = BlogDetailViewController(nibName: "BlogDetailViewController", bundle: nil)
                        blogdetailVC.title=globalData.setLanguageForKey("blog_Detail") as String
                        blogdetailVC.blog_ID = (newsArr .object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "id") as! String
                        self.navigationController?.pushViewController(blogdetailVC, animated: true)
                    }
                    else
                    {
                        let rtmQuickLinkVC = VIPMembershipVC(nibName: "VIPMembershipVC", bundle: nil)
                        appDelegate.ViewController_type = "blog"
                        appDelegate.detail_ID = (newsArr .object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "id") as! String
                        self.navigationController?.pushViewController(rtmQuickLinkVC, animated: true)
                    }
                }
                else if((prefs.object(forKey: "subscription_plan")) as! String == "hard_copy")
                {
                    
                    let blogdetailVC = BlogDetailViewController(nibName: "BlogDetailViewController", bundle: nil)
                    blogdetailVC.title=globalData.setLanguageForKey("blog_Detail") as String
                    blogdetailVC.blog_ID = (newsArr .object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "id") as! String
                    self.navigationController?.pushViewController(blogdetailVC, animated: true)
                    
                }
            }
        }
        else
        {
            let blogdetailVC = BlogDetailViewController(nibName: "BlogDetailViewController", bundle: nil)
            blogdetailVC.title=globalData.setLanguageForKey("blog_Detail") as String
            blogdetailVC.blog_ID = (newsArr .object(at: (indexPath as NSIndexPath).row) as! NSDictionary).object(forKey: "id") as! String
            self.navigationController?.pushViewController(blogdetailVC, animated: true)
        }
    }
}
