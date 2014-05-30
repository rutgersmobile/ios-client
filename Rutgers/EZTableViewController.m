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
@property NSMutableArray *sections;
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
   // self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (EZTableViewRow *)rowForIndexPath:(NSIndexPath *)indexPath{
    EZTableViewSection *ezSection = self.sections[indexPath.section];
    return [ezSection rowAtIndex:indexPath.row];
}

-(void)addSection:(EZTableViewSection *)section{
    [self.sections addObject:section];
}

-(void)insertSection:(EZTableViewSection *)section atIndex:(NSInteger)index{
    [self.sections insertObject:self atIndex:index];
}

-(void)removeAllSections{
    [self.sections removeAllObjects];
}

#pragma mark - TableView Data source
-(NSString *)identifierForRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    return [self rowForIndexPath:indexPath].identifier;
}
-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewRow *row = [self rowForIndexPath:indexPath];
    [row setupCell:cell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    EZTableViewSection *ezSection = self.sections[section];
    return ezSection.numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    EZTableViewSection *ezSection = self.sections[section];
    return ezSection.title;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewRow *row = [self rowForIndexPath:indexPath];
    if (row.didSelectRowBlock) {
        row.didSelectRowBlock();
    }
}
@end
