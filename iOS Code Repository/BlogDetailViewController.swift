//  BlogDetailViewController

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


class BlogDetailViewController: BaseViewController {
    
    @IBOutlet weak var DateLB : UILabel?                            /*! This property is declare for date Label. */
    var yxis : CGFloat =  0.0                                       /*! This property is declare for yxis. */
    var fl: CGFloat = 0.0                                           /*! This property is declare for saving webview height. */
    var loginFound :Bool = false                                    /*! This property is declare for checking user login or not. */
    var vipFound :Bool = false                                      /*! This property is declare for checking VIP USER */
    @IBOutlet var detailScrollView: UIScrollView!                   /*! This property is declare UIScrollView */
    @IBOutlet weak var articleBtn: UIButton!                        /*! This object is used for Aticle UIButton */
    @IBOutlet var WebViewHeight: NSLayoutConstraint!                /*! This object is webView height constraints */
    @IBOutlet weak var titleLB : UILabel?                           /*! This object is used for title */
    @IBOutlet weak var authorNameLB : UILabel?                      /*! This object is used for Author name */
    @IBOutlet weak var authorDescriptionLB : UILabel?               /*! This object is used for Author Description */
    @IBOutlet weak var DetailImgView : UIImageView?                 /*! This object is used for larger image view */
    @IBOutlet var ImageView: UIView!                                /*! This object is used for image */
    @IBOutlet var ImageScrollView: UIScrollView!                    /*! This object is used for showing image in scrollView */
    @IBOutlet weak var imageContentView: UIView!                    /*! This object is used for ContentView for images */
    @IBOutlet weak var thumbImgView: UIImageView!                   /*! This object is used for small image  */
    @IBOutlet weak var authorImgView: UIImageView!                  /*! This object is used for author image */
    @IBOutlet var FulImgView: UIImageView!                          /*! This object is used for large image */
    @IBOutlet var FullView: UIView!                                 /*! This object is used for full view */
    @IBOutlet var AuthorView: UIView!                               /*! This object is used for author view */
    @IBOutlet weak var ViewCountBtn: UIButton!                      /*! This object is for Viewcount UIButton*/
    @IBOutlet var ContentViewConstraint: NSLayoutConstraint!        /*! This object is scrollView content height constraints */
    @IBOutlet weak var ContentView: UIView!                         /*! This object is declare of ContentView*/
    @IBOutlet weak var NewsImageView: UIImageView!                  /*! This object is declare of NewsImageView*/
    @IBOutlet var webView: UIWebView!                               /*! This object is declare of webView*/
    
    var imageArr = NSMutableArray()                                 /*! This property is declare image Array */
    var newsDetailData = NSMutableDictionary()                      /*! This property is declare NewsDetail Dictionary */
    var newsDetailArr = NSMutableArray()                            /*! This property is declare NewsDetail Array */
    var blog_ID : String = ""                                       /*! This property is declare string for blog_ID */
    var shareVC = ShareViewController()                             /*! This is the object of ShareViewController  */
    var BigAdvertisment_image : String = ""                         /*! This property is declare for get Image URL in String */

    var BigAdvertisment_url : String = ""                           /*! This property is declare for URL in String */

    var banerAdController : BanerAdViewController!                  /*! This is the object of BanerAdViewController  */
    var advertismentArr = NSArray()                                 /*! This property is declare for storing advertismentArr*/
    var timer = Timer()                                             /*! This property is declare for Timer*/
    var adsview = AdsView()                                         /*! This object is declare of AdsView*/
   
    
    //MARK:- View didLoad
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
        
        /*!
         @brief if loginFound then delete the loginViewController from navigation Array
         
         */
        if(loginFound)
        {
            var navArray:Array = (self.navigationController?.viewControllers)!
            navArray.remove(at: navArray.count-2)
            self.navigationController?.viewControllers = navArray
        }
            /*!
             @brief if vipFound then delete the loginViewController  and VipViewController from navigation Array
             
             */

