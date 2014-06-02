//
//  RUReaderTableViewRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewRow.h"
#import "RUReaderTableViewCell.h"
#import <TOWebViewController.h>

@interface RUReaderTableViewRow ()
@property (nonatomic) NSDictionary *item;
@end
@implementation RUReaderTableViewRow
-(instancetype)initWithItem:(NSDictionary *)item{
    self = [super initWithIdentifier:@"RUReaderTableViewCell"];
    if (self) {
        self.item = item;
    }
    return self;
}

-(void)setupCell:(RUReaderTableViewCell *)cell{
    [cell setTitle:[self.item[@"title"] firstObject]];
    [cell setDetail:[self.item[@"description"] firstObject]];
    [cell setTime:[self.item[@"pubDate"] firstObject]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
@end
