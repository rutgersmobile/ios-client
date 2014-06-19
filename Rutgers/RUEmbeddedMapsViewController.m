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
}

@synthesize place = _place;
-(void)setPlace:(RUPlace *)place{
    if (![_place isEqual:place]) {
        [self.mapView removeAnnotation:_place];
        _place = place;
        [self zoomToPlace];
    }
}/*
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *view = [super mapView:mapView viewForAnnotation:annotation];
    view.canShowCallout = NO;
    return view;
}*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
