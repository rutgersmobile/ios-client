//
//  RUMapsComponent.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsComponent.h"
#import "NSUserDefaults+MKMapRect.h"

NSString *const mapsRecentRegionKey = @"mapsRecentRegionKey";


@interface RUMapsComponent ()
@property (nonatomic) BOOL shouldStartTrackingOnLocationUpdate;
@end

@implementation RUMapsComponent
+(instancetype)newWithChannel:(NSDictionary *)channel{
    return [[self alloc] init];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldStartTrackingOnLocationUpdate = YES;
    
    //load last map rect, or world rect
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{mapsRecentRegionKey : MKStringFromMapRect(MKMapRectWorld)}];
    MKMapRect mapRect = [[NSUserDefaults standardUserDefaults] mapRectForKey:mapsRecentRegionKey];
    [self.mapView setVisibleMapRect:mapRect];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mapView.showsUserLocation = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.mapView.userTrackingMode != MKUserTrackingModeNone) {
        self.shouldStartTrackingOnLocationUpdate = YES;
    }
    self.mapView.showsUserLocation = NO;

}

#pragma mark - MKMapViewDelegate protocol implementation
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
   // [super mapView:mapView regionDidChangeAnimated:animated];
    [[NSUserDefaults standardUserDefaults] setMapRect:mapView.visibleMapRect forKey:mapsRecentRegionKey];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if (self.shouldStartTrackingOnLocationUpdate) {
        [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        self.shouldStartTrackingOnLocationUpdate = NO;
    }
}

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
