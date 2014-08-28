//
//  RUSOCCourseHeaderDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUSOCCourseHeaderDataSource.h"
#import "DataTuple.h"

@implementation RUSOCCourseHeaderDataSource

-(void)setHeaderItems:(NSDictionary *)headerItems{
    NSMutableArray *items = [NSMutableArray array];
    if (headerItems[@"subjectNotes"]) {
        [items addObject:[[DataTuple alloc] initWithTitle:headerItems[@"subjectNotes"] object:nil]];
    }
    if (headerItems[@"synopsisUrl"]) {
        [items addObject:[[DataTuple alloc] initWithTitle:@"Synopsis" object:headerItems[@"synopsisUrl"]]];
    }
    if (headerItems[@"preReqNotes"]) {
        [items addObject:[[DataTuple alloc] initWithTitle:@"Prerequisites" object:headerItems[@"preReqNotes"]]];
    }

    
    self.items = items;
}

-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    DataTuple *item = [self itemAtIndexPath:indexPath];
    cell.textLabel.text = item.title;
    cell.accessoryType = item.object ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

@end
