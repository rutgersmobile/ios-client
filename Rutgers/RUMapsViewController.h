//
//  RUMapsViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class RUPlace;

@interface RUMapsViewController : UIViewController <MKMapViewDelegate>;

@property (nonatomic) MKMapView *mapView;

-(id)initWithPlace:(RUPlace *)place;
@property (nonatomic) RUPlace *place;
-(void)zoomToPlace;
@end
