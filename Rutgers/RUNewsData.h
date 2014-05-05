//
//  RUNewsData.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/1/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUNewsData : NSObject
+(RUNewsData *)sharedData;
-(void)getNewsWithCompletion:(void (^)(NSDictionary *response))completionBlock;
@end
