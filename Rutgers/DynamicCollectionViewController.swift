//
//  DynamicCollectionViewController.swift
//  Rutgers
//
//  Created by scm on 8/25/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

private let viewElement = "cell"
private let bannerElement = "banner"

/*
    If the channel has the banner tag to it , then the banner will be added to the top
 */

// initialization and view setup
class DynamicCollectionViewController: UICollectionViewController, RUChannelProtocol
{
    var dataSource : DynamicDataSource! = nil
    var channel : NSDictionary! = nil
    // the indicator to show before the data is loaded..
    var activityIndicator : UIActivityIndicatorView! = nil
    var  bannerImageNames : [String]?
   
    let flowLayout : UICollectionViewFlowLayout =
    {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake( 18, 18 , 18, 20 )
        layout.minimumLineSpacing = 15 ;
        layout.minimumInteritemSpacing = 15 ;
        return layout
    }()
    
    
   /// Conform to RUChannelProtocol
    static func channelHandle() -> String!
    {
        return "dtable-grid"
    }
  
    static func registerClass()
    {
        RUChannelManager.sharedInstance().register(DynamicCollectionViewController.self)
    }
   
    public static func channel(withConfiguration channelConfiguration: [AnyHashable : Any]!) -> Any! {
        return DynamicCollectionViewController(channel: channelConfiguration as [NSObject : AnyObject]) // load the view for the controller from the nib file
    }

