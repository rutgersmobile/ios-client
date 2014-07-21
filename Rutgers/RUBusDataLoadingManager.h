//
//  RUBusDataLoadingManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
extern NSString const *newBrunswickAgency;
extern NSString const *newarkAgency;
*/

@interface RUBusDataLoadingManager : NSObject

+(instancetype)sharedInstance;
-(void)fetchAllStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchAllRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler;
-(void)fetchActiveStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchActiveRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler;

@end