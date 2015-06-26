//
//  RUInfoTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUInfoTableViewController.h"
#import "DataTuple.h"
#import "RUInfoDataSource.h"
#import "TableViewController_Private.h"
#import <MessageUI/MessageUI.h>

@interface RUInfoTableViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation RUInfoTableViewController

+(instancetype)newWithChannel:(NSDictionary *)channel{
    return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.dataSource = [[RUInfoDataSource alloc] init];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = [self.dataSource itemAtIndexPath:indexPath];
    NSString *type = item[@"type"];
    
    if (![RUInfoDataSource buttonTypeEnabled:type]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    if ([type isEqualToString:@"callButton"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel://" stringByAppendingString:item[@"number"]]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([type isEqualToString:@"textButton"]) {
        [self presentMessageComposeViewControllerWithRecipients:@[item[@"number"]] body:item[@"body"]];
    } else if ([type isEqualToString:@"emailButton"]) {
        [self presentMailCompseViewControllerWithRecipients:@[item[@"email"]] body:item[@"body"]];
    } else if ([type isEqualToString:@"webButton"]) {
        [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : self.title, @"view" : @"www", @"url" : item[@"url"]}] animated:YES];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![super tableView:tableView shouldHighlightRowAtIndexPath:indexPath]) return NO;
    NSDictionary *item = [self.dataSource itemAtIndexPath:indexPath];
    NSString *type = item[@"type"];
    return ![type isEqualToString:@"text"];
}

/**
 *  Present the user a view controller to send a text message
 *
 *  @param recipients An array of text message recipients
 *  @param body       The body of the text message
 */
-(void)presentMessageComposeViewControllerWithRecipients:(NSArray *)recipients body:(NSString *)body{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        messageVC.body = body;
        messageVC.recipients = recipients;
        messageVC.messageComposeDelegate = self;
        [self presentViewController:messageVC animated:YES completion:^{
            
        }];
    }
}

/**
 *  Present the user a view controller to send a email
 *
 *  @param recipients An array of mail recipients
 *  @param body       The body of the mail message
 */
-(void)presentMailCompseViewControllerWithRecipients:(NSArray *)recipients body:(NSString *)body{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        [mailVC setMessageBody:body isHTML:NO];
        [mailVC setToRecipients:recipients];
        mailVC.mailComposeDelegate = self;
        [self presentViewController:mailVC animated:YES completion:^{
            
        }];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end

