//
//  DynamicCollectionViewController.swift
//  Rutgers
//
//  Created by scm on 8/25/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

private let reuseIdentifier = "Cell"

 
    // use the collection view to display both the banner as well as the cells
class DynamicCollectionViewController: UICollectionViewController, RUChannelProtocol, UICollectionViewDelegateFlowLayout {

    var dataSource : DynamicDataSource! = nil
    var channel : NSDictionary! = nil
    // the indicator to show before the data is loaded..
    var activityIndicator : UIActivityIndicatorView! = nil
    var  bannerImageNames : [String]?
    
   /// Conform to RUChannelProtocol
    static func channelHandle() -> String!
    {
        return "dtable-grid"
    }
   
    static func registerClass()
    {
        RUChannelManager.sharedInstance().registerClass(DynamicCollectionViewController.self)
    }
   
    static func channelWithConfiguration(channel : [NSObject : AnyObject]!) -> AnyObject!
    {
        return DynamicCollectionViewController(channel: channel) // load the view for the controller from the nib file
    }

    init(channel : [NSObject : AnyObject]!)
    {
        self.channel = channel
        
        self.bannerImageNames = self.channel?["banner"] as? [String]
        
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
     
        
        self.collectionView!.registerNib(UINib.init(nibName: "DynamicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.scrollDirection = .Vertical
        layout.itemSize = CGSize(width: 150, height: 150);
        layout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5)
        
        self.collectionView?.dataSource = self;
        self.collectionView?.delegate = self ;
     
        self.collectionView!.setCollectionViewLayout(layout, animated: true)
        
           self.dataSource = DynamicDataSource.init(channel:  self.channel as! [NSObject : AnyObject] , forLayout: true)
        /*
 
            The data source is not used directly by the collection View for now .. 
            The view controller acts as a wrapper between the actual collection view and the data source
 
         */
        
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
        
        // Register cell classes
       // self.collectionView!.registerClass(DynamicCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
            return self.dataSource.numberOfSections
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
           return self.dataSource.numberOfItemsInSection(section)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let halfWidth = (self.collectionView?.bounds.width)! / 2
        let reducedSize = halfWidth - 10
        return CGSizeMake(reducedSize, reducedSize)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DynamicCollectionViewCell
        //cell.backgroundColor = UIColor.blueColor();

        let item : NSDictionary = (self.dataSource.itemAtIndexPath(indexPath) as! NSDictionary)

        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 5
        cell.title.attributedText = NSAttributedString(
            string: item.channelTitle,
            attributes: [NSParagraphStyleAttributeName: style]
        )
        //cell.title.lineBreakMode  = .ByWordWrapping
        //cell.title.numberOfLines = 0
        if let imageLocation = item["image"] as? String {
            let imageUrlString = RUNetworkManager.baseURL().absoluteString! + "img/" + imageLocation
            let imageUrl = NSURL(string: imageUrlString)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
            {
                let imageData : NSData? = NSData(contentsOfURL: imageUrl!)
                
                dispatch_async(dispatch_get_main_queue())
                {
                    // Update the UI
                    cell.imageView.contentMode = .ScaleAspectFit
                    cell.imageView.image = UIImage(data: imageData!)!
                }
            }
        }
        
        //cell.layer.borderColor = UIColor.blackColor().CGColor
        //cell.layer.borderWidth = 5 ;
        //cell.layer.cornerRadius = 8 
        cell.layer.cornerRadius = 5
        
        // implement using swift for learning purposes
        return cell
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool
     {
        return true
     }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
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
