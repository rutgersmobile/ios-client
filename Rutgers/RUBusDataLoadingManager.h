//
//  RUBusDataLoadingManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

extern NSString * const newBrunswickAgency;
extern NSString * const newarkAgency;

/**
 *  The centralized point of bus data access. All messages should be sent to the singleton instance
 */
@interface RUBusDataLoadingManager : NSObject

+(instancetype)sharedInstance;

+(NSString *)titleForAgency:(NSString *)agency;

-(void)fetchAllStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchAllRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler;

-(void)fetchActiveStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchActiveRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler;

-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void(^)(NSArray *stops, NSError *error))handler;

-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *routes, NSArray *stops, NSError *error))handler;

-(void)getPredictionsForItem:(id)item completion:(void (^)(NSArray *predictions,  NSError *error))handler;

-(void)getSerializedItemWithName:(NSString *)name type:(NSString *)type completion:(void (^)(id item, NSError *error))handler;
@end
