//
//  EZTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewController.h"
#import "EZTableViewSection.h"
#import "EZTableViewRow.h"
#import "ALTableViewRightDetailCell.h"

@interface EZTableViewController ()
@property (nonatomic) NSMutableArray *sections;
@end

@implementation EZTableViewController

-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.sections = [NSMutableArray array];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
}

- (EZTableViewSection *)sectionAtIndex:(NSInteger)section{
    return self.sections[section];
}

- (EZTableViewRow *)rowForIndexPath:(NSIndexPath *)indexPath{
    return [[self sectionAtIndex:indexPath.section] rowAtIndex:indexPath.row];
}

-(void)addSection:(EZTableViewSection *)section{
    [self.sections addObject:section];
}

-(void)insertSection:(EZTableViewSection *)section atIndex:(NSInteger)index{
    [self.sections insertObject:section atIndex:index];
}

-(void)removeAllSections{
    [self.sections removeAllObjects];
}

#pragma mark - TableView Data source
-(NSString *)identifierForRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    return [self rowForIndexPath:indexPath].identifier;
}

-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[self rowForIndexPath:indexPath] setupCell:cell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self sectionAtIndex:section].numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.tableView) {
        return [self.sections count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self sectionAtIndex:section].title;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewRow *row = [self rowForIndexPath:indexPath];
    if (row.didSelectRowBlock) {
        row.didSelectRowBlock();
    }
}
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self rowForIndexPath:indexPath].shouldHighlight;
}
@end
