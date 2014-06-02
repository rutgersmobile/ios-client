//
//  ALTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "ALTableViewController.h"
#import "ALTableViewRightDetailCell.h"

@interface ALTableViewController ()
@property (nonatomic) NSMutableDictionary *layoutCells;
@end

@implementation ALTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.layoutCells = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerClass:[ALTableViewRightDetailCell class] forCellReuseIdentifier:@"ALTableViewRightDetailCell"];
}

-(NSString *)identifierForRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    [NSException raise:@"Must override abstract methods in ALTableview" format:nil];
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewAbstractCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifierForRowInTableView:tableView atIndexPath:indexPath]];
    [self setupCell:cell inTableView:tableView forRowAtIndexPath:indexPath];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ALTableViewAbstractCell *layoutCell = [self layoutCellWithIdentifier:[self identifierForRowInTableView:tableView atIndexPath:indexPath]];

    [self setupCell:layoutCell inTableView:tableView forRowAtIndexPath:indexPath];
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

-(ALTableViewAbstractCell *)layoutCellWithIdentifier:(NSString *)identifier{
    ALTableViewAbstractCell *cell = self.layoutCells[identifier];
    if (!cell) {
        cell = [[NSClassFromString(identifier) alloc] init];
        self.layoutCells[identifier] = cell;
    }
    return cell;
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    if (self.updating) {
        return [self tableView:tableView heightForRowAtIndexPath:indexPath];
    }*/
    return 60.0;
}
-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    [NSException raise:@"Must override abstract methods in ALTableview" format:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}
-(NSInteger)numberOfSections{
    return [self numberOfSectionsInTableView:self.tableView];
}
/*
-(void)beginUpdates{
    [self.tableView beginUpdates];
    self.updating++;
}
-(void)endUpdates{
    self.updating--;
    [self.tableView endUpdates];
}*/
@end
