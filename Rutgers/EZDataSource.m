//
//  EZTableViewDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/21/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZDataSource.h"
#import "ComposedDataSource_Private.h"
#import "EZTableViewAbstractRow.h"
#import "DataSource_Private.h"

@interface EZDataSource ()
@end

@implementation EZDataSource

-(EZTableViewAbstractRow *)itemAtIndexPath:(NSIndexPath *)indexPath{
    return [super itemAtIndexPath:indexPath];
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewAbstractRow *row = [self itemAtIndexPath:indexPath];
    if (row.didSelectRowBlock) {
        row.didSelectRowBlock();
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(BOOL)shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self itemAtIndexPath:indexPath].shouldHighlight;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self shouldHighlightItemAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [self itemAtIndexPath:indexPath].textRepresentation;
    }
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)) return YES;
    return NO;
}

-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath{
    return [self itemAtIndexPath:indexPath].shouldCopy;
}

@end
