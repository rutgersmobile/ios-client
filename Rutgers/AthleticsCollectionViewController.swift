//
//  AthleticsCollectionViewController.swift
//  Rutgers
//
//  Created by scm on 8/30/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell_Atheletics"


struct ImageCache
{
    var cachedImages : [String : UIImage] // create a cache of the images that are loaded are the network request
    init()
    {
        cachedImages = [String : UIImage]()
    }
    func getImage(named : String) -> UIImage?
    {
        return cachedImages[named]
    }
    
    mutating func setImage(named: String , image : UIImage)
    {
        cachedImages[named] = image;
    }
    
}



/*
    Add image chaching mechanism to the Reader Data Source
 */
extension  RUReaderDataSource : UICollectionViewDelegate
{
    
    // MARK: UICollectionViewDataSource
    
    

    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.numberOfSections
    }
    
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.numberOfItems(inSection: section)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! AthleticsCollectionViewCell
        
        let item : RUReaderItem = self.item(at: indexPath) as! RUReaderItem ;
        
        var cache : ImageCache = ImageCache()
        // get the image in a sepereate thread and fill it in later
        DispatchQueue.global(qos: .background).async {
            var image : UIImage?

            
            if( item.imagePresent)
            {
                if let cachedImage = cache.getImage(named: item.imageURL.absoluteString)
                {
                    image = cachedImage
                }
                else
                {
                    let imageData : NSData? = NSData(contentsOf: item.imageURL)
                    image = UIImage(data: imageData! as Data)
                    cache.setImage(named: item.imageURL.absoluteString, image: image!)
                }
               
            }
            else
            {
                image = UIImage(named: "default_athletics_score_img")
            }
           
            // in cases where the url does not point to an image and we are unable to form an image. Use the default image
            // Reason : 
            // sometimes we are not able to extract the school code, this happens for golf, and we end up with a string web../-lg.png
            // For some reason this not a 404 at the server side and gives us some rubbish back , so we need to chek if we have been able to form an image from the data
            
            

            DispatchQueue.main.async {
                // Update the UI
                cell.schoolIcon.contentMode = .scaleAspectFit
                cell.schoolIcon.image = image
            }
        }

        if (item.isEvent || item.nilScores) {
            cell.homeScore.hidden = true
            cell.awayScore.hidden = true
            cell.scoreDivider.hidden = true
        }
        
        // if Rutgers is home
        if(item.isRuHome)
        {
            cell.homeScore.text = String(item.ruScore)
            cell.homeScore.textColor = UIColor.red
            cell.awayScore.text = String(item.otherScore)
            cell.sideIndicator.backgroundColor = UIColor.red
        }
        else
        {
            cell.awayScore.text = String(item.ruScore)
            cell.awayScore.textColor = UIColor.red
            cell.homeScore.text = String(item.otherScore)
            cell.sideIndicator.backgroundColor = UIColor.gray
        }

        cell.locationLabel.text = item.descriptionText
        cell.dateTimeLabel.text = item.dateString
        cell.schoolNameLabel.text = item.title
        
        // set the shadow
        cell.layer.shadowOffset = CGSize.zero;
        cell.layer.shadowColor = UIColor.black.cgColor
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
    static func channelHandle() -> String
    {
        return "Athletics"
    }
    
    static func registerClass()
    {
        RUChannelManager.sharedInstance().register(AthleticsCollectionViewController.self)
    }
    
    static func channel(withConfiguration channelConfiguration: [AnyHashable : Any]!) -> Any! {
        //   let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        return AthleticsCollectionViewController(channel: channelConfiguration as [NSObject : AnyObject]!) // load the view for the controller from the nib file
    }
   
    init(channel : [NSObject : AnyObject]!)
    {
        self.channel = channel as NSDictionary! ;
        super.init(nibName: "AthleticsCollectionViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        self.collectionView!.register(UINib.init(nibName: "AthleticsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        layout.sectionInset = UIEdgeInsetsMake(18, 10 , 18, 10 )
        layout.minimumLineSpacing = 18 ;
        layout.minimumInteritemSpacing = 18 ;
        self.collectionView!.setCollectionViewLayout(layout, animated: true)
        
        // get the url to visit
        let atheleticsUrl = "sports/\(self.channel["data"]!).json"
        self.dataSource = RUReaderDataSource.init(url: atheleticsUrl)
        
        self.dataSource.loadContent
            {
                DispatchQueue.main.async // call reload on main thread otherwise veryt laggy
                {
                    self.collectionView!.reloadData()
                    self.collectionView!.layoutIfNeeded()
                    self.activityIndicator.stopAnimating()
                }
        }
       
        self.collectionView?.dataSource = self.dataSource
       // Add notification to handle rotate of the app .. 
        NotificationCenter.default.addObserver(self, selector: #selector(AthleticsCollectionViewController.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

    }

    // MARK: Flow Layout Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // deteremine the cell hieght based on the orientation and device ..
        
        var cellHeight : CGFloat?
        let orientation = UIApplication.shared.statusBarOrientation
        if(orientation == .landscapeLeft || orientation == .landscapeRight)
        {
            cellHeight = (self.collectionView?.bounds.height)! / 3 ;
        }
        else
        {
            cellHeight = (self.collectionView?.bounds.height)! / 5 ;
        }
        
        return CGSize(  width: (self.collectionView?.bounds.size.width)! - 20 , height: cellHeight! ) ;
    }
   
   
    func orientationChanged()
    {
        print("rotate")
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
}
