//
//  EZTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/19/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewController.h"
#import "EZTableViewSection.h"
#import "EZTableViewRightDetailRow.h"
#import "ALTableViewRightDetailCell.h"
#import "ALTableViewTextCell.h"

@interface EZTableViewController ()
@property (nonatomic) NSMutableArray *searchResultSections;
@end

@implementation EZTableViewController
-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.sections = [NSMutableArray array];
        self.searchResultSections = [NSMutableArray array];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
}

-(void)startNetworkLoad{
    if (!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(startNetworkLoad) forControlEvents:UIControlEventValueChanged];
    }
    [self.refreshControl beginRefreshing];
}

-(void)networkLoadSucceeded{
    [self.refreshControl endRefreshing];
}

-(void)networkLoadFailed{
    [self.refreshControl endRefreshing];
}

-(NSArray *)sectionsForTableView:(UITableView *)tableView{
    if (tableView == self.tableView) {
        return self.sections;
    } else if (tableView == self.searchController.searchResultsTableView) {
        return self.searchResultSections;
    }
    return nil;
}

- (EZTableViewSection *)sectionInTableView:(UITableView *)tableView atIndex:(NSInteger)section {
    return [self sectionsForTableView:tableView][section];
}

- (EZTableViewAbstractRow *)rowInTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath{
    return [[self sectionInTableView:tableView atIndex:indexPath.section] rowAtIndex:indexPath.row];
}

-(void)addSection:(EZTableViewSection *)section{
    [self insertSection:section atIndex:self.sections.count];
}

-(void)insertSection:(EZTableViewSection *)section atIndex:(NSInteger)index{
    [self.sections insertObject:section atIndex:index];
    if (self.isViewLoaded) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)replaceSectionAtIndex:(NSInteger)index withSection:(EZTableViewSection *)section{
    self.sections[index] = section;
    [self reloadSectionAtIndex:index];
}

-(void)replaceSection:(EZTableViewSection *)oldSection withSection:(EZTableViewSection *)newSection{
    NSInteger index = [self indexOfSection:oldSection];
    [self replaceSectionAtIndex:index withSection:newSection];
}

-(void)removeAllSections{
    if (self.isViewLoaded) {
        NSInteger count = self.sections.count;
        [self.tableView beginUpdates];
        [self.sections removeAllObjects];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } else {
        [self.sections removeAllObjects];
    }
}

-(void)reloadSection:(EZTableViewSection *)section{
    NSInteger index = [self indexOfSection:section];
    [self reloadSectionAtIndex:index];
}

-(void)reloadSectionAtIndex:(NSInteger)index{
    if (self.isViewLoaded) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(NSInteger)indexOfSection:(EZTableViewSection *)section{
    return [self.sections indexOfObject:section];
}
-(EZTableViewSection *)sectionAtIndex:(NSInteger)index{
    return self.sections[index];
}

#pragma mark - TableView Data source
-(NSString *)identifierForCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    return [self rowInTableView:tableView forIndexPath:indexPath].identifier;
}

-(void)setupCell:(ALTableViewAbstractCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[self rowInTableView:tableView forIndexPath:indexPath] setupCell:cell];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self sectionInTableView:tableView atIndex:section].numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self sectionsForTableView:tableView].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self sectionInTableView:tableView atIndex:section].title;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EZTableViewAbstractRow *row = [self rowInTableView:tableView forIndexPath:indexPath];
    if (row.didSelectRowBlock) {
        row.didSelectRowBlock();
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self rowInTableView:tableView forIndexPath:indexPath].shouldHighlight;
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:[self rowInTableView:tableView forIndexPath:indexPath].textRepresentation];
    }
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender{
    if (action == @selector(copy:)) return YES;
    return NO;
}

-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath{
    return [self rowInTableView:tableView forIndexPath:indexPath].shouldCopy;
}

#pragma mark - SearchDisplayController Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterForSearchString:searchString];
    return YES;
}

-(void)filterForSearchString:(NSString *)string{
    @synchronized (self.searchResultSections) {
        [self.searchResultSections removeAllObjects];
        for (EZTableViewSection *section in self.sections) {
            NSArray *filteredRows = [section.allRows filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EZTableViewAbstractRow *row, NSDictionary *bindings) {
                NSString *text = row.textRepresentation;
                return ([text rangeOfString:string options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound);
            }]];
            if (filteredRows.count) {
                EZTableViewSection *filteredSection = [[EZTableViewSection alloc] initWithSectionTitle:section.title rows:filteredRows];
                [self.searchResultSections addObject:filteredSection];
            }
        }
    }
}

@end
