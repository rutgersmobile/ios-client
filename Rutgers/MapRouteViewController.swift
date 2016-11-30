//
//  MapRouteViewController.swift
//  Rutgers
//
//  Created by scm on 11/21/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import UIKit
import MapKit

class MapRouteViewController: UIViewController
{
    let defaultMapRect = MKMapRectMake(78609409.062235206, 100781568.35516316, 393216.0887889266, 462848.10451197624)
    var mapView : MKMapView? = nil;

    init()
    {
        super.init(nibName: nil, bundle: nil)
        // initilize the map view
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
    }
    
    override func loadView()
    {
        super.loadView()
        mapView = MKMapView.init(frame: self.view.bounds)
        self.view = mapView!
    }
    
    override func viewDidLoad()
    {
        // set properties of the map view[
        self.mapView?.setVisibleMapRect(self.defaultMapRect, animated: false)
        self.mapView?.showsUserLocation = true
        self.mapView?.mapType = .Standard
        
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
