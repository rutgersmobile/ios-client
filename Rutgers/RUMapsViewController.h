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
-(instancetype)initWithPlace:(RUPlace *)place NS_DESIGNATED_INITIALIZER;

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) RUPlace *place;
-(void)zoomToPlace;
@end
