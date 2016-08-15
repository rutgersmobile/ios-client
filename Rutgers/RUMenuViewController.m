//
//  RUMenuViewController.m
//  Rutgers
//
//  Created by Russell Frank on 1/12/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMenuViewController.h"
#import "UITableView+Selection.h"
#import "UIApplication+StatusBarHeight.h"
#import "TableViewController_Private.h"
#import "RURootController.h"
#import "RUDefines.h"
#import "Rutgers-Swift.h"

// for moving the cells
#import "DataSource_Private.h"

/*
    RU Menu is shown within the slide menu bar
    This acts as the starting point for the app.

    If a last channel exits , then its view controller is initialized .. After this initilization . The RUMenu is initialized.
 */


@interface RUMenuViewController ()
@property (nonatomic) UIView *paddingView;
@end

@implementation RUMenuViewController
- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = @"Menu";
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.delegate menuWillAppear];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.delegate menuWillDisappear];
}




-(void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    self.dataSource = [[RUMenuDataSource alloc] init];
 
    /*
        Sets the graphics opt of the menu slide bar
     */
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 32+kLabelHorizontalInsets*2, 0, 0);
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
   
    /*
        Location where the menu bar moves to the previous selected item
     */
    NSIndexPath *indexPath = [[self.dataSource indexPathsForItem:[RURootController sharedInstance].selectedItem] lastObject];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
   
         //   Allow user to drag and drop the cells within the menu item
     UILongPressGestureRecognizer * menuCellLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:menuCellLongPress];
    
    
}

/*
    Allow user to drag drop menu cell items
 */
-(IBAction)longPressGestureRecognized:(id)sender
{
    UILongPressGestureRecognizer * longPress = (UILongPressGestureRecognizer *) sender ;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location]; // get index path from touch location

    static UIView * viewCopy = nil ; // create a copy of the cell that will be animated into the new location
    static NSIndexPath * sourceIndexPath = nil ;
    
    
    switch (state)
    {
            // display the animation of taking the cell of the drawer and hide the original cell
        case UIGestureRecognizerStateBegan:
            {
                if(indexPath)
                {
                    sourceIndexPath = indexPath ;
                   
                    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
                 
                    
                    viewCopy = [self customViewCopyFromView:cell]; // create a copy of the cell view for animating
                   
                    // add the copy to the center of the cell , and then begin animation from that location
                    
                    __block CGPoint center = cell.center ; // center will be moved within the block
                    viewCopy.center = center ;
                    viewCopy.alpha = 0.0 ;
                    
                    [self.tableView addSubview:viewCopy];
                    [UIView animateWithDuration:0.25 animations:^
                         {
                             center.y = location.y ;
                             viewCopy.center = center ;
                             viewCopy.transform = CGAffineTransformMakeScale(1.05, 1.05);
                             viewCopy.alpha = 0.98 ;
                             
                             // Fade out the cell
                             cell.alpha = 0.0;
                         }
                         completion:^(BOOL finished)
                         {
                             cell.hidden = YES;
                         }
                     ];
                }
            break;
            }
           // display the animation for when the user the dragging the cellCopy ;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint center = viewCopy.center ;;
            center.y = location.y ;
            viewCopy.center = center ; // change the cell to new location
            
           // update data source
            [(DataSource *)self.dataSource notifyItemMovedFromIndexPath:sourceIndexPath toIndexPath:indexPath];
           
            
            sourceIndexPath = indexPath;
            break;
        }
        default:
        {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^
                {
                    
                    viewCopy.center = cell.center;
                    viewCopy.transform = CGAffineTransformIdentity;
                    viewCopy.alpha = 0.0;
                    
                    // Undo fade out.
                    cell.alpha = 1.0;
                    
                }
                completion:^(BOOL finished)
                {
                    
                    sourceIndexPath = nil;
                    [viewCopy removeFromSuperview];
                    viewCopy = nil;
                    
                }
             ];
            break;
        }
    }
    
    
    
}

/*
    Used to create the copy of the cell view which will be used animated and moved to a new location
 */
-(UIView *)customViewCopyFromView:(UIView *)inputView
{
  // Make image from input view
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    
    // create view from image
    UIView * viewCopy = [[UIImageView alloc] initWithImage:image];
    viewCopy.layer.masksToBounds = NO;
    viewCopy.layer.cornerRadius = 0.0 ;
    viewCopy.layer.shadowOffset = CGSizeMake(-5.0,0.0);
    viewCopy.layer.shadowRadius = 5.0 ;
    viewCopy.layer.shadowOpacity = 0.4 ;
    
    return viewCopy ;
}


/*
    pre auto layout
 */
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setContentInsets];
}

/*
    pre auto layout : 
    see this :
    http://stackoverflow.com/questions/1983463/whats-the-uiscrollview-contentinset-property-for
 */
-(void)setContentInsets{
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarHeight];
    UIEdgeInsets insets = UIEdgeInsetsMake(statusBarHeight, 0, 0, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

// store the state and reload
-(void)reloadTablePreservingSelectionState:(UITableView *)tableView{
    if (tableView == self.tableView) {
        [self.tableView reloadData];
        [self.tableView selectRowsAtIndexPaths:[self.dataSource indexPathsForItem:[RURootController sharedInstance].selectedItem] animated:NO];
    } else {
        [super reloadTablePreservingSelectionState:tableView];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.dataSource itemAtIndexPath:indexPath];
    
    if(DEV) NSLog(@"%@",item);
    [self.delegate menu:self didSelectItem:item];
}
@end
