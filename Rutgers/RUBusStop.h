//
//  RUBusStop.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RUBusStop : NSObject
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@property (nonatomic) NSString *tag;
@property (nonatomic) NSString *title;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSInteger stopId;
@property (nonatomic) NSArray *routes;  // Why is the multiple routes for each stop. Is it combining multiple buses going through the stop into this array ? 
@property (nonatomic, readonly, copy) NSArray *activeRoutes;
@property (nonatomic) NSString *agency; // How is the agency specified ? 

@end
