//
//  RUBusData.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString const* newBrunswickAgency;
NSString const* newarkAgency;

@class RUBusRoute, CLLocation;

@interface RUBusData : NSObject
-(void)getActiveStopsAndRoutesWithCompletion:(void (^)(NSDictionary *activeStops, NSDictionary *activeRoutes))completionBlock;

-(void)getPredictionsForItem:(id)item withCompletion:(void (^)(NSArray *response))completionBlock;

-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock;
-(void)stopsNearLocation:(CLLocation *)location completion:(void (^)(NSArray *results))completionBlock;

+(RUBusData *)sharedInstance;

@end
