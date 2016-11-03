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
#import "FeedbackDataSourceDelegate.h"
#import "RUChannelManager.h"
#import "RUAnalyticsManager.h"



@interface RUFeedbackViewController () <FeedbackDataSourceDelegate>
@property (nonatomic) UIBarButtonItem *sendButton;
@end

@implementation RUFeedbackViewController
+(NSString *)channelHandle{
    return @"feedback";
}
+(void)load{
    [[RUChannelManager sharedInstance] registerClass:[self class]];
}

+(instancetype)channelWithConfiguration:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;

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
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
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
    self.sendButton.title = @"Sending...";
    self.sendButton.enabled = NO;
    [self.view endEditing:YES];
}

-(void)formDidChange{
    self.sendButton.enabled = [self validateForm];
}

-(void)formSendFailed{
    self.sendButton.title = @"Send";
    self.sendButton.enabled = YES;
    [[[UIAlertView alloc] initWithTitle:@"Failure" message:@"Your feedback has not been sent! Please check your network connection and try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

-(void)formSendSucceeded{
    self.sendButton.title = @"Send";
    [self.dataSource resetContent];
    [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Thank you for sending your feedback!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

-(void)showRUInfo{
    NSDictionary *channel = @{@"title": @"RU-Info",
                              @"view": @"ruinfo"};
    [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:channel] animated:YES];
}
@end
