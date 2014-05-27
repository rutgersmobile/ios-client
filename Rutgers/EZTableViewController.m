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
#import "EZTableViewCell.h"

@interface EZTableViewController ()
@property NSMutableArray *sections;
@property NSMutableDictionary *layoutCells;
@end

@implementation EZTableViewController

-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.sections = [NSMutableArray array];
        self.layoutCells = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[EZTableViewCell class] forCellReuseIdentifier:@"EZTableViewCell"];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    EZTableViewSection *ezSection = self.sections[section];
    return ezSection.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewRow *row = [self rowForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
    [row setupCell:cell];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    EZTableViewSection *ezSection = self.sections[section];
    return ezSection.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewRow *row = [self rowForIndexPath:indexPath];
    
    UITableViewCell *layoutCell = [self layoutCellWithIdentifier:row.identifier];
    
    [row setupCell:layoutCell];
    
    [layoutCell setNeedsUpdateConstraints];
    [layoutCell updateConstraintsIfNeeded];
    
    layoutCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(layoutCell.bounds));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [layoutCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for internal rounding errors that are occasionally observed in
    // the Auto Layout engine, which cause the returned height to be slightly too small in some cases.
    height += 1;
    
    return height;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 500*320.0/CGRectGetWidth(tableView.bounds);
}
-(UITableViewCell *)layoutCellWithIdentifier:(NSString *)identifier{
    UITableViewCell *cell = self.layoutCells[identifier];
    if (!cell) {
        cell = [[NSClassFromString(identifier) alloc] init];
        self.layoutCells[identifier] = cell;
    }
    return cell;
}
#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewRow *row = [self rowForIndexPath:indexPath];
    if (row.didSelectRowBlock) {
        row.didSelectRowBlock();
    }
}
@end