    init(channel : [NSObject : AnyObject]!)
    {
        self.channel = channel as NSDictionary!
        self.bannerImageNames = nil;
        super.init(collectionViewLayout: self.flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
   
    func isBannerPresent() -> Bool
    {
        return self.bannerImageNames != nil;
    }
    

    override func viewDidLoad()
    {

        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        self.collectionView?.backgroundColor = UIColor.white
        
        self.collectionView!.register(UINib.init(nibName: "DynamicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: viewElement)
        self.collectionView!.register(BannerCell.self, forCellWithReuseIdentifier: bannerElement)
        
        
        self.collectionView?.dataSource = self;
        self.collectionView?.delegate = self ;

        
        self.dataSource = DynamicDataSource.init(channel:  self.channel as [NSObject : AnyObject] , forLayout: true)
        
        self.dataSource.loadContent // when the data has been loaded , we stop the load sign and layout the views
        {
            // extract the banner images into an array
            self.extractBannerNamesFromDataSource()
            DispatchQueue.main.async {
                self.collectionView!.reloadData()
                self.activityIndicator.stopAnimating()
            }
  
        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    func extractBannerNamesFromDataSource() 
    {
        // if images exist in the bannerItems. Then create the banner
        guard self.dataSource.bannerItems != nil else
        {
            return
        }
        // images present in the datasource for the banner and hence we add it to the view
        self.bannerImageNames = [String]()
        
        for item in self.dataSource.bannerItems
        {
            let dict : NSDictionary = item as! NSDictionary
            self.bannerImageNames?.append(dict["image"] as! String)
        }
    }
    
}

// Add the layout methods
extension DynamicCollectionViewController
{
     func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        // let halfWidth = (self.collectionView?.bounds.width)! / 2
        // let reducedSize = halfWidth - 10
        //return CGSizeMake(reducedSize, reducedSize)
       
        var cellWidth:CGFloat = 0 ;
        var cellSize:CGSize ;
        let screenWidth = self.collectionView?.bounds.width
        
        
        if(indexPath.row == 0 && self.isBannerPresent())
        {
            let aspectRatio:CGFloat = 0.8 ;  // the height will be (value) more than the width
            cellWidth = (screenWidth! - 20 );
            cellSize = CGSize(width:cellWidth, height:cellWidth * aspectRatio)
        }
        else
        {
            let aspectRatio:CGFloat = 1.2 ;  // the height will be (value) more than the width
            cellWidth = (screenWidth! ) / 2.4;
            cellSize = CGSize(width:cellWidth, height:cellWidth * aspectRatio)
        }
        
        return cellSize
        
    }
    
  
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionView?.collectionViewLayout.invalidateLayout()
        if(isBannerPresent())
        {
            let bannerIndexPath = IndexPath(row: 0, section: 0)
            self.collectionView?.reloadItems(at: [bannerIndexPath])
        }
    }
  

    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let _ = bannerImageNames // if we have to add the banner , then decide the size for the banner too
        {
            if(indexPath.row == 0)
            {
                return false
            }
        }
        
        return true
    }



    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item:NSDictionary!

        if (isBannerPresent()) // if we have to add the banner , then index to old data source is -1
        {
                let indexForDict : IndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                item = self.dataSource.item(at: indexForDict) as! NSDictionary
        }
        else
        {
                item = self.dataSource.item(at: indexPath) as! NSDictionary
        }
        
            
        var channel = item["channel"]
        
        if ((channel == nil))
        {
            channel = item ;
        }
       
        let vc : UIViewController = RUChannelManager.sharedInstance().viewController(forChannel: channel as! [NSObject : AnyObject]!)
       
        if( ((channel! as AnyObject).channelTitle == nil) && (item.channelTitle != nil))
        {
            vc.title = item.channelTitle
        }
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
       
    }

    
    
 }

    
// Data Source Items
extension DynamicCollectionViewController
{
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataSource.numberOfSections
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
       // if the banner has to be added , the we have 1 more element than the number of items in the data source
       if let _ = self.bannerImageNames
       {
            return self.dataSource.numberOfItems(inSection: section) + 1  // for the banner
       }
       else
       {
           return self.dataSource.numberOfItems(inSection: section)
       }
        
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(isBannerPresent())
        {
            if(indexPath.row == 0)
            {
                // the banner images will obly have the images, not the url
                return loadBannerCell(reuseIdentifier: bannerElement, imageNames: self.bannerImageNames! , indexPath: indexPath as NSIndexPath)
            }
            else
            {
                
                // In order to compensate for the data source requring elements zero indexed , but here the zero index is the banner , we decrement by 1
                let indexForDict : IndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                return loadDynamicCollectionViewCell(reuseIdentifier: viewElement, indexPath: indexForDict as NSIndexPath)
            }
            
        }
        else
        {
           return loadDynamicCollectionViewCell(reuseIdentifier: viewElement, indexPath: indexPath as NSIndexPath)
        }
        
    }
    
    
    func loadBannerCell(reuseIdentifier : String , imageNames : [String] , indexPath : NSIndexPath) -> BannerCell
    {
            let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! BannerCell
            print(cell.frame)

            cell.layer.borderColor = UIColor.blue.cgColor
            cell.layer.borderWidth = 2
            cell.layer.cornerRadius = 8
             // The cell will keep showing the activity view until the images are loaded from the urls
       
            // the imageNames will only contain the filename and type , not the url . Ie image.jpg
            let imageBaseUrlString = RUNetworkManager.baseURL().absoluteString + "img/"
            let imageUrlStringArr = imageNames.map({"\(imageBaseUrlString)\($0)"})
        
            cell.loadImagesForUrlStrings(strArray: imageUrlStringArr)
            return cell;
    }

    func loadDynamicCollectionViewCell(reuseIdentifier : String , indexPath : NSIndexPath) -> DynamicCollectionViewCell
    {
        
        let cell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! DynamicCollectionViewCell
        

        let item : NSDictionary = (self.dataSource.item(at: indexPath as IndexPath!) as! NSDictionary)

        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 5
        cell.title.attributedText = NSAttributedString(
            string: item.channelTitle,
            attributes: [NSParagraphStyleAttributeName: style]
        )
        
        // even if no image name is present, show a default image, to prevent the ugly UI
        cell.imageView.image = UIImage(named: "default_dynamic_cell_img")
        
        if let imageLocation = item["image"] as? String
        {
            let imageUrlString = RUNetworkManager.baseURL().absoluteString + "img/" + imageLocation
            let imageUrl = URL(string: imageUrlString)
            
            DispatchQueue.global(qos: .background).async
            {
                let imageData : Data?
                do {
                    imageData = try Data(contentsOf: imageUrl!)
                } catch {
                    imageData = nil
                }

                if let imageData = imageData
                {
                    let image = UIImage(data: imageData)
                    
                    DispatchQueue.main.async
                    {
                        // Update the UI
                        cell.imageView.contentMode = .scaleAspectFit
                        if let image = image // if we have an image , then update the image, else keep the default image we set earlier
                        {
                            cell.imageView.image = image
                        }
                        
                    }    
                }
                
            }
        }
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
}

// Rotation Support
extension DynamicCollectionViewController
{
    
    
}
