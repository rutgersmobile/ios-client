//
//  RUBusDataAgencyManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RUBusDataAgencyManager : NSObject
-(instancetype)initWithAgency:(NSString *)agency NS_DESIGNATED_INITIALIZER;
+(instancetype)managerForAgency:(NSString *)agency;

-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *routes, NSArray *stops, NSError *error))handler;

-(void)fetchAllStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchAllRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler;
-(void)fetchActiveStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchActiveRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler;
-(void)fetchActiveStopsNearbyLocation:(CLLocation *)location completion:(void(^)(NSArray *stops, NSError *error))handler;
@end
