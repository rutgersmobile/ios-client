//
//  RUEmbeddedMapsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/13/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUEmbeddedMapsViewController.h"
#import "RUPlace.h"

@interface RUEmbeddedMapsViewController ()

@end

@implementation RUEmbeddedMapsViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.userInteractionEnabled = NO;
    //self.mapView.zoomEnabled = NO;
    //self.mapView.scrollEnabled = NO;
}

-(void)setPlace:(RUPlace *)place{
    if (![self.place isEqual:place]) {
        [self.mapView removeAnnotation:self.place];
        [super setPlace:place];
        [self zoomToPlace];
    }
}

@end
