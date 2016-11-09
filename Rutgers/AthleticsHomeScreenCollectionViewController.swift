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

