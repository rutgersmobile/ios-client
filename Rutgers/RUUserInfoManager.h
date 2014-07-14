//
//  RUUserInfoManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUUserInfoManager : NSObject

+(instancetype)sharedInstance;

-(BOOL)hasUserInformation;
-(void)getUserInformationCancellable:(BOOL)cancellable completion:(dispatch_block_t)completion;

@property (nonatomic) NSDictionary *campus;
@property (nonatomic) NSDictionary *userRole;
@end
