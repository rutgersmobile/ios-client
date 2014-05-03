//
//  RUPlacesData.h
//  Rutgers
//
//  Created by Kyle Bailey on 4/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUPlacesData : NSObject
-(void)queryPlacesWithString:(NSString *)query completion:(void (^)(NSArray *results))completionBlock;
-(void)getRecentPlacesWithCompletion:(void (^)(NSArray *recents))completionBlock;
-(void)userDidSelectPlace:(NSDictionary *)place;
+(RUPlacesData *)sharedInstance;
@end
