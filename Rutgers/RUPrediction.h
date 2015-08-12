//
//  RUPrediction.h
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUPrediction : NSObject
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, readonly) NSString *stopTag;
@property (nonatomic, readonly) NSString *routeTag;

@property (nonatomic, readonly) NSString *directionTitle;
@property (nonatomic, readonly) NSString *stopTitle;
@property (nonatomic, readonly) NSString *routeTitle;

@property (nonatomic, readonly) BOOL active;
@property (nonatomic, readonly) NSArray *arrivals;
@end
