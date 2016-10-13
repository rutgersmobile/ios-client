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
 
    // use the collection view to display both the banner as well as the cells
    
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource : DynamicDataSource! = nil
    var channel : NSDictionary! = nil
    var activityIndicator : UIActivityIndicatorView! = nil
   /// Conform to RUChannelProtocol
    static func channelHandle() -> String!
    {
        return "dtable.temp"
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
        self.channel = channel ;
        super.init(nibName: "DynamicCollectionViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {

        super.viewDidLoad()
        self.dataSource = DynamicDataSource.init(channel:  self.channel as! [NSObject : AnyObject] , forLayout: true)
        
        self.navigationController?.view.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        let hConstraintView = NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v0" : self.view])
        let vConstraintView = NSLayoutConstraint.constraintsWithVisualFormat("V:|[v0]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v0" : self.view])
        
        self.navigationController?.view.addConstraints(hConstraintView)
        self.navigationController?.view.addConstraints(vConstraintView)
        self.navigationController?.view.layoutIfNeeded()
       
        
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
        self.collectionView?.dataSource = self;
        self.collectionView?.delegate = self ;
       
        self.collectionView!.registerNib(UINib.init(nibName: "DynamicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
      
        // set up the view constraints
        
        self.view.addSubview(self.collectionView!)
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        // try to set up constraints on the collection view 
        self.collectionView?.backgroundColor = UIColor.blueColor()
        
        let hConstraintCollectionView = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView" : collectionView])
        
        let vConstraintCollectionView = NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView" : collectionView])

       // let verticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView(>=0)]|", options: .AlignAllCenterY, metrics: nil, views: views)
        self.view.addConstraints(hConstraintCollectionView)
        self.view.addConstraints(vConstraintCollectionView)
      //  self.view.layoutIfNeeded()
  
       
        
        
        
        print(self.collectionView?.frame)
        print(self.view.frame)
        
        
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
