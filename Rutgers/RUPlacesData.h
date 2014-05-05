//
//  RUPlacesData.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MAX_RECENT_PLACES 7
#define MAX_NEARBY_PLACES 7
@class CLLocation;
@interface RUPlacesData : NSObject


-(void)queryPlacesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock;
-(void)getRecentPlacesWithCompletion:(void (^)(NSArray *recents))completionBlock;
-(void)addPlaceToRecentPlacesList:(NSDictionary *)place;
-(void)placesNearLocation:(CLLocation *)location completion:(void (^)(NSArray *nearbyPlaces))completionBlock;

+(RUPlacesData *)sharedInstance;
@end
