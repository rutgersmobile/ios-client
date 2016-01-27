//
//  RUUserInfoManager.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RUFavorite;

extern NSString *const userInfoManagerDidChangeInfoKey;
extern NSString *const userInfoManagerDidChangeFavoritesKey;

@interface RUUserInfoManager : NSObject

+(void)performInCampusPriorityOrderWithNewBrunswickBlock:(dispatch_block_t)newBrunswickBlock newarkBlock:(dispatch_block_t)newarkBlock camdenBlock:(dispatch_block_t)camdenBlock;

+(NSDictionary *)currentCampus;
+(void)setCurrentCampus:(NSDictionary *)currentCampus;
+(NSArray *)campuses;

+(NSDictionary *)currentUserRole;
+(void)setCurrentUserRole:(NSDictionary *)currentUserRole;
+(NSArray *)userRoles;

-(void)getUserInfoIfNeededWithCompletion:(dispatch_block_t)completion;

+(NSArray <RUFavorite *>*)favorites;
+(void)addFavorite:(RUFavorite *)favorite;
+(void)removeFavorite:(RUFavorite *)favorite;

@end
