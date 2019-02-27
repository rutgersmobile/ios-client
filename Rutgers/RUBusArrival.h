//
//  RUArrival.h
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The bus arrival holds the minutes and seconds for an arrival inside a prediction object
 */
@interface RUBusArrival : NSObject
-(instancetype)initWithDictionary:(NSDictionary *)dictionary generatedOn:(NSDate*)genDate;
@property (nonatomic, readonly) NSInteger minutes;
@property (nonatomic, readonly) NSInteger seconds;
@property (nonatomic, readonly) NSDate* savedDate;
@property (nonatomic, readonly) NSString* route_id;
@property (nonatomic) NSString* vehicle;
@end
