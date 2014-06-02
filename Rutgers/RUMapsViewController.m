//
//  RUMapsViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/8/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsViewController.h"
#import <MapKit/MapKit.h>
#import "RUMapView.h"
#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import "NSUserDefaults+MKMapRect.h"

NSString *const mapsRecentRegionKey = @"mapsRecentRegionKey";

@interface RUMapsViewController () <MKMapViewDelegate>
@property (nonatomic) RUMapView *mapView;
@end

@implementation RUMapsViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUMapsViewController alloc] init];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    RUMapView *mapView = [[RUMapView alloc] initForAutoLayout];
    mapView.delegate = self;
    self.mapView = mapView;
    
    [self.view addSubview:mapView];
    [mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self.navigationController setToolbarHidden:NO animated:NO];

    //setup tracking toolbar
    UIBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *barArray = @[flexibleSpace, trackingButton,flexibleSpace];
    [self setToolbarItems:barArray];
    
    //load last map rect, or world rect
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{mapsRecentRegionKey : MKStringFromMapRect(MKMapRectWorld)}];
    MKMapRect mapRect = [[NSUserDefaults standardUserDefaults] mapRectForKey:mapsRecentRegionKey];
    [mapView setVisibleMapRect:mapRect];
}
-(void)dealloc{
    self.mapView.delegate = nil;
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

#pragma mark - MKMapViewDelegate protocol implementation
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults] setMapRect:mapView.visibleMapRect forKey:mapsRecentRegionKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
