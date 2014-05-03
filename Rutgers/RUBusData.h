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

@class RUBusData;

@protocol RUBusDataDelegate <NSObject>
@required
-(void)busData:(RUBusData *)busData didUpdateNearbyStops:(NSDictionary *)nearbyStops;
@end

@class RUBusRoute;

@interface RUBusData : NSObject
-(void)startFindingNearbyStops;
-(void)stopFindingNearbyStops;

-(void)updateActiveStopsAndRoutesWithCompletion:(void (^)(NSDictionary *activeStops, NSDictionary *activeRoutes))completionBlock;

-(void)getPredictionsForStops:(NSArray *)stops withCompletion:(void (^)(NSArray *response))completionBlock;
-(void)getPredictionsForRoute:(RUBusRoute *)route withCompletion:(void (^)(NSArray *response))completionBlock;


-(void)queryStopsAndRoutesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock;

@property (weak) id<RUBusDataDelegate> delegate;



@property NSDictionary *nearbyStops;


+(RUBusData *)sharedInstance;

@end
