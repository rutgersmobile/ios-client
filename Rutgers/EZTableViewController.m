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

@interface EZTableViewController () <UISearchDisplayDelegate>
@property (nonatomic) NSMutableArray *sections;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) NSMutableArray *searchResultSections;
@property (nonatomic) BOOL searchEnabled;
//@property (nonatomic) BOOL updating;
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
-(void)enableSearch{
    if (self.searchEnabled) return;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.delegate = self;
    
    [self.searchController.searchResultsTableView registerClass:[ALTableViewRightDetailCell class] forCellReuseIdentifier:@"ALTableViewRightDetailCell"];
    [self.searchController.searchResultsTableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:@"ALTableViewTextCell"];

    self.tableView.tableHeaderView = searchBar;

    self.searchEnabled = YES;
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
    [self.sections addObject:section];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.sections.count-1] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)insertSection:(EZTableViewSection *)section atIndex:(NSInteger)index{
    [self.sections insertObject:section atIndex:index];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)removeAllSections{
    NSInteger count = self.sections.count;
    [self.sections removeAllObjects];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - TableView Data source
-(NSString *)identifierForRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
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

#pragma mark - SearchDisplayController Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterForSearchString:searchString];
    return YES;
}

-(void)filterForSearchString:(NSString *)string{
    [self.searchResultSections removeAllObjects];
    for (EZTableViewSection *section in self.sections) {
        NSArray *filteredRows = [section.allRows filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            NSString *text;
            if ([evaluatedObject respondsToSelector:@selector(text)]) {
                text = [evaluatedObject text];
            } else if ([evaluatedObject respondsToSelector:@selector(attributedText)]) {
                text = [[evaluatedObject attributedText] string];
            } else {
                return NO;
            }
            return ([text rangeOfString:string options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound);
        }]];
        if (filteredRows.count) {
            EZTableViewSection *filteredSection = [[EZTableViewSection alloc] initWithSectionTitle:section.title rows:filteredRows];
            [self.searchResultSections addObject:filteredSection];
        }
    }
}

@end
