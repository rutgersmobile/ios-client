//
//  RUBusData.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

const NSString *newBrunswickAgency;
const NSString *newarkAgency;

@class RUBusData;

@protocol RUBusDataDelegate <NSObject>
@required
-(void)busData:(RUBusData *)busData didUpdateNearbyStops:(NSDictionary *)nearbyStops;
@end

@class RUBusRoute;

@interface RUBusData : NSObject
-(void)startFindingNearbyStops;
-(void)stopFindingNearbyStops;

-(void)updateActiveStopsAndRoutesWithCompletion:(void (^)(void))completionBlock;

-(void)getPredictionsForStops:(NSArray *)stops inAgency:(NSString *)agency withCompletion:(void (^)(NSArray *response))completionBlock;
-(void)getPredictionsForRoute:(RUBusRoute *)route inAgency:(NSString *)agency withCompletion:(void (^)(NSArray *response))completionBlock;

@property (weak) id<RUBusDataDelegate> delegate;

@property NSMutableDictionary *stops;
@property NSMutableDictionary *routes;
@property NSMutableDictionary *activeStops;
@property NSMutableDictionary *activeRoutes;
@property NSDictionary *nearbyStops;

+(RUBusData *)sharedInstance;

@end
