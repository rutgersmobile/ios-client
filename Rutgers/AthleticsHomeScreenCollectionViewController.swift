//
//  AthleticsHomeScreenCollectionViewController.swift
//  Rutgers
//
//  Created by scm on 10/7/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import UIKit
/*
    Will function as the collection view in the atheelics home page . Where there are two cells .
 */


private let viewElem = "squ"
private let bannerElem = "banner"



class AthleticsHomeScreenCollectionViewController: UICollectionViewController  ,UICollectionViewDelegateFlowLayout,  RUChannelProtocol
{
    var dataSource : DynamicDataSource! = nil
    var channel : NSDictionary! = nil
    var activityIndicator : UIActivityIndicatorView! = nil
  
    var imagesInBanner = 5;
    
    
    let flowLayout : UICollectionViewFlowLayout =
    {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(18, 10 , 18, 10 )
        layout.minimumLineSpacing = 18 ;
        layout.minimumInteritemSpacing = 18 ;
        return layout
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.dataSource = DynamicDataSource.init(channel:  self.channel as [NSObject : AnyObject] , forLayout: true)
       
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
        // set the data source and the delegate for the collection view
        self.collectionView?.delegate = self ;
        self.collectionView?.dataSource = self;
        
        // Indicator to be showed within the main collectoin view
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerNib(UINib.init(nibName: "DynamicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: viewElem)
        self.collectionView!.registerClass(BannerCell.self, forCellWithReuseIdentifier: bannerElem)
        
        self.dataSource.loadContentWithAnyBlock
        {
            dispatch_async(dispatch_get_main_queue()) // call reload on main thread otherwise veryt laggy
            {
                self.collectionView!.reloadData()
                self.view.layoutIfNeeded()
                self.collectionView!.layoutIfNeeded()
                self.activityIndicator.stopAnimating()
            }
            
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    /// Conform to RUChannelProtocol
    static func channelHandle() -> String!
    {
        return "athletics"
    }
    
    static func registerClass()
    {
        RUChannelManager.sharedInstance().registerClass(AthleticsHomeScreenCollectionViewController.self)
    }
    
    static func channelWithConfiguration(channel : [NSObject : AnyObject]!) -> AnyObject!
    {
        return AthleticsHomeScreenCollectionViewController(channel: channel) // load the view for the controller from the nib file
    }
    
    init(channel : [NSObject : AnyObject]!)
    {
        self.channel = channel ;
        super.init(collectionViewLayout: self.flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return self.dataSource.numberOfSections
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.dataSource.numberOfItemsInSection(section) + 1  // for the banner
    }
   
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        var cellWidth:CGFloat = 0 ;
        var cellSize:CGSize ;
        
        let screenWidth = self.collectionView?.frame.width
        
        if(indexPath.row == 0)
        {
            let aspectRatio:CGFloat = 0.8 ;  // the height will be (value) more than the width
            cellWidth = (screenWidth! - 20 );
            cellSize = CGSizeMake( cellWidth, cellWidth * aspectRatio)
        }
        else
        {
            let aspectRatio:CGFloat = 1.2 ;  // the height will be (value) more than the width
            cellWidth = (screenWidth! ) / 2.5;
            cellSize = CGSizeMake( cellWidth, cellWidth * aspectRatio)
        }
       
        
        return cellSize
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        
       if(indexPath.row == 0 ) // the zeroth index is the banner
       {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bannerElem, forIndexPath: indexPath) as! BannerCell
            cell.layer.borderColor = UIColor.blueColor().CGColor
            cell.layer.borderWidth = 2
            cell.layer.cornerRadius = 8
             // The cell will keep showing the activity view until the images are loaded from the urls
        
            // pass in the urls for the images and the cell will load it in the background
            let simURLS : [String] = ["http://www.rutgers.edu/sites/default/files/styles/home_featuredbreakpoints_theme_uwide_wide_1x/public/featured_images/UW_RevThinking_hp.png" ,
                                    "http://news.rutgers.edu/sites/medrel/files/inline-img/groupshot400.jpg",
                                    "http://www.rutgers.edu/sites/default/files/styles/home_featuredbreakpoints_theme_uwide_wide_1x/public/featured_images/UW_ss_268287005_hp.png",
                                    "http://www.camden.rutgers.edu/sites/camden/files/styles/ru_homepage_feature/public/callout-golf.png",
                                    "http://republicbuzz.com/wp-content/uploads/2016/05/20160516/428467_160515152619-obama-rutgers-large-169.jpg"
                                 ]
            cell.loadImagesForUrlStrings(simURLS)
            return cell;
        
       }
        else
       {
        
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewElem, forIndexPath: indexPath) as! DynamicCollectionViewCell
            //cell.backgroundColor = UIColor.blueColor();
       
            let indexForDict : NSIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        
            let item : NSDictionary = (self.dataSource.itemAtIndexPath(indexForDict) as! NSDictionary) // accout for the banner being added at the to
            
            cell.title.text = item.channelTitle
            cell.title.lineBreakMode  = .ByWordWrapping
            cell.title.numberOfLines = 0
            
            cell.layer.borderColor = UIColor.blackColor().CGColor
            cell.layer.borderWidth = 5 ;
            cell.layer.cornerRadius = 8
        
        
        
        
            return cell
            
        }
       
    }
    
 
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let item:NSDictionary = self.dataSource.itemAtIndexPath(indexPath) as! NSDictionary
        
        var channel = item["channel"]
        
        if ((channel == nil))
        {
            channel = item ;
        }
        
        let vc : UIViewController = RUChannelManager.sharedInstance().viewControllerForChannel(channel as! [NSObject : AnyObject]!)
        
        if( (channel!.channelTitle == nil) && (item.channelTitle != nil))
        {
            vc.title = item.channelTitle
        }
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


// loads the banner images for now
class BannerCellDataSource : NSObject
{
    
    //TODO : use seperate contrainers for the stirng and images to prevent the copy of strings being used as dict keys
    
    var strImages : [String]? // since the images are kept in a dict , we cannot keep the order of the images. That is display the images in the same order as on the server
                            // So to index the dict by number ,we keep an array of strings with the same ordering as present in the server .
                            // now index by number into the strImages , obtain the string , then use it in a dict to extract the image
    
    var cachedImages : [String : UIImage]? // create a cache of the images that are loaded are the network request
   
    override init() // do the initial setup
    {
        cachedImages = [String : UIImage]()
    }
   
    
    /*
        Expensive call , as needs to acces kernel space for the lock
        Use a serial dispatch queue to ensure that the blocks are exectued in serial
     */
    func synchronized(lock: AnyObject , block:() throws -> Void ) rethrows
    {
        objc_sync_enter(lock)
        defer // ensures that even if the block causes an exception , the lock is removed
        {
            objc_sync_exit(lock)
        }
        try block()
    }
    
    
    // load the images from the url strings , then call the callback ..
    // the call back will be done in a main thread , so it should only be ued to update UIElements
    func loadImagesFromUrlStrings( array : [String] , callbackUIUpdate : (Bool) -> Void)
    {
        // set the strImages for indexing into array
        self.strImages = array
        
        let imageCacheAccessQueue : dispatch_queue_t = dispatch_queue_create("com.rutgers.imageCacheQueue", nil) // just setting a name for the queue to be used when we profile
        
        // the group is created so that the ui update can be done at the proper time
        // After every block that has been added to the group has been executed , we will use the group notify to run the uiupdate . Ensures that ui is updated only after all the data has been obtained
        let imageDownloadGroup : dispatch_group_t = dispatch_group_create()
        
        
        for imageStr  in array // iterate through each image string in the array and create a nsurlsession for each and load them
        {
            guard cachedImages![imageStr] == nil else
            {
                continue
            }
            // if the image is not present then load the image from the url , else continue and move to next step
            
            // enter the group
            dispatch_group_enter(imageDownloadGroup)
            
            let imageUrl = NSURL.init(string: imageStr)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(imageUrl)
            {
                ( data , let response , let error) in
                
                   if let imageData = data
                   {
                        let responseImage = UIImage(data: imageData)
                  
                        // put the blocks into a serial qeueue to ensure that the insertion into th dict happens in a thread safe manner and not having to use locks
                        // we add it to the group so that the group notify will only be called after the images has been added to the dict
                        dispatch_group_async(imageDownloadGroup, imageCacheAccessQueue)
                        {
                            self.cachedImages![imageStr] = responseImage
                        }
                   }
                    else // did not obtain the image .. Put some place holder to the image.. Or not show the banner at all ?
                   {
                    
                   }
                  
                    // leave the group
                    dispatch_group_leave(imageDownloadGroup)
            }
            
            task.resume()
           
        }
        
        dispatch_group_notify(imageDownloadGroup, dispatch_get_main_queue())
        {
                callbackUIUpdate(true) // update the ui after all the UI has been updated
        }
         
        
    }
    
    func imageAtIndex( idx : Int ) -> UIImage?
    {
        guard idx < self.numImages() else // acces index largers than the number of images so return nul
        {
            return nil
        }
        
        return cachedImages![strImages![idx]]!;
    }
   
    // keep track of the number of images in the banner
    func numImages() -> Int
    {
        return cachedImages!.count
    }
    
    
    
}






/*
 
     // TODO : DOES NOT HANDLE THE CASE WHERE THE URL IS STUPID
 
 */

// The cell containing the banner in it
class BannerCell : UICollectionViewCell , UIScrollViewDelegate
{
    var scrollView : UIScrollView?
    var pageControl : UIPageControl?
    var loadingView : UIActivityIndicatorView?
    var imagesUrls : [UIImageView]?
    var dataSource : BannerCellDataSource?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        // set up the data source used to load the images in the cell
        dataSource = BannerCellDataSource()
        
        // set the activity view to take up the entire cell bounds
        loadingView = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        loadingView?.center = self.contentView.center
        loadingView?.startAnimating() // keep on animating till the iamge has been loaded
        
        
        // set the size and pos of the scrollview inside the cell to take up the entire cell
        scrollView = UIScrollView(frame: CGRectMake(0,0,self.contentView.bounds.width, self.contentView.bounds.height))
        scrollView!.delegate = self
        
        pageControl = UIPageControl(frame: CGRectMake(0,self.contentView.bounds.height - 50 ,self.contentView.bounds.width,50))
        self.pageControl!.addTarget(self, action: #selector(BannerCell.changePage(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        
       // setupViews() // add the page view after the scorllView so that it appears on the top
        
        // add the view to the contentView 
        // the loading view is kept on top of both the scroll view and the pagecontrol
        // if the hidden when the loading has been done ... So no need to remove the view from the screen
        loadingView?.hidesWhenStopped = true 
        self.contentView.addSubview(loadingView!) 
         
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
        Pass in an array of strings and the cell will load it in the scroll view
     */
    func loadImagesForUrlStrings(strArray : [String])
    {
            dataSource?.loadImagesFromUrlStrings(strArray)
            {
                success in
                // do the loading into the view and adding to the scrollview in the main thread
                if(success)
                {
                   
                    self.loadDataFromDataSourceAndDisplay()
                }
                else
                {
                   // Do Nothing. The Spinner will keep running
                }
               
            }
    }
    
    func loadDataFromDataSourceAndDisplay()
    {
        
        self.setupViews()
        for index in 0..<self.dataSource!.numImages()
        {
            // create the proper frame to add the scrollview in
            var tempFrame = CGRectMake(0, 0, 0, 0)
            tempFrame.origin.x = self.scrollView!.frame.size.width * CGFloat(index)
            tempFrame.size = self.scrollView!.frame.size
         
            let subView = UIImageView(frame: tempFrame)
            subView.image = self.dataSource!.imageAtIndex(index)
            self.scrollView!.addSubview(subView)
        }
        self.scrollView!.contentSize = CGSizeMake(self.scrollView!.frame.size.width * CGFloat(self.dataSource!.numImages()) , self.scrollView!.frame.size.height)
    }
    
    
    func setupViews()
    {
        self.loadingView?.stopAnimating()
        self.contentView.addSubview(scrollView!) // add the scrollview to the screen
        self.scrollView!.pagingEnabled = true
        self.pageControl!.numberOfPages = (self.dataSource?.numImages())!
        self.pageControl!.currentPage = 0
        self.pageControl!.tintColor = UIColor.redColor()
        self.pageControl!.pageIndicatorTintColor = UIColor.blackColor()
        self.pageControl!.currentPageIndicatorTintColor = UIColor.greenColor()
        self.contentView.addSubview(pageControl!)
    }
    
   
    func changePage(sender: AnyObject) -> ()
    {
        let x  = CGFloat(pageControl!.currentPage) * scrollView!.frame.size.width
        scrollView!.setContentOffset(CGPointMake(x,0), animated: true)
    }
    

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl!.currentPage = Int(pageNumber)
    }

}



