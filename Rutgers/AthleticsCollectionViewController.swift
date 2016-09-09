//
//  AthleticsCollectionViewController.swift
//  Rutgers
//
//  Created by scm on 8/30/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell_Atheletics"

/*
    Add image chaching mechanism to the Reader Data Source
 */
extension  RUReaderDataSource : UICollectionViewDelegate
{
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.numberOfSections
    }
    
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.numberOfItemsInSection(section)
    }
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AthleticsCollectionViewCell
        
        let item : RUReaderItem = self.itemAtIndexPath(indexPath) as! RUReaderItem ;
        
        
        // get the image in a sepereate thread and fill it in
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
        {
            let imageData : NSData? = NSData(contentsOfURL: item.imageURL)
            
            dispatch_async(dispatch_get_main_queue())
            {
                // Update the UI
                cell.schoolIcon.contentMode = .ScaleAspectFit
                cell.schoolIcon.image = UIImage(data: imageData!)!
            }
        }
        
        
        // if Rutgers is home
        if(item.isRuHome)
        {
            cell.homeScore.text = String(item.ruScore)
            cell.homeScore.textColor = UIColor.redColor()
            cell.awayScore.text = String(item.otherScore)
        }
        else
        {
            cell.awayScore.text = String(item.ruScore)
            cell.awayScore.textColor = UIColor.redColor()
            cell.homeScore.text = String(item.otherScore)
        }
        
        // if Ru won
        if(item.ruWin)
        {
            cell.sideIndicator.backgroundColor = UIColor.redColor()
        }
        else
        {
            cell.sideIndicator.backgroundColor = UIColor.grayColor()
        }
        
        
        cell.locationLabel.text = item.descriptionText
        cell.dateTimeLabel.text = item.dateString
        cell.schoolNameLabel.text = item.title
        
        // set the shadow
        
        /*
         self.viewBg!.layer.shadowOffset = CGSizeMake(0, 0)
         self.viewBg!.layer.shadowColor = UIColor.blackColor().CGColor
         self.viewBg!.layer.shadowRadius = 4
         self.viewBg!.layer.shadowOpacity = 0.25
         self.viewBg!.layer.masksToBounds = false;
         self.viewBg!.clipsToBounds = false;
         */
        
        
        cell.layer.shadowOffset = CGSizeZero;
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        cell.layer.shadowRadius = 4.0;
        cell.layer.shadowOpacity = 0.5;
        cell.layer.masksToBounds = false;
        
        return cell
    }
    
    

    
    
}


class AthleticsCollectionViewController: UICollectionViewController ,UICollectionViewDelegateFlowLayout ,RUChannelProtocol
{
    var dataSource : RUReaderDataSource! = nil
    var channel : NSDictionary! = nil
    var activityIndicator : UIActivityIndicatorView! = nil
   
    /// Conform to RUChannelProtocol
    static func channelHandle() -> String!
    {
        return "Athletics"
    }
    
    static func registerClass()
    {
        RUChannelManager.sharedInstance().registerClass(AthleticsCollectionViewController.self)
    }
    
    static func channelWithConfiguration(channel : [NSObject : AnyObject]!) -> AnyObject!
    {
        //   let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        return AthleticsCollectionViewController(channel: channel) // load the view for the controller from the nib file
    }
   
    init(channel : [NSObject : AnyObject]!)
    {
        self.channel = channel ;
        super.init(nibName: "AthleticsCollectionViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        self.collectionView!.registerNib(UINib.init(nibName: "AthleticsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        

        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsetsMake(18, 10 , 18, 10 )
        layout.minimumLineSpacing = 18 ;
        layout.minimumInteritemSpacing = 18 ;
        self.collectionView!.setCollectionViewLayout(layout, animated: true)
        

        
       // get the url to visit
        let atheleticsUrl = "sports/\(self.channel["data"]!).json"
        self.dataSource = RUReaderDataSource.init(url: atheleticsUrl)
        
        self.dataSource.loadContentWithAnyBlock
            {
                dispatch_async(dispatch_get_main_queue()) // call reload on main thread otherwise veryt laggy
                {
                    self.collectionView!.reloadData()
                    self.collectionView!.layoutIfNeeded()
                    self.activityIndicator.stopAnimating()
                }
        }
       
        self.collectionView?.dataSource = self.dataSource
       // Add notification to handle rotate of the app .. 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AthleticsCollectionViewController.didRotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }

    // MARK: Flow Layout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // deteremine the cell hieght based on the orientation and device ..
        
        var cellHeight : CGFloat?
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        if(orientation == .LandscapeLeft || orientation == .LandscapeRight)
        {
            cellHeight = (self.collectionView?.bounds.height)! / 3 ;
        }
        else
        {
            cellHeight = (self.collectionView?.bounds.height)! / 5 ;
        }
        
        return CGSizeMake(  (self.collectionView?.bounds.size.width)! - 20 , cellHeight! ) ;
    }
   
   
    func didRotate()
    {
        print("rotate")
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}
