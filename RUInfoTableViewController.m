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
#import <TSMiniWebBrowser.h>

@interface RUInfoTableViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property MFMessageComposeViewController *messageController;
@property MFMailComposeViewController *mailController;

@end


@implementation RUInfoTableViewController
-(void)setDelegate:(id<RUComponentDelegate>)delegate{
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(onMenuButtonTapped)]) {
        // delegate expects menu button notification, so let's create and add a menu button
        UIBarButtonItem * btn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(onMenuButtonTapped)];
        self.navigationItem.leftBarButtonItem = btn;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://732-445-INFO"]];
            break;
        case 1:
            switch (indexPath.row) {
                case 1:
                    //text rutgers to 66746
                    [self presentMessageCompseViewControllerWithRecipients:@[@"66746"] body:@"rutgers"];
                    break;
                case 3:
                    //text your question to 66746
                    [self presentMessageCompseViewControllerWithRecipients:@[@"66746"] body:nil];
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
-(void)presentMessageCompseViewControllerWithRecipients:(NSArray *)recipients body:(NSString *)body{
    if([MFMessageComposeViewController canSendText]){
        self.messageController = [[MFMessageComposeViewController alloc] init];
        self.messageController.body = body;
        self.messageController.recipients = recipients;
        self.messageController.messageComposeDelegate = self;
        [self presentViewController:self.messageController animated:YES completion:^{
            
        }];
    } else {
        
    }
}
-(void)presentMailCompseViewControllerWithRecipients:(NSArray *)recipients body:(NSString *)body{
    self.mailController = [[MFMailComposeViewController alloc] init];
    [self.mailController setMessageBody:body isHTML:NO];
    [self.mailController setToRecipients:recipients];;
    self.mailController.mailComposeDelegate = self;
    [self presentViewController:self.mailController animated:YES completion:^{
        
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
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end

