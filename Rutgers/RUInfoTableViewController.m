//
//  RUInfoTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUInfoTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "EZDataSource.h"
#import "EZTableViewTextRow.h"
#import "ALTableViewTextCell.h"
#import "RUChannelManager.h"


@interface RUInfoTableViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation RUInfoTableViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUInfoTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
}

-(id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        [self makeSections];
    }
    return self;
}

/**
 *  Build the data structure containing all the information pertinent to the ru-info channel
 */
-(void)makeSections{
    NSArray *infoData = @[@{@"header" :@"Call RU-Info",
                            @"body" : @[@{@"type" : @"text" , @"text" : @"Contact a helpful Information Assistant at RU-info with your Rutgers questions by calling, texting, or email."},
                                        @{@"type" : @"callButton", @"text" : @"Call (732-445-INFO)", @"number" : @"telprompt://732-445-INFO"}]},
                          
                          @{@"header" :@"Text RU-Info",
                            @"body" : @[@{@"type" : @"text" , @"text" : @"Text RU-info with your question. To sign up for RU-info TEXT:"},
                                        @{@"type" : @"textButton", @"text" : @"Text 'Rutgers' to 66746", @"number" : @"66746", @"body" : @"Rutgers"},
                                        @{@"type" : @"text" , @"text" : @"Or, if you have already signed up:"},
                                        @{@"type" : @"textButton" , @"text" : @"Text your question to 66746", @"number" : @"66746"}]
                            },
                          
                          @{@"header" :@"Email RU-Info",
                            @"body" : @[@{@"type" : @"text" , @"text" : @"Email RU-Info with your question:"},
                                        @{@"type" : @"emailButton", @"text" : @"Email Colonel Henry", @"email" : @"colhenry@rci.rutgers.edu"}]
                            },
                          
                          @{@"header" :@"Visit Website",
                            @"body" : @[@{@"type" : @"text" , @"text" : @"For hours and additional info, visit us online:"},
                                        @{@"type" : @"webButton", @"text" : @"Visit Website", @"url" : @"http://m.rutgers.edu/ruinfo.html"}]
                            }];
    
    //Create centered paragraph style for use below
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    //These attributes will be applied to all the text onscreen that is not a button
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17], NSParagraphStyleAttributeName : paragraphStyle};
   
    //These attributes will be applied to all buttons
    NSDictionary *buttonAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : self.view.tintColor};
    NSDictionary *disabledButtonAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    
    //Loop through the sections in infoData
    for (NSDictionary *sectionDictionary in infoData) {
        
        //Make a new section
        EZDataSourceSection *section = [[EZDataSourceSection alloc] initWithSectionTitle:sectionDictionary[@"header"]];
        
        //Loop through all the body rows
        for (NSDictionary *rowDictionary in sectionDictionary[@"body"]) {
            NSString *string = rowDictionary[@"text"];
            NSString *type = rowDictionary[@"type"];
            EZTableViewTextRow *row = [[EZTableViewTextRow alloc] init];
            __weak typeof(self) weakSelf = self;
            if ([type isEqualToString:@"text"]) {
                //Configure for static text
                row.shouldHighlight = NO;
                row.attributedText = [[NSAttributedString alloc] initWithString:string attributes:textAttributes];
            } else {
                //Configure button
                if ([self typeEnabled:type]) {
                    //If the buttons action can be handled, figure out its type and set up the action
                    row.attributedText = [[NSAttributedString alloc] initWithString:string attributes:buttonAttributes];
                    if ([type isEqualToString:@"callButton"]) {
                        row.didSelectRowBlock = ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rowDictionary[@"number"]]];
                        };
                    } else if ([type isEqualToString:@"textButton"]) {
                        row.didSelectRowBlock = ^{
                            [weakSelf presentMessageComposeViewControllerWithRecipients:@[rowDictionary[@"number"]] body:rowDictionary[@"body"]];
                        };
                    } else if ([type isEqualToString:@"emailButton"]) {
                        row.didSelectRowBlock = ^{
                            [weakSelf presentMailCompseViewControllerWithRecipients:@[rowDictionary[@"email"]] body:rowDictionary[@"body"]];
                        };
                    } else if ([type isEqualToString:@"webButton"]) {
                        row.didSelectRowBlock = ^{
                            [weakSelf.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : self.title, @"view" : @"www", @"url" : rowDictionary[@"url"]}] animated:YES];
                        };
                    }
                } else {
                    //Otherwise grey out the button
                    row.attributedText = [[NSAttributedString alloc] initWithString:string attributes:disabledButtonAttributes];
                }
                row.showsDisclosureIndicator = NO;
            }
            [section addItem:row];
        }
        [self.dataSource addSection:section];
    }
}

/**
 *  Checks if a specified button action type can be handled
 *
 *  @param type callButton, textButton, emailButton, webButton
 *
 *  @return YES if the action can be handled, no otherwise
 */
-(BOOL)typeEnabled:(NSString *)type{
     if ([type isEqualToString:@"callButton"]) {
         return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"telprompt://732-445-INFO"]];
    } else if ([type isEqualToString:@"textButton"]) {
        return [MFMessageComposeViewController canSendText];
    } else if ([type isEqualToString:@"emailButton"]) {
        return [MFMailComposeViewController canSendMail];
    } else if ([type isEqualToString:@"webButton"]) {
        return YES;
    }
    return NO;
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
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    [mailVC setMessageBody:body isHTML:NO];
    [mailVC setToRecipients:recipients];
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

