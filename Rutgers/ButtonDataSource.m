//
//  ButtonDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ButtonDataSource.h"
#import "DataSource_Private.h"

@implementation ButtonDataSource
-(id)initWithTitle:(NSString *)title{
    self = [super initWithItems:@[title]];
    if (self) {
        
    }
    return self;
}

-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [super configureCell:cell forRowAtIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = self.on ? cell.tintColor : [UIColor grayColor];
}
@end
