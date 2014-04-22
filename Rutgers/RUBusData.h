//
//  RUBusData.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RUBusDataDelegate <NSObject>

@end

@interface RUBusData : NSObject
-(void)getAgencyConfigWithCompletion:(void (^)(void))completionBlock;
@end
