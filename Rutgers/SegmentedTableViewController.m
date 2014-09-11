//
//  SegmentedTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/7/14.
//  Copyright (c) 2014 Kyle Bailey. All rights reserved.
//

#import "SegmentedTableViewController.h"
#import "SegmentedDataSource.h"
#import "TableViewController_Private.h"

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
    self.toolbarItems = barArray;
    
    if (![[self.navigationController.viewControllers firstObject] isEqual:self]) {
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self.tableView addGestureRecognizer:leftSwipe];
        [self.tableView addGestureRecognizer:rightSwipe];
    }
    
}

#pragma mark - Segmented Control

-(void)segmentedControlIndexChanged:(UISegmentedControl *)segmentedControl{
    NSString *selectedTitle = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    [[NSUserDefaults standardUserDefaults] setObject:selectedTitle forKey:[self segmentRestorationKey]];
}

-(NSString *)segmentRestorationKey{
    return [NSString stringWithFormat:@"%@SelectedSegmentKey", NSStringFromClass([self class])];
}

-(void)restoreSelectionState{
    
    NSString *selectedTitle = [[NSUserDefaults standardUserDefaults] stringForKey:[self segmentRestorationKey]];
    
    UISegmentedControl *segmentedControl = self.segmentedControl;
    
    for (NSInteger index = 0; index < self.segmentedControl.numberOfSegments; index++) {
        if ([[segmentedControl titleForSegmentAtIndex:index] isEqualToString:selectedTitle]) {
            
            SegmentedDataSource *dataSource = (SegmentedDataSource *)self.dataSource;
            [dataSource setSelectedDataSourceIndex:index];
            self.segmentedControl.selectedSegmentIndex = index;
            
            break;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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

-(void)swipeLeft{
    NSInteger selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex;
    if (selectedSegmentIndex == -1) return;
    if (selectedSegmentIndex < self.segmentedControl.numberOfSegments - 1) [self selectSegmentIndex:++selectedSegmentIndex];
}

-(void)swipeRight{
    NSInteger selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex;
    if (selectedSegmentIndex == -1) return;
    if (selectedSegmentIndex > 0) [self selectSegmentIndex:--selectedSegmentIndex];
}

-(void)selectSegmentIndex:(NSInteger)index{
    [UIView animateWithDuration:0.15 animations:^{
        [self.segmentedControl setSelectedSegmentIndex:index];
    }];
    
    SegmentedDataSource *segmentedDataSource = (SegmentedDataSource*)self.dataSource;
    [segmentedDataSource setSelectedDataSourceIndex:index animated:YES];
    [self segmentedControlIndexChanged:self.segmentedControl];
}

-(void)setDataSource:(DataSource *)dataSource{
    if ([self.dataSource isEqual:dataSource]) return;
    [super setDataSource:dataSource];
    
    SegmentedDataSource *segmentedDataSource = (SegmentedDataSource*)dataSource;
    [segmentedDataSource configureSegmentedControl:self.segmentedControl];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlIndexChanged:) forControlEvents:UIControlEventValueChanged];
    [self setupSegmentedControlWidth:self.segmentedControl];
    [self restoreSelectionState];
}

-(void)setupSegmentedControlWidth:(UISegmentedControl *)segmentedControl{
    
    CGFloat minimumWidth = iPad() ? 240 : 160;
    if (segmentedControl.numberOfSegments >= 2) minimumWidth += iPad() ? 40 : 30;
    if (segmentedControl.numberOfSegments >= 3) minimumWidth += iPad() ? 40 : 30;
    
    CGRect viewBounds = self.view.bounds;
    CGFloat maximumWidth = MIN(CGRectGetHeight(viewBounds), CGRectGetWidth(viewBounds))-12;
    
    [segmentedControl sizeToFit];
    CGRect controlBounds = segmentedControl.bounds;
    
    if (controlBounds.size.width < minimumWidth) {
        controlBounds.size.width = minimumWidth;
    } else if (controlBounds.size.width > maximumWidth) {
        segmentedControl.apportionsSegmentWidthsByContent = YES;
        [segmentedControl sizeToFit];
        controlBounds = segmentedControl.bounds;
        
        if (controlBounds.size.width > maximumWidth){
            controlBounds.size.width = maximumWidth;
        }
    }
    
    if (!CGRectEqualToRect(controlBounds, segmentedControl.bounds)) {
        segmentedControl.bounds = controlBounds;
    }

}
@end
