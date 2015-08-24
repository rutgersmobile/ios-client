//
//  RUOSMDataLoadingManager.m
//  Rutgers
//
//  Created by Open Systems Solutions on 7/31/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import "RUOSMDataLoadingManager.h"
#import "RUNetworkManager.h"
#import <MapKit/MapKit.h>

@implementation RUOSMDataLoadingManager
+(instancetype)sharedManager{
    static RUOSMDataLoadingManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RUOSMDataLoadingManager alloc] init];
    }); 
    return sharedManager;
}

static MKMapRect RutgersNewBrunswickMapRect = {78691175.381219566, 101107765.14724207, 28528.723740428686, 48530.010125249624};
//static MKMapRect RutgersNewarkMapRect = {78894857.494345963, 100867653.78942496, 36284.271456703544, 38839.335474461317};

-(void)get{
    NSString *base = @"http://api.openstreetmap.org/api/0.6/";
    
    [[RUNetworkManager sessionManager] GET:[base stringByAppendingString:@"map"] parameters:[self parametersFromMapRect:RutgersNewBrunswickMapRect] success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *ways = [responseObject[@"way"] subarrayWithRange:NSMakeRange(0, 100)];
        NSMutableString *wayString = [NSMutableString string];
        NSInteger number = ways.count;
        [ways enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [wayString appendString:obj[@"_id"]];
            if (idx != number - 1) [wayString appendString:@","];
        }];
        [[RUNetworkManager sessionManager] GET:[base stringByAppendingString:@"ways"] parameters:@{@"ways" : wayString} success:^(NSURLSessionDataTask *task, id responseObject) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

}

-(id)parametersFromMapRect:(MKMapRect)mapRect{
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    CLLocationDegrees left = region.center.longitude - region.span.longitudeDelta/2.0;
    CLLocationDegrees bottom = region.center.latitude - region.span.latitudeDelta/2.0;
    CLLocationDegrees right = region.center.longitude + region.span.longitudeDelta/2.0;
    CLLocationDegrees top = region.center.latitude + region.span.latitudeDelta/2.0;

    return @{@"bbox" : [NSString stringWithFormat:@"%f,%f,%f,%f",left,bottom,right,top]};
}

@end
