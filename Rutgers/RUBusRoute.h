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
-(instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *tag;
@property (nonatomic) NSArray *stops;
@property (nonatomic) BOOL active;
@property (nonatomic) NSArray *directions;
@property (nonatomic) NSString *agency;

@end
