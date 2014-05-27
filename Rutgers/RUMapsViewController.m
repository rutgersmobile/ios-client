//
//  RUMapsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsViewController.h"
#import <MapKit/MapKit.h>
#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import "NSUserDefaults+MKMapRect.h"

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
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    self.view = self.mapView;
    
    [self.navigationController setToolbarHidden:NO animated:NO];

    //make sure nothing gets rendered under the osm tiles
    self.mapView.showsBuildings = NO;
    self.mapView.showsPointsOfInterest = NO;
    
    //this looks weird so disable it
    self.mapView.pitchEnabled = NO;

    self.mapView.showsUserLocation = YES;
    
    //setup tracking toolbar
    UIBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = @[flexibleSpace, trackingButton,flexibleSpace];
    [self setToolbarItems:barArray];
    
    //load last map rect, or world rect
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{mapsRecentRegionKey : MKStringFromMapRect(MKMapRectWorld)}];
    MKMapRect mapRect = [[NSUserDefaults standardUserDefaults] mapRectForKey:mapsRecentRegionKey];
    [self.mapView setVisibleMapRect:mapRect];

    
    //add our overlay
    RUMapsTileOverlay *overlay = [[RUMapsTileOverlay alloc] init];
    overlay.canReplaceMapContent = YES;
    [self.mapView addOverlay:overlay
                       level:MKOverlayLevelAboveLabels];
}

#pragma mark - MKMapViewDelegate
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    
    return nil;
}
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults] setMapRect:mapView.visibleMapRect forKey:mapsRecentRegionKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
