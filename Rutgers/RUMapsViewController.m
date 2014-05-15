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
    [self.view addSubview:self.mapView];
    [self.mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    RUMapsTileOverlay *overlay = [[RUMapsTileOverlay alloc] init];
    overlay.canReplaceMapContent = YES;
    [self.mapView addOverlay:overlay
                       level:MKOverlayLevelAboveLabels];
}
#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
