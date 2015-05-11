//
//  MenuDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "MenuDataSource.h"
#import "DataSource_Private.h"
#import "NativeChannelsDataSource.h"
#import "WebLinksDataSource.h"

@implementation MenuDataSource
-(id)init{
    self = [super init];
    if (self) {
        [self addDataSource:[[NativeChannelsDataSource alloc] init]];
        [self addDataSource:[[WebLinksDataSource alloc] init]];
        
        NSDictionary *optionsChannel = @{@"handle" : @"options",
                                        @"title" : @"Options",
                                        @"view" : @"options",
                                        @"icon" : @"gear"
                                         };
        
        [self addDataSource:[[MenuBasicDataSource alloc] initWithItems:@[optionsChannel]]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyDidReloadData) name:userInfoManagerDidChangeCampusKey object:nil];
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
