//
//  MenuDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "MenuDataSource.h"
#import "NativeChannelsDataSource.h"
#import "WebLinksDataSource.h"

@implementation MenuDataSource
-(id)init{
    self = [super init];
    if (self) {
        [self addDataSource:[[NativeChannelsDataSource alloc] init]];
        [self addDataSource:[[WebLinksDataSource alloc] init]];
        
        MenuBasicDataSource *optionsDataSource = [[MenuBasicDataSource alloc] init];
        optionsDataSource.items = @[@{@"title" : @"Options", @"view" : @"options"}];
        [self addDataSource:optionsDataSource];
    }
    return self;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
@end
