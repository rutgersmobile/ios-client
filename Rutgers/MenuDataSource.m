//
//  MenuDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "MenuDataSource.h"
#import "DataSource_Private.h"
#import "ChannelsDataSource.h"
#import "RUUserInfoManager.h"

@implementation MenuDataSource
-(instancetype)init{
    self = [super init];
    if (self) {
        [self addDataSource:[[ChannelsDataSource alloc] init]];
        
        NSDictionary *optionsChannel = @{@"handle" : @"options",
                                        @"title" : @"Options",
                                        @"view" : @"options",
                                        @"icon" : @"gear"
                                         };
        
        [self addDataSource:[[MenuBasicDataSource alloc] initWithItems:@[optionsChannel]]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyDidReloadData) name:userInfoManagerDidChangeInfoKey object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

@end
