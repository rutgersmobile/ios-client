//
//  OptionsDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "OptionsDataSource.h"
#import "StringDataSource.h"

@implementation OptionsDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        StringDataSource *preferences = [[StringDataSource alloc] initWithItems:@[@"Set Preferences"]];
        preferences.showsDisclosureIndicator = YES;

        StringDataSource *reset = [[StringDataSource alloc] initWithItems:@[@"Reset App"]];
        reset.showsDisclosureIndicator = YES;

        StringDataSource *legal = [[StringDataSource alloc] initWithItems:@[@"Legal Notices"]];
        legal.showsDisclosureIndicator = YES;

        [self addDataSource:preferences];
        [self addDataSource:reset];
        [self addDataSource:legal];
        
    }
    return self;
}
@end
