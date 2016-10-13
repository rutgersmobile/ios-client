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
        self.dataSource = DynamicDataSource.init(channel:  self.channel as! [NSObject : AnyObject] , forLayout: true)
       
        
        
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



extension AthleticsHomeScreenCollectionViewController : UIPageViewControllerDataSource , UIPageViewControllerDelegate
{
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return nil;
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nil;
    }
}



class BannerImage : UIViewController
{
    let image : UIImage;
    
    init(image : UIImage)
    {
        self.image = image ;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView : UIImageView = UIImageView(image: UIImage(named: <#T##String#>));
    override func viewDidLoad() {
        
        
        
    }
}




class BannerCell : UICollectionViewCell
{
    let pageViewController = UIPageViewController.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // set the data source for the pageViewController to be the AtheleticHomeScreen , keep the design simple for now
      
        self.pageViewController.dataSource = AthleticsHomeScreenCollectionViewController.self as! UIPageViewControllerDataSource
        self.pageViewController.delegate = AthleticsHomeScreenCollectionViewController.self as! UIPageViewControllerDelegate
       
        setupViews()
          
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews()
    {
        self.pageViewController.view.frame = self.contentView.bounds
        
        self.contentView.addSubview(self.pageViewController.view)
    }
    
}





