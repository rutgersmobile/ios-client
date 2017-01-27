//
//  BannerCell.swift
//  Rutgers
//
//  Created by scm on 11/9/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation


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
    func loadImagesFromUrlStrings( array : [String] , callbackUIUpdate : @escaping (Bool) -> Void)
    {
        // set the strImages for indexing into array
        self.strImages = array
        
        let imageCacheAccessQueue : DispatchQueue = DispatchQueue(label: "com.rutgers.imageCacheQueue", attributes: []) // just setting a name for the queue to be used when we profile
        
        // the group is created so that the ui update can be done at the proper time
        // After every block that has been added to the group has been executed , we will use the group notify to run the uiupdate . Ensures that ui is updated only after all the data has been obtained
        let imageDownloadGroup : DispatchGroup = DispatchGroup()
        
        
        for imageStr  in array // iterate through each image string in the array and create a nsurlsession for each and load them
        {
            guard cachedImages![imageStr] == nil else
            {
                continue
            }
            // if the image is not present then load the image from the url , else continue and move to next step
            
            // enter the group
            imageDownloadGroup.enter()
            
            let imageUrl = URL.init(string: imageStr)!
            let task = URLSession.shared.dataTask(with: imageUrl, completionHandler: {
                ( data , response , error) in
                
                   if let imageData = data
                   {
                        let responseImage = UIImage(data: imageData)
                 
                        if let image = responseImage // failure to convert the data into image . if so show a default banner
                        {
                            // put the blocks into a serial qeueue to ensure that the insertion into th dict happens in a thread safe manner and not having to use locks
                            // we add it to the group so that the group notify will only be called after the images has been added to the dict
                            imageCacheAccessQueue.async(group: imageDownloadGroup)
                            {
                                self.cachedImages![imageStr] = image
                            }
                        }
                        else
                        {
                            imageCacheAccessQueue.async(group: imageDownloadGroup)
                            {
                                self.cachedImages![imageStr] = UIImage(named:"default_dynamic_banner_img")
                            }
                        }
                    
                       
                   }
                    else // did not obtain the image .. Put some place holder to the image.. Or not show the banner a
                   {
                        // did not get the data and errored out . Put a default image up
                        imageCacheAccessQueue.async(group: imageDownloadGroup)
                        {
                            self.cachedImages![imageStr] = UIImage(named:"default_dynamic_banner_img")
                        }
                    
                   }
                
                    // leave the group
                    imageDownloadGroup.leave()
            })            

            
            task.resume()
           
        }
        
        imageDownloadGroup.notify(queue: DispatchQueue.main)
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
        return self.strImages!.count
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
   
    override func prepareForReuse()
    {
        
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        // set up the data source used to load the images in the cell
        dataSource = BannerCellDataSource()
        
        // set the activity view to take up the entire cell bounds
        loadingView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        loadingView?.center = self.contentView.center
        loadingView?.startAnimating() // keep on animating till the iamge has been loaded
        
        
       
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
            dataSource?.loadImagesFromUrlStrings(array: strArray)
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
               
            } }
    
    func loadDataFromDataSourceAndDisplay()
    {
        
        self.setupViews()
        for index in 0..<self.dataSource!.numImages()
        {
            // create the proper frame to add the scrollview in
            var tempFrame = CGRect(x:0, y:0, width:0, height:0)
            tempFrame.origin.x = self.scrollView!.frame.size.width * CGFloat(index)
            tempFrame.size = self.scrollView!.frame.size
         
            let subView = UIImageView(frame: tempFrame)
            subView.image = self.dataSource!.imageAtIndex(idx: index)
            self.scrollView!.addSubview(subView)
        }
        self.scrollView!.contentSize = CGSize(width:self.scrollView!.frame.size.width * CGFloat(self.dataSource!.numImages()) , height:self.scrollView!.frame.size.height)
    }
    
    
    func setupViews()
    {
        
        if(scrollView != nil)
        {
            self.scrollView?.removeFromSuperview()
            self.pageControl?.removeFromSuperview()
        }
        
        
        // set the size and pos of the scrollview inside the cell to take up the entire cell
        scrollView = UIScrollView(frame: CGRect(x:0, y:0, width:self.contentView.bounds.width, height:self.contentView.bounds.height))
        scrollView!.delegate = self

        pageControl = UIPageControl(frame: CGRect(x:0, y:self.contentView.bounds.height - 50, width:self.contentView.bounds.width, height:50))
        self.pageControl!.addTarget(self, action: #selector(BannerCell.changePage(sender:)), for: UIControlEvents.valueChanged)
        
 
        self.loadingView?.stopAnimating()
        self.contentView.addSubview(scrollView!) // add the scrollview to the screen
        self.scrollView!.isPagingEnabled = true
        self.pageControl!.numberOfPages = (self.dataSource?.numImages())!
        self.pageControl!.currentPage = 0
        self.pageControl!.tintColor = UIColor.red
        self.pageControl!.pageIndicatorTintColor = UIColor.black
        self.pageControl!.currentPageIndicatorTintColor = UIColor.green
        self.contentView.addSubview(pageControl!)
    }
    
   
    func changePage(sender: AnyObject) -> ()
    {
        let x  = CGFloat(pageControl!.currentPage) * scrollView!.frame.size.width
        scrollView!.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl!.currentPage = Int(pageNumber)
    }

}