        else if(vipFound)
        {
            var navArray:Array = (self.navigationController?.viewControllers)!
            navArray.remove(at: navArray.count-2)
            navArray.remove(at: navArray.count-2)
            self.navigationController?.viewControllers = navArray
    
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible=true
        NotificationCenter.default.addObserver(self, selector: #selector(BlogDetailViewController.changeFont(_:)), name: NSNotification.Name(rawValue: "ChangeFont"), object: nil) /*! @brief This method set font of viewControllers! */
        NotificationCenter.default.addObserver(self, selector: #selector(BlogDetailViewController.AddBanner(_:)), name: NSNotification.Name(rawValue: "ShowbannerAd"), object: nil) /*! @brief Here we set the notification for Banner add !*/
        /*!
         @brief Here we added activityView and call API in background thread.
         
         */
        activityView.showActivityIndicator(self.view)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
            // background thread code
            self.ParseBlogDetailData(self.blog_ID)
                DispatchQueue.main.async { () -> Void in
                // done, back to main thread
                UIApplication.shared.isNetworkActivityIndicatorVisible=false
                self.activityView.hideActivityIndicator(self.view)
                if(self.newsDetailArr.count>0)
                {
                    self.addBadgeForViewCount()
                    self.DateLB?.text = (self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "publish_date") as? String
                    self.DateLB?.font = globalFont.fontRegular9
                    self.titleLB?.text = (self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "title") as? String
                    self.titleLB?.font = globalFont.fontBoldAce
                    self.titleLB!.adjustsFontSizeToFitWidth = true
                    
                    let scrollViewBounds = self.detailScrollView.bounds
                    
                    var scrollViewInsets = UIEdgeInsets.zero
                    scrollViewInsets.top = scrollViewBounds.size.height
                    scrollViewInsets.top -= self.ContentView.bounds.size.height-30
                    
                    scrollViewInsets.bottom = scrollViewBounds.size.height+10
                    scrollViewInsets.bottom -= self.ContentView.bounds.size.height
                    scrollViewInsets.bottom += 1
                    print(self.ContentViewConstraint)
                    
                    
                    self.ContentViewConstraint.constant = self.detailScrollView.frame.size.height-250
                    let htmlString =  NSString(format: "<html><style type=\"text/css\"> \n body {font-size: 16;}\n</style> \n<body>%@</body></html>",(self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "long_description") as! String);
                    
                    self.webView.loadHTMLString(htmlString as String , baseURL: nil)
                    self.webView.backgroundColor = UIColor.clear
                    self.webView.isOpaque=false
                    
                    LazyImage.showForImageView(self.DetailImgView!, url: (self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "featured_image") as? String, defaultImage: "detail_placeholder.png")
                    
                    if(self.imageArr.count>0)
                    {
                        self.addThumbNailImage()
                    }
                     // Update view count in background thread
                    self.UpdateViewCountinBackground()
                }
            }
        }
        
    }
    /*!
     @brief if app coming from background then this notifcation method  will add BanerAdViewController on this controller
     */
    func AddBanner(_ notification: Notification) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let presentedViewController = appDelegate.mainNavigationController?.visibleViewController
        
        if  presentedViewController!.isKind(of: BlogDetailViewController.self)
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
     @brief This method is used for, if app font will change then this notification will change the font this viewController
     
     */
    func changeFont(_ notification: Notification) {
        globalFont.setFont()
        self.viewDidLoad()
    }
    /*!
     @brief This method used to small adbanner view in viewController
     */
    func ShowAdvertismentView()  {
        
        UIView.animate(withDuration: 3.0, animations: {
            self.adsview.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 44.0, width: UIScreen.main.bounds.size.width, height: 44)
        })
        
    }
    /*!
     @brief This method  ChangeImages in AdsView
     */
    func ChangeImage()
    {
        if(advertismentArr.count>0)
        {
            let randomIndex = Int(arc4random_uniform(UInt32(advertismentArr.count)))
            // Get a random item
            let randomItem = advertismentArr[randomIndex] /*!@brief  get random images from advertismentArr */
            LazyImage.showForImageView(adsview.addsImgView, url: (randomItem as! NSDictionary).object(forKey: "image") as? String)
            adsview.URlStr = (randomItem as! NSDictionary).object(forKey: "url") as! String
        }
    }
    /*!
     @brief This method  is called when view will viewWillDisappear
     */
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    /*!
     @brief This method  is used to add custom Badge on UIButton
     */
    
