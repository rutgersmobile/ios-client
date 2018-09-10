//
//  RUMapsViewController.swift
//  Rutgers
//
//  Created by Open Systems Solutions on 6/16/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

import Foundation

import MapKit

protocol MapViewDelegate {
    
}

typealias Annotation = MKAnnotation

protocol MapView {
    var showsUserLocation: Bool { get set }
    
    var userTrackingBarButtonItem: UIBarButtonItem? { get }
    
    func addAnnotationWrapper(annotation: Annotation)
    func removeAnnotationWrapper(annotation: Annotation)
    
    //func showAnnotationsWrapper(annotations: [Annotation], animated: Bool)
   
    func showCoordinate(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, animated: Bool)
}



extension MKMapView: MapView {
    var userTrackingBarButtonItem: UIBarButtonItem? {
        return MKUserTrackingBarButtonItem(mapView: self)
    }
    
    func addAnnotationWrapper(annotation: Annotation) {
        addAnnotation(annotation)
    }
    
    func removeAnnotationWrapper(annotation: Annotation) {
        removeAnnotation(annotation)
    }
    
    func showCoordinate(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, animated: Bool) {
        let camera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: altitude)
        setCamera(camera, animated: animated)
    }

    func showAnnotationsWrapper(annotations: [Annotation], animated: Bool) {
        showAnnotations(annotations, animated: animated)
    }
}

@objcMembers
open class MapsViewController: UIViewController {
    open static let defaultMapRect = MKMapRectMake(78609409.062235206, 100781568.35516316, 393216.0887889266, 462848.10451197624)
    
    var mapView: MapView!
    open var place: RUPlace?
    
    public init(place: RUPlace) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func loadView() {
        super.loadView()
        
        let bounds = view.bounds
 
            let mapView = MKMapView(frame: bounds)
            self.mapView = mapView
            self.view = mapView;

        mapView.setVisibleMapRect(MapsViewController.defaultMapRect, animated: false)
        //mkMapView.delegate = self;
        mapView.showsUserLocation = true;
        
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = true

        navigationItem.rightBarButtonItem = mapView.userTrackingBarButtonItem
        loadPlace(animated: false)
    }
    
    func loadPlace(animated: Bool) {
        title = place?.title
        
        zoomToPlace(animated: animated)
    }
    
    func zoomToPlace(animated: Bool) {
        guard let place = place else { return }
        mapView.addAnnotationWrapper(annotation: place)
        mapView.showCoordinate(coordinate: place.coordinate, altitude: 850, animated: animated)
    }
}

open class EmbeddedMapsViewController: MapsViewController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
    }
    
    override open var place: RUPlace? {
        didSet {
            if let place = oldValue {
                mapView.removeAnnotationWrapper(annotation: place)
            }
            
            zoomToPlace(animated: false)
        }
    }
}
