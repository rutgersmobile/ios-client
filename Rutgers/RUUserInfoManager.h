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

-(void)getUserInfoIfNeededWithCompletion:(dispatch_block_t)completion;

@property (nonatomic) NSDictionary *campus;
@property (nonatomic) NSDictionary *userRole;
@property (readonly) NSArray *campuses;
@property (readonly) NSArray *userRoles;

-(void)performInCampusPriorityOrderWithNewBrunswickBlock:(dispatch_block_t)newBrunswickBlock newarkBlock:(dispatch_block_t)newarkBlock camdenBlock:(dispatch_block_t)camdenBlock;

@end
