//
//  RUBusRoute.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RUBusRoute : NSObject
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *directions;
@property (nonatomic, readonly) NSArray *stops;

@property (nonatomic) NSString *tag;
@property (nonatomic) BOOL active;
@property (nonatomic) NSString *agency;

@end
