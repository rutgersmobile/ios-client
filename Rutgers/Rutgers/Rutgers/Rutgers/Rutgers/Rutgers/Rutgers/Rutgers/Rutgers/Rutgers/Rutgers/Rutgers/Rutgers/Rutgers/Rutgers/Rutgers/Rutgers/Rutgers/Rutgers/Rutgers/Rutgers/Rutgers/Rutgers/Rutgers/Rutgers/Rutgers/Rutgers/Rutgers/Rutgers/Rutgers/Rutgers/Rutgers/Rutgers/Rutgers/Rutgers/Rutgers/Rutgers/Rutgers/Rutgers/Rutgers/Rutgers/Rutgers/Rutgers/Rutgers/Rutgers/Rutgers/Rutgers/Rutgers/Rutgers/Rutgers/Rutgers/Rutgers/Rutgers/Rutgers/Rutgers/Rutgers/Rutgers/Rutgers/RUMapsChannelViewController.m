//
//  RUMapsComponent.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsChannelViewController.h"
#import "RUChannelManager.h"

NSString *const mapsRecentCameraKey = @"mapsRecentCameraKey";

@interface RUMapsChannelViewController ()
@property (nonatomic) BOOL shouldStartTrackingOnLocationUpdate;
@end

@implementation RUMapsChannelViewController
+(NSString *)channelHandle{
    return @"maps";
}
+(void)load{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] init];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.shouldStartTrackingOnLocationUpdate = YES;
}

-(void)encodeRestorableStateWithCoder:(nonnull NSCoder *)coder{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.mapView.camera forKey:mapsRecentCameraKey];
}

-(void)decodeRestorableStateWithCoder:(nonnull NSCoder *)coder{
    MKMapCamera *camera = [coder decodeObjectForKey:mapsRecentCameraKey];
    if (camera) {
        self.mapView.camera = camera;
    }
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
