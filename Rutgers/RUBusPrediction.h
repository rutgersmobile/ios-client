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
@property (nonatomic) BOOL active;
@property (nonatomic) NSString* routeTitle;
@property (nonatomic) NSString* stopTitle;
@property (nonatomic , readonly) NSString* stop_id;
@property (nonatomic) NSArray* messages;
@property (nonatomic) NSArray* arrivals;
@end
