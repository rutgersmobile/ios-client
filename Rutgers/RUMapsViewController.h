//
//  RUMapsViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RUPlace.h"

@interface RUMapsViewController : UIViewController 
@property (nonatomic) MKMapView *mapView;

-(id)initWithPlace:(RUPlace *)place;

@end
