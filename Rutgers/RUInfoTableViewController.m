//
//  RUInfoTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUInfoTableViewController.h"
#import "RUComponentDelegate.h"
#import <MessageUI/MessageUI.h>
#import <PBWebViewController.h>

@interface RUInfoTableViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic) id <RUComponentDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableViewCell *callCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *textCells;

@end

@implementation RUInfoTableViewController
+(instancetype)component{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil];
    RUInfoTableViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"RUInfoTableViewController"];
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"telprompt://732-445-INFO"]]) {
        self.callCell.textLabel.textColor = [UIColor grayColor];
        self.callCell.userInteractionEnabled = NO;
    }
    
    if (![MFMessageComposeViewController canSendText]) {
        for (UITableViewCell* textCell in self.textCells) {
           textCell.textLabel.textColor = [UIColor grayColor];
           textCell.userInteractionEnabled = NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://732-445-INFO"]];
            break;
        }
        case 1:
            switch (indexPath.row) {
                case 1:
                    //text rutgers to 66746
                    [self presentMessageComposeViewControllerWithRecipients:@[@"66746"] body:@"rutgers"];
                    break;
                case 3:
                    //text your question to 66746
                    [self presentMessageComposeViewControllerWithRecipients:@[@"66746"] body:nil];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            //email col henry
            [self presentMailCompseViewControllerWithRecipients:@[@"colhenry@rci.rutgers.edu"] body:nil];
            break;
        case 3:
            //visit website
        {
           // TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[]];
        }
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
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
-(void)presentMailCompseViewControllerWithRecipients:(NSArray *)recipients body:(NSString *)body{
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    [mailVC setMessageBody:body isHTML:NO];
    [mailVC setToRecipients:recipients];;
    mailVC.mailComposeDelegate = self;
    [self presentViewController:mailVC animated:YES completion:^{
        
    }];
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

