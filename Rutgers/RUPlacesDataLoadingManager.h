//
//  RUPlacesData.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class RUPlace;

extern NSString *PlacesDataDidUpdateRecentPlacesKey;

@interface RUPlacesDataLoadingManager : NSObject
+(RUPlacesDataLoadingManager *)sharedInstance;

-(void)performOnPlacesLoaded:(void (^)(NSError *error))block;

-(void)queryPlacesWithString:(NSString *)query completion:(void (^)(NSArray *results, NSError *error))completionBlock;

-(void)userWillViewPlace:(RUPlace *)place;
-(void)getRecentPlacesWithCompletion:(void (^)(NSArray *recents))completionBlock;

-(void)placesNearLocation:(CLLocation *)location completion:(void (^)(NSArray *nearbyPlaces, NSError *error))completionBlock;
@end
