//
//  RUFoodData.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUFoodData : NSObject
+(RUFoodData *)sharedInstance;
-(void)getFoodWithCompletion:(void (^)(NSArray *response))completionBlock;
@end
