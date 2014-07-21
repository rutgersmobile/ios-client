//
//  RUBusDataAgencyManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUBusDataAgencyManager : NSObject
-(instancetype)initWithAgency:(NSString *)agency;
+(instancetype)managerForAgency:(NSString *)agency;

-(void)fetchAllStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchAllRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler;
-(void)fetchActiveStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler;
-(void)fetchActiveRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler;

@end
