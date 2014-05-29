//
//  RUMapsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsViewController.h"
#import <MBXMapKit.h>

NSString *const mapsRecentRegionKey = @"mapsRecentRegionKey";

@interface RUMapsViewController () <MKMapViewDelegate>
@property MKMapView *mapView;
@end

@implementation RUMapsViewController
+(instancetype)component{
    return [[RUMapsViewController alloc] init];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.mapView = [[MBXMapView alloc] initWithFrame:self.view.bounds mapID:@"examples.map-pgygbwdm"];
    self.mapView.delegate = self;
    
    self.view = self.mapView;
    
    [self.navigationController setToolbarHidden:NO animated:NO];

    self.mapView.showsUserLocation = YES;
    
    //setup tracking toolbar
    UIBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = @[flexibleSpace, trackingButton,flexibleSpace];
    [self setToolbarItems:barArray];
    
    //load last map rect, or world rect
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:mapsRecentRegionKey];
    if (array) {
        self.mapView.camera.altitude = [array[0] doubleValue],
        self.mapView.camera.centerCoordinate = CLLocationCoordinate2DMake([array[1] doubleValue],[array[2] doubleValue]);
    }
    
}

#pragma mark - MKMapViewDelegate protocol implementation
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D coordinate = mapView.centerCoordinate;
    NSArray *array = @[@(mapView.camera.altitude),@(coordinate.latitude),@(coordinate.longitude)];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:mapsRecentRegionKey];
}

@end
