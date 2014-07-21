//
//  RUBusDataAgencyManager.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/17/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUBusDataAgencyManager.h"

#define URLS @{newBrunswickAgency: @"rutgersrouteconfig.txt", newarkAgency: @"rutgers-newarkrouteconfig.txt"}
#define ACTIVE_URLS @{newBrunswickAgency: @"nbactivestops.txt", newarkAgency: @"nwkactivestops.txt"}

@interface RUBusDataAgencyManager ()
@property NSString *agency;
@end

@implementation RUBusDataAgencyManager
-(instancetype)initWithAgency:(NSString *)agency{
    self = [super init];
    if (self) {
        self.agency = agency;
    }
    return self;
}

+(instancetype)managerForAgency:(NSString *)agency{
    return [[self alloc] initWithAgency:agency];
}

-(void)fetchAllStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler{
    
}

-(void)fetchAllRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler{
    
}

-(void)fetchActiveStopsWithCompletion:(void(^)(NSArray *stops, NSError *error))handler{
    
}

-(void)fetchActiveRoutesWithCompletion:(void(^)(NSArray *routes, NSError *error))handler{
    
}
@end