    func  addBadgeForViewCount()  {
        
        let mkbadge : MKNumberBadgeView = MKNumberBadgeView.init(frame: CGRect(x: 8, y: -20, width: 50, height: 50))
        mkbadge.fillColor = UIColor.red
        mkbadge.hideWhenZero = false
        mkbadge.isHidden = false
        mkbadge.value = UInt( (self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "total_view_count") as! String)!
        ViewCountBtn .addSubview(mkbadge)
    }
    /*!
     @brief This method  is used to Added ThumbNail images in Scrollview
     */
    
    func addThumbNailImage()
    {
        print(imageArr.count)
        var x : CGFloat = 0
        for i in 0 ..<  imageArr.count
        {
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRect(x: x, y: 0, width: 100, height: 100));
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 0.5
            imageView.tag=100+i
            LazyImage.showForImageView(imageView, url: (imageArr .object(at: i) as! NSDictionary).object(forKey: "image_thumb") as! String)
            ImageScrollView.addSubview(imageView)
            x=x+10+imageView.frame.size.width
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(NewsDetailViewController.imageTapped(_:)))
            imageView.addGestureRecognizer(tapGestureRecognizer)
            
        }
        let int: Int = imageArr.count
        let imageCount = CGFloat(int)
        ImageScrollView.contentSize = CGSize(width: 500 as CGFloat, height: 100)
    }
    /*!
     @brief Image tapAction
     */
    func imageTapped(_ sender: UITapGestureRecognizer? = nil)
    {
        let imgtag = (sender?.view?.tag)! as Int
        FullView.frame = CGRect(x: 0, y: 0, width: detailScrollView.frame.size.width, height: detailScrollView.frame.size.height)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(FullView)
        LazyImage.showForImageView(FulImgView, url: (imageArr .object( at: imgtag - 100) as! NSDictionary).object(forKey: "image") as! String)
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(NewsDetailViewController.CloseimageTapped(_:)))
        FulImgView.addGestureRecognizer(tapGestureRecognizer)
        print("imageFound")
    }
    /*!
     @brief This method is used for close largeImageView
     */
    @IBAction func CloseBtn_Action(_ sender: AnyObject) {
        FullView .removeFromSuperview()
    }
    func CloseimageTapped(_ img: AnyObject)
    {
        FullView .removeFromSuperview()
    }
    /*!
     @brief This method is used add AuthorView in ScrollView
     */
    func addAuthor()
    {
        
        AuthorView.frame = CGRect(x: 0, y: yxis, width: detailScrollView.frame.size.width,height: 120 )
        detailScrollView .addSubview(AuthorView);
        authorNameLB?.text=(newsDetailArr .object(at: 0) as! NSDictionary).object(forKey: "author_name") as? String
        authorDescriptionLB?.text=(newsDetailArr .object(at: 0) as! NSDictionary).object(forKey: "author_description") as? String
        LazyImage.showForImageView(authorImgView, url: (newsDetailArr .object(at: 0) as! NSDictionary).object(forKey: "author_image") as? String)
        
        
    }
    /*!
     @brief UIWebView Delegate
     */
   
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        webView.frame.size = webView.sizeThatFits(CGSize.zero)
        webView.scrollView.isScrollEnabled = false;
        var frame = webView.frame;
        frame.size.width = self.view.frame.width-20;       // Your desired width here.
        frame.size.height = 1;        // Set the height to a small one.
        webView.frame = frame;       // Set webView's Frame, forcing the Layout of its embedded scrollView with current Frame's constraints (Width set above).
        frame.size.height = webView.scrollView.contentSize.height;  // Get the corresponding height from the webView's embedded scrollView.
        webView.frame = frame;
        fl = webView.frame.size.height // save the height of webview content variable
        detailScrollView.contentSize = CGSize(width: self.view.frame.width, height: 600+fl )
        
       
        if imageArr.count>0 {
            
            ImageView.frame = CGRect(x: 10, y: webView.frame.size.height+webView.frame.origin.y+10,width: self.view.frame.width-20,height: 100)
            detailScrollView .addSubview(ImageView)
            yxis = ImageView.frame.origin.y+ImageView.frame.height+10
            print(yxis)
            
            self.addAuthor()
        }
        else
        {
            yxis = webView.frame.origin.y+webView.frame.height+10
            self.addAuthor()
        }
        
        
        
    }
    
    /*!
     @brief UIWebView Delegate
     */
    func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked{
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    
    /*!
     @brief viewDidLayoutSubviews
     */
    override func viewDidLayoutSubviews()
    {
        let scrollViewBounds = detailScrollView.bounds
        let containerViewBounds = ContentView.bounds
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height/2.0;
        scrollViewInsets.top -= ContentView.bounds.size.height/2.0;
        
        scrollViewInsets.bottom = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= ContentView.bounds.size.height/2.0;
        scrollViewInsets.bottom += 1
        
        detailScrollView.contentInset = scrollViewInsets
        self.activityView.container.center = self.view.center
    
        detailScrollView.contentSize = CGSize(width: self.view.frame.width, height: 400+fl )
        if(imageArr.count>0)
        {
            detailScrollView.contentSize = CGSize(width: self.view.frame.width, height: 400+fl+300 )
        }
        else
        {
            detailScrollView.contentSize = CGSize(width: self.view.frame.width, height: 400+fl+150 )
        }
        
        let scrollViewBounds1 = ImageScrollView.bounds
        let containerViewBounds1 = imageContentView.bounds
        
        var scrollViewInsets1 = UIEdgeInsets.zero
        scrollViewInsets1.top = scrollViewBounds1.size.width/2.0;
        scrollViewInsets1.top -= imageContentView.bounds.size.width/2.0;
        
        scrollViewInsets1.bottom = scrollViewBounds1.size.width/2.0
        scrollViewInsets1.bottom -= imageContentView.bounds.size.width/2.0;
        scrollViewInsets1.bottom += 1
        
        ImageScrollView.contentInset = scrollViewInsets1
        let int: Int = imageArr.count
        let imageCount = CGFloat(int)
        ImageScrollView.contentSize = CGSize(width: imageCount * 110 + 10 as CGFloat, height: 100)
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*!
     @brief Save Article Button action
     */
    @IBAction  func saveArticleBtn()
    {
        let prefs = UserDefaults.standard
        
        if((prefs.object(forKey: "Auth_key")) == nil)
        {
            
            self.view.makeToast(globalData.setLanguageForKey("Saved_Article_error") as String, duration: 1.0, position: CSToastPositionCenter)
        }
        else
        {
            
            if(articleBtn.isSelected==false)
            {
                articleBtn.isSelected=true
                
                self.SaveArticleParser((newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "id")  as! NSString, save: "1")
            }
            else
            {
                articleBtn.isSelected=false
                self.SaveArticleParser((newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "id") as! NSString, save: "0")
                
                
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateView"), object:(self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "id") as! String)
        }
        
    }
    /*!
     @brief This method called Save Article API in background thread
     */
    func SaveArticleParser(_ postID:NSString , save:NSString)
    {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            print("This is run on the background queue")
            let reachability : Reachability = Reachability.forInternetConnection()// check internet connection
            let internetStatus : NetworkStatus
            internetStatus = reachability.currentReachabilityStatus()
            if  internetStatus != NotReachable {
                if let responseDict=WebParser.savedArticle("3", post: postID as String, saved: save as String)
                {
                    if(responseDict.count>0)
                    {
                        let userPerfs = UserDefaults.standard
                        userPerfs.set((responseDict.object(forKey: "data") as! NSDictionary).object(forKey: "saved_article_count") as! String, forKey: "save_article_Count")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshMenuView"), object: nil)
                        
                        
                    }
                }
    
            }
            DispatchQueue.main.async(execute: { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshMenuView"), object: nil)
            
            })
        })
        
        
    }
    /*!
     @brief This method called  for ShareViewController
     */
    @IBAction func ShareBtn()
    {
        shareVC = ShareViewController(nibName: "ShareViewController", bundle: nil)
        shareVC.NewsImage = (self.DetailImgView?.image)!
        shareVC.TitleStr = ((self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "title") as? NSString)!
        shareVC.featureImageURL =  ((self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "featured_image") as? NSString)!
        shareVC.DescriptionStr = ((self.newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "short_description") as? NSString)!
        shareVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height);
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(shareVC.view)
    }
    /*!
     @brief This method is used for Comment
     */
    @IBAction  func commentBtn()
    {
        let NewsCommentVC = NewsCommentViewController(nibName: "NewsCommentViewController", bundle: nil)
        NewsCommentVC.title=globalData.setLanguageForKey("Comment") as String
        NewsCommentVC.postID = (newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "id") as! NSString
        if(((newsDetailArr .object(at: 0) as! NSDictionary).object(forKey: "comment") as! NSArray).count>0)
        {
            NewsCommentVC.commentArr = (newsDetailArr .object(at: 0) as! NSDictionary).object(forKey: "comment") as! NSMutableArray
        }
        NewsCommentVC.post_Type = "3"
        self.navigationController?.pushViewController(NewsCommentVC, animated: true)

    }
    
    /*!
     @brief This method called for get Blog Detail API and prase data
     */
    func ParseBlogDetailData(_ news_ID:String )
    {
        
        let reachability : Reachability = Reachability.forInternetConnection()
        let internetStatus : NetworkStatus
        internetStatus = reachability.currentReachabilityStatus()
        if  internetStatus != NotReachable {
            //let pareser : NSMutableDictionary
            if let newsDetailData=WebParser.blogsDetail(news_ID, language:"en")
            {
                if((newsDetailData.object(forKey: "data") as! NSDictionary).object(forKey: "status") as! String == "200")
                {
                    DispatchQueue.main.async { () -> Void in
                        self.advertismentArr = NSMutableArray.init(array: ((newsDetailData.object(forKey: "data") as! NSDictionary).object(forKey: "advertisement")) as! NSArray)
                        self.BigAdvertisment_url =  ((newsDetailData.object(forKey: "data") as! NSDictionary).object(forKey: "big_advertisement_url")) as! String
                        self.BigAdvertisment_image = ((newsDetailData.object(forKey: "data") as! NSDictionary).object(forKey: "big_advertiesment")) as! String
                        if(((newsDetailData.object(forKey: "data") as! NSDictionary).object(forKey: "is_save_article")) as! String == "1")
                        {
                            self.articleBtn.isSelected=true
                        }
                    }
                    newsDetailArr = NSMutableArray.init(array: (newsDetailData.object(forKey: "data") as! NSDictionary).object(forKey: "result") as! NSArray)
                    if(((newsDetailArr .object(at: 0) as! NSDictionary).object(forKey: "images") as! NSArray).count>0)
                    {
                        
                        imageArr = NSMutableArray.init(array: (newsDetailArr .object(at: 0) as! NSDictionary).object(forKey: "images") as! NSArray)
                    }
                    
                }
                else
                {
                    DispatchQueue.main.async { () -> Void in
                        self.view.makeToast(newsDetailData.object(forKey: "message") as! String, duration: 0.6, position: CSToastPositionCenter)
                    }
                    
                }
            }
            else
            {
                DispatchQueue.main.async { () -> Void in
                    self.view.makeToast("No response found", duration: 0.6, position: CSToastPositionCenter)
                }
            }
        }

    }
    /*!
     @brief This method called for Update View Count api in background thread
     */
    func UpdateViewCountinBackground()
    {
        let magazinieID = (newsDetailArr.object(at: 0) as! NSDictionary).object(forKey: "id") as! String
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            print("This is run on the background queue")
            let reachability : Reachability = Reachability.forInternetConnection()
            let internetStatus : NetworkStatus
            internetStatus = (reachability.currentReachabilityStatus)()
            if  internetStatus != NotReachable{
                
                if let respnseDict=WebParser.addViewCountPerPage(magazinieID as String, post: "3")
                {
                    print(respnseDict)
                    
                    
                }
                
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                print("This is run on the main queue, after the previous code in outer block")
                
            })
        })
    }
    
 
    
}
