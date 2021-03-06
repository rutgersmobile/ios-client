//
//  DataTupleDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TupleDataSource.h"
#import "DataTuple.h"
#import "ALTableViewTextCell.h"
#import "DataSource_Private.h"

@implementation TupleDataSource
-(instancetype)init{
    self = [super init];
    if (self) {
        self.showsDisclosureIndicator = YES;
    }
    return self;
}

-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *tuple = [self itemAtIndexPath:indexPath];
    cell.textLabel.text = tuple.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
