//
//  RUInfoTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUInfoTableViewController.h"
#import <MessageUI/MessageUI.h>
#import <TOWebViewController.h>
#import "EZTableViewSection.h"
#import "EZTableViewTextRow.h"
#import "RUChannelManager.h"


@interface RUInfoTableViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation RUInfoTableViewController
+(instancetype)componentForChannel:(NSDictionary *)channel{
    return [[RUInfoTableViewController alloc] init];
}
- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self makeSections];
}
-(void)makeSections{
    NSArray *infoData = @[@{@"header" :@"Call RU-Info",
                            @"body" : @[@{@"type" : @"text" , @"text" : @"Contact a helpful Information Assistant at RU-info with your Rutgers questions by calling, texting, or email."},
                                        @{@"type" : @"callButton", @"text" : @"Call (732-445-INFO)", @"number" : @"732-445-INFO"}]},
                          
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
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17], NSParagraphStyleAttributeName : paragraphStyle};
    NSDictionary *buttonAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : self.view.tintColor};
    NSDictionary *disabledButtonAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17], NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    
    for (NSDictionary *sectionDictionary in infoData) {
        EZTableViewSection *section = [[EZTableViewSection alloc] initWithSectionTitle:sectionDictionary[@"header"]];
        for (NSDictionary *rowDictionary in sectionDictionary[@"body"]) {
            NSString *string = rowDictionary[@"text"];
            NSString *type = rowDictionary[@"type"];
            EZTableViewTextRow *row = [[EZTableViewTextRow alloc] init];
            if ([type isEqualToString:@"text"]) {
                row.shouldHighlight = NO;
                row.attributedString = [[NSAttributedString alloc] initWithString:string attributes:textAttributes];
            } else {
                if ([self typeEnabled:type]) {
                    row.attributedString = [[NSAttributedString alloc] initWithString:string attributes:buttonAttributes];
                    if ([type isEqualToString:@"callButton"]) {
                        row.didSelectRowBlock = ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rowDictionary[@"number"]]];
                        };
                    } else if ([type isEqualToString:@"textButton"]) {
                        row.didSelectRowBlock = ^{
                            [self presentMessageComposeViewControllerWithRecipients:@[rowDictionary[@"number"]] body:rowDictionary[@"body"]];
                        };
                    } else if ([type isEqualToString:@"emailButton"]) {
                        row.didSelectRowBlock = ^{
                            [self presentMailCompseViewControllerWithRecipients:@[rowDictionary[@"email"]] body:rowDictionary[@"body"]];
                        };
                    } else if ([type isEqualToString:@"webButton"]) {
                        row.didSelectRowBlock = ^{
                            [self.navigationController pushViewController:[[RUChannelManager sharedInstance] viewControllerForChannel:@{@"title" : self.title, @"view" : @"www", @"url" : rowDictionary[@"url"]}] animated:YES];
                        };
                    }
                } else {
                    row.attributedString = [[NSAttributedString alloc] initWithString:string attributes:disabledButtonAttributes];
                }
            }
            [section addRow:row];
        }
        [self addSection:section];
    }
}
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

