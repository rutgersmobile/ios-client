//
//  RUPrediction.h
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The bus prediction object holds the predictions for a singlular route and stop combination.
 Also holds any message associated with a stop and route:w
 */
@interface RUBusPrediction : NSObject
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, readonly) NSString *stopTag;
@property (nonatomic, readonly) NSString *routeTag;

@property (nonatomic, readonly) NSString *directionTitle;
@property (nonatomic, readonly) NSString *stopTitle;
@property (nonatomic, readonly) NSString *routeTitle;

@property (nonatomic, readonly) BOOL active;
@property (nonatomic) NSArray *arrivals;

@property (nonatomic , readonly) NSArray * messages ;
@end
