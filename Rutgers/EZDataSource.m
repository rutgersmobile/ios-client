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

@interface EZDataSource ()
@end


@implementation EZDataSource

-(void)addSection:(EZDataSourceSection *)section{
    [self addDataSource:section];
}

-(void)insertSection:(EZDataSourceSection *)section atIndex:(NSInteger)index{
    [self insertDataSource:section atIndex:index];
}
/*
-(void)replaceSectionAtIndex:(NSInteger)index withSection:(EZDataSourceSection *)section{
    self.sections[index] = section;
    [self reloadSectionAtIndex:index];
}

-(void)replaceSection:(EZDataSourceSection *)oldSection withSection:(EZDataSourceSection *)newSection{
    NSInteger index = [self indexOfSection:oldSection];
    [self replaceSectionAtIndex:index withSection:newSection];
}*/

-(void)removeAllSections{
    [super removeAllDataSources];
}

-(void)reloadSection:(EZDataSourceSection *)section{
    [section notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:0]];
}

-(void)reloadSectionAtIndex:(NSInteger)index{
    [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:index]];
}

-(EZDataSourceSection *)sectionAtIndex:(NSInteger)index{
    return self.dataSources[index];
}

-(NSInteger)indexOfSection:(EZDataSourceSection *)section{
    return [self.dataSources indexOfObject:section];
}

-(EZTableViewAbstractRow *)itemAtIndexPath:(NSIndexPath *)indexPath{
    return [[self sectionAtIndex:indexPath.section] itemAtIndex:indexPath.row];
}


#pragma mark - Table View Data Source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    EZTableViewAbstractRow *item = [self itemAtIndexPath:indexPath];
    [item setupCell:cell];
    return cell;
}



#pragma mark - Collection View Data Source





#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewAbstractRow *row = [self itemAtIndexPath:indexPath];
    if (row.didSelectRowBlock) {
        row.didSelectRowBlock();
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self itemAtIndexPath:indexPath].shouldHighlight;
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:[self itemAtIndexPath:indexPath].textRepresentation];
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
