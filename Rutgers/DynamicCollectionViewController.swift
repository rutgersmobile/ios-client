//
//  DynamicCollectionViewController.swift
//  Rutgers
//
//  Created by scm on 8/25/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation


private let reuseIdentifier = "Cell"

class DynamicCollectionViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout , RUChannelProtocol{
  

    var pageViewController : UIPageViewController?
    var collectionView : UICollectionView?
    var dataSource : DynamicDataSource! = nil
    var channel : NSDictionary! = nil
    var activityIndicator : UIActivityIndicatorView! = nil
   /// Conform to RUChannelProtocol
    static func channelHandle() -> String!
    {
        return "dtable"
    }
   
    static func registerClass()
    {
        RUChannelManager.sharedInstance().registerClass(DynamicCollectionViewController.self)
    }
   
    static func channelWithConfiguration(channel : [NSObject : AnyObject]!) -> AnyObject!
    {
        //   let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        return DynamicCollectionViewController(channel: channel) // load the view for the controller from the nib file
    }

    init(channel : [NSObject : AnyObject]!)
    {
        self.channel = channel ;
        super.init(nibName: "DynamicCollectionViewController", bundle: NSBundle.mainBundle())
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
     
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.scrollDirection = .Vertical
        layout.itemSize = CGSize(width: 150, height: 150);
        layout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5)
        self.collectionView = UICollectionView.init(frame: CGRectMake(0,-320, 320, 300) , collectionViewLayout: layout)
        self.collectionView?.dataSource = self;
        self.collectionView?.delegate = self ;
       
        self.collectionView!.registerNib(UINib.init(nibName: "DynamicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.view.addSubview(self.collectionView!)
       
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.view.frame = CGRectMake(0,0, 320, 300)
        self.view.addSubview((self.pageViewController?.view)!)
        
       
        // try to set up constraints on the collection view and page view
        
       /*
                Constaint horizontally
        */
        
        self.pageViewController?.view.backgroundColor = UIColor.redColor()
        self.pageViewController?.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.collectionView?.backgroundColor = UIColor.blueColor()
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = true
        
        
        let views = ["collectionView" : self.collectionView! , "pageView" : self.pageViewController!.view]
        let hConstraintCollectionView = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        

       let hConstraintPageView = NSLayoutConstraint.constraintsWithVisualFormat("H:|[pageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)

        let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView(>=0)]-(>=5)-[pageView(>=0)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
       // let verticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView(>=0)]|", options: .AlignAllCenterY, metrics: nil, views: views)
        self.view.addConstraints(hConstraintCollectionView)
        self.view.addConstraints(hConstraintPageView)
        
        self.view.addConstraints(vConstraint)
    
        
        print(self.collectionView?.frame)
        print(self.pageViewController?.view.frame)
        
        
        /*
 
            The data source is not used directly by the collection View for now .. 
            The view controller acts as a wrapper between the actual collection view and the data source
 
         */
        self.dataSource = DynamicDataSource.init(channel:  self.channel as! [NSObject : AnyObject] , forLayout: true)
        
        self.dataSource.loadContentWithAnyBlock
        {
            dispatch_async(dispatch_get_main_queue()) // call reload on main thread otherwise veryt laggy
            {
                    self.collectionView!.reloadData()
                    self.collectionView!.layoutIfNeeded()
                    self.activityIndicator.stopAnimating()
            }
  
        }
        
        // Register cell classes
       // self.collectionView!.registerClass(DynamicCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
            return self.dataSource.numberOfSections
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
           return self.dataSource.numberOfItemsInSection(section)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DynamicCollectionViewCell
        //cell.backgroundColor = UIColor.blueColor();
      
        let item : NSDictionary = (self.dataSource.itemAtIndexPath(indexPath) as! NSDictionary)
   
        cell.title.text = item.channelTitle
        cell.title.lineBreakMode  = .ByWordWrapping
        cell.title.numberOfLines = 0
        
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 5 ;
        cell.layer.cornerRadius = 8 
        
        // implement using swift for learning purposes
        
        
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
     func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
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
