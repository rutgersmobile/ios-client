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



class AthleticsHomeScreenCollectionViewController: UICollectionViewController  ,UICollectionViewDelegateFlowLayout,  RUChannelProtocol{
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
        return "dtable"
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
        return self.dataSource.numberOfItemsInSection(section)
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
        
            // Create a array of UIViewControllers that page view controller will use to display its data
            // Putting a UiViewContoller seems weird but that page view controller needs an array of view controller not views
            var pageVC:[UIViewController] = []
            for index in 0..<5
            {
                let bm =  BannerImage.init(image: UIImage(named: "ru_banner_1")! , frame: cell.frame , index: index)
                pageVC.append(bm)
            }
       
            cell.viewControllersInPage = pageVC
       
            cell.setupViews()
        
            return cell;
        
       }
        else
       {
        
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewElem, forIndexPath: indexPath) as! DynamicCollectionViewCell
            //cell.backgroundColor = UIColor.blueColor();
            
            let item : NSDictionary = (self.dataSource.itemAtIndexPath(indexPath) as! NSDictionary)
            
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







class BannerImage : UIViewController
{
    let image : UIImage;
    let imageView : UIImageView ;
    let superViewFrame : CGRect ;
    let index : Int;
    
    
    init(image : UIImage , frame : CGRect , index : Int)
    {
        self.image = image ;
        self.superViewFrame = frame ;
        imageView = UIImageView(frame: superViewFrame)
        
        // make the image fit the view
        UIGraphicsBeginImageContext(CGSizeMake(self.imageView.frame.width, self.imageView.frame.height))
        let imageRect = imageView.bounds
        self.image.drawInRect(imageRect)
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        // set index of the image for tracking in the page view controller
        self.index = index
        
        
        super.init(nibName: nil, bundle: nil)
    }
  
    /*
        The super view of this  view should set the frame of the this view view controller for it to show up properly
     */
    override func loadView()
    {
        self.view = UIView.init(frame: CGRectZero)
        self.view.frame = self.superViewFrame
        self.imageView.frame = self.view.frame
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        
        self.view.addSubview(imageView)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false ;
        NSLayoutConstraint.constraintsWithVisualFormat("H:|[imv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil , views: ["imv" : imageView])
        NSLayoutConstraint.constraintsWithVisualFormat("V:|[imv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil , views: ["imv" : imageView])
        
        self.view.layoutIfNeeded()
        
    }
}




class BannerCell : UICollectionViewCell
{
    let pageViewController = UIPageViewController.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    var viewControllersInPage : [UIViewController] = []
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // set the data source for the pageViewController to be the AtheleticHomeScreen , keep the design simple for now
        self.pageViewController.dataSource = self as UIPageViewControllerDataSource
        self.pageViewController.delegate = self as UIPageViewControllerDelegate
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews()
    {
        self.contentView.backgroundColor = UIColor.clearColor()
        self.pageViewController.view.frame = self.contentView.frame
      
        self.pageViewController.setViewControllers([viewControllersInPage[0]], direction: .Forward, animated: true, completion: nil)
      // add constaints on the pageViewController view so that it lies inside
        
        
        
        self.contentView.addSubview(self.pageViewController.view)
    }
    
    
}


extension BannerCell : UIPageViewControllerDataSource , UIPageViewControllerDelegate
{
    // implement these two to get the dots 
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.viewControllersInPage.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let bm : BannerImage = viewController as! BannerImage
        var vcIndex : Int = bm.index
       
        vcIndex += 1;
        
        if(vcIndex == self.viewControllersInPage.count) // if at the zero index , the no more vc to show
        {
            return nil ;
        }
       
        return self.viewControllersInPage[vcIndex];
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let bm : BannerImage = viewController as! BannerImage
        var vcIndex : Int = bm.index
       
        if(vcIndex == 0) // if at the zero index , the no more vc to show
        {
            return nil ;
        }
       
        vcIndex -= 1;
        
        return self.viewControllersInPage[vcIndex];
    }
}


