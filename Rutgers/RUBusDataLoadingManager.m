//
//  RUBusDataLoadingManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusDataLoadingManager.h"
/*
NSString const *newBrunswickAgency = @"rutgers";
NSString const *newarkAgency = @"rutgers-newark";
*/



@interface RUBusDataLoadingManager ()
@property NSDictionary *agencyManagers;
@end

@implementation RUBusDataLoadingManager
+(instancetype)sharedInstance{
    static RUBusDataLoadingManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RUBusDataLoadingManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.agencyManagers = @{};
    }
    return self;
}


-(void)fetchAllStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler{
    
}
-(void)fetchAllRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler{
    
}
-(void)fetchActiveStopsForAgency:(NSString *)agency completion:(void(^)(NSArray *stops, NSError *error))handler{
    
}
-(void)fetchActiveRoutesForAgency:(NSString *)agency completion:(void(^)(NSArray *routes, NSError *error))handler{
    
}

@end
