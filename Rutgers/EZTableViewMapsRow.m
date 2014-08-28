//
//  EZTableViewMapsRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewMapsRow.h"
#import "RUMapsTableViewCell.h"
#import "RUPlace.h"

@interface EZTableViewMapsRow ()
@property (nonatomic) RUPlace *place;
@end
@implementation EZTableViewMapsRow
-(id)init{
    self = [super initWithIdentifier:NSStringFromClass([RUMapsTableViewCell class])];
    if (self) {
    }
    return self;
}

-(instancetype)initWithPlace:(RUPlace *)place{
    self = [self init];
    if (self) {
        self.place = place;
    }
    return self;
}

-(void)setupCell:(RUMapsTableViewCell *)cell{
    cell.place = self.place;
}

@end
