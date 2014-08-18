//
//  RUBusDataLoadingManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

static NSString * const newBrunswickAgency;
static NSString * const newarkAgency;

#define TITLES @{newBrunswickAgency : @"New Brunswick", newarkAgency : @"Newark"}

@interface RUBusDataLoadingManager : NSObject

+(instancetype)sharedInstance;
-(void)fetchAllStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchAllRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler;

-(void)fetchActiveStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchActiveRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler;

-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void(^)(NSArray *stops, NSError *error))handler;

-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *results))handler;

-(void)getPredictionsForItem:(id)item withSuccess:(void (^)(NSArray *))successBlock failure:(void (^)(void))failureBlock;
@end
