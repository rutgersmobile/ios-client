//
//  RUFeedbackViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 6/25/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFeedbackViewController.h"
#import "RUFeedbackDataSource.h"
#import "RUFeedbackDataSource.h"
#import "AlertDataSource.h"
#import "TableViewController_Private.h"

@interface RUFeedbackViewController ()

@end

@implementation RUFeedbackViewController

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[[self class] alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.bounces = NO;
    
    self.dataSource = [[RUFeedbackDataSource alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardDidShow:(NSNotification *)notification{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] fromView:nil];
    
#warning fix this
    [self setBottomInsetHeight:CGRectGetHeight(kbRect)];
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height, 1, 1) animated:YES];

    /*
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }*/
}

-(void)keyboardWillHide:(NSNotification *)notification{
    [self setBottomInsetHeight:0];
}

-(void)setBottomInsetHeight:(CGFloat)height{
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    contentInsets.bottom = height;
    
    self.tableView.contentInset = contentInsets;
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.contentInset;
    scrollIndicatorInsets.bottom = height;
    
    self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
}
                                                  
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DataSource *dataSource = [(ComposedDataSource *)self.dataSource dataSourceAtIndex:indexPath.section];

    if ([dataSource isKindOfClass:[AlertDataSource class]]) {
        AlertDataSource *alertDataSource = (AlertDataSource *)dataSource;
        [alertDataSource showAlert];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    DataSource *dataSource = [(ComposedDataSource *)self.dataSource dataSourceAtIndex:indexPath.section];
    return [dataSource isKindOfClass:[AlertDataSource class]];
}

-(BOOL)validateForm{
    return NO;
}

-(void)send{
    
}

@end
