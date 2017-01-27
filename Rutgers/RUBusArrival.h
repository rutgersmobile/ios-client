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
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, readonly) NSInteger minutes;
@property (nonatomic, readonly) NSInteger seconds;
@property (nonatomic, readonly) NSString* vehicle;
@end
