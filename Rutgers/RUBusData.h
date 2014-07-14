//
//  RUBusData.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RUBusRoute, CLLocation;

extern NSString const *newBrunswickAgency;
extern NSString const *newarkAgency;

@interface RUBusData : NSObject

-(void)getAgencyConfigWithCompletion:(void (^)(NSDictionary *allStops, NSDictionary *allRoutes))completionBlock;
-(void)getActiveStopsAndRoutesWithCompletion:(void (^)(NSDictionary *activeStops, NSDictionary *activeRoutes))completionBlock;

-(void)getPredictionsForItem:(id)item withSuccess:(void (^)(NSArray *response))successBlock failure:(void (^)(void))failureBlock;
-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock;
-(void)getActiveStopsNearLocation:(CLLocation *)location completion:(void (^)(NSArray *results))completionBlock;

+(RUBusData *)sharedInstance;

@end
