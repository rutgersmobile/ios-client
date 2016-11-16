//
//  DynamicDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"

/**
    This is the class used to model the infomation for the dynamic tbvc
 */
@interface DynamicDataSource : BasicDataSource
-(instancetype)initWithChannel:(NSDictionary *)channel ;
-(instancetype)initWithChannel:(NSDictionary *)channel forLayout:(BOOL)layout  NS_DESIGNATED_INITIALIZER;
@property NSDictionary *channel;
-(void)loadContentWithAnyBlock:(void(^)(void)) completionBlock;

// TODO simple solution for now. Rewirte the data source in swift later
@property (nonatomic) NSArray * bannerItems; // this stores the elements to be kept in the banner. This breaks all oop good practices. Rewrite.
@end
