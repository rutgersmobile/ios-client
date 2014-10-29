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
#import "ALTTableViewController_Private.h"
#import "FeedbackDataSourceDelegate.h"

@interface RUFeedbackViewController () <FeedbackDataSourceDelegate>
@property (nonatomic) UIBarButtonItem *sendButton;
@end

@implementation RUFeedbackViewController

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[[self class] alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    RUFeedbackDataSource *feedback = [[RUFeedbackDataSource alloc] init];
    feedback.feedbackDelegate = self;
    self.dataSource = feedback;

    self.sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem = self.sendButton;
    self.sendButton.enabled = NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DataSource *dataSource = [(ComposedDataSource *)self.dataSource dataSourceAtIndex:indexPath.section];

    if ([dataSource isKindOfClass:[AlertDataSource class]]) {
        AlertDataSource *alertDataSource = (AlertDataSource *)dataSource;
        [alertDataSource showAlertInView:tableView];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    DataSource *dataSource = [(ComposedDataSource *)self.dataSource dataSourceAtIndex:indexPath.section];
    return [dataSource isKindOfClass:[AlertDataSource class]];
}

-(BOOL)validateForm{
    return [(RUFeedbackDataSource *)self.dataSource validateForm];
}

-(void)updateInterface{
    self.sendButton.enabled = [self validateForm];
}

-(void)send{
    [(RUFeedbackDataSource *)self.dataSource send];
    self.sendButton.enabled = NO;
}

-(void)formDidChange{
    self.sendButton.enabled = [self validateForm];
}

-(void)formSendFailed{
    self.sendButton.enabled = YES;
    [[[UIAlertView alloc] initWithTitle:@"Failure" message:@"Your feedback has not been sent!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

-(void)formSendSucceeded{
    [self.view endEditing:YES];
    [self.dataSource resetContent];
    [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Your feedback has been sent to the abyss!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}
@end
