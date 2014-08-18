//
//  SegmentedTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/7/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "SegmentedTableViewController.h"
#import "SegmentedDataSource.h"

@interface SegmentedTableViewController ()
@end

@implementation SegmentedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.segmentedControl = [[UISegmentedControl alloc] init];
    
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barArray = @[flexibleSpace,segmentedControlButtonItem,flexibleSpace];
    [self setToolbarItems:barArray];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;

    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;

    [self.tableView addGestureRecognizer:leftSwipe];
    [self.tableView addGestureRecognizer:rightSwipe];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.searching) {
        [self.navigationController setToolbarHidden:NO animated:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (!self.searching) {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    [super searchDisplayControllerWillBeginSearch:controller];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [super searchDisplayControllerWillEndSearch:controller];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) return;
    
    NSInteger selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex;
    if (selectedSegmentIndex == -1) return;
    switch (swipeGestureRecognizer.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            if (selectedSegmentIndex < self.segmentedControl.numberOfSegments - 1) [self selectSegmentIndex:++selectedSegmentIndex];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if (selectedSegmentIndex > 0) [self selectSegmentIndex:--selectedSegmentIndex];
            break;
        default:
            break;
    }
}

-(void)selectSegmentIndex:(NSInteger)index{
    [UIView animateWithDuration:0.15 animations:^{
        [self.segmentedControl setSelectedSegmentIndex:index];
    }];
    
    if ([self.dataSource isKindOfClass:[SegmentedDataSource class]]) {
        SegmentedDataSource *segmentedDataSource = (SegmentedDataSource*)self.dataSource;
        [segmentedDataSource setSelectedDataSourceIndex:index animated:YES];
    }
}

-(void)setDataSource:(DataSource *)dataSource{
    if ([self.dataSource isEqual:dataSource]) return;
    [super setDataSource:dataSource];
    
    if ([dataSource isKindOfClass:[SegmentedDataSource class]]) {
        SegmentedDataSource *segmentedDataSource = (SegmentedDataSource*)dataSource;
        [segmentedDataSource configureSegmentedControl:self.segmentedControl];
    }
}

@end
