//
//  RUInfoTableViewController.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/3/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUInfoTableViewController.h"
#import <MessageUI/MessageUI.h>
#import <PBWebViewController.h>

@interface RUInfoTableViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property NSArray *infoData;
@property NSIndexPath *phoneIndex;
@property NSArray *textIndexes;
//@property (weak, nonatomic) IBOutlet UITableViewCell *callCell;
//@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *textCells;

@end

@implementation RUInfoTableViewController
+(instancetype)component{
    return [[RUInfoTableViewController alloc] init];
}
- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.infoData = @[@{@"header" :@"Call RU-Info",
                            @"body" : @[@"Contact a helpful Information Assistant at RU-info with your Rutgers questions by calling, texting, or email.",
                                        @"Call (732-445-INFO)"]
                            },
                          
                          @{@"header" :@"Text RU-Info",
                            @"body" : @[@"Text RU-info with your question. \nTo sign up for RU-info TEXT:",
                                        @"Text 'Rutgers' to 66746",
                                        @"Or, if you have already signed up:",
                                        @"Text your question to 66746"]
                            },
                          
                          @{@"header" :@"Email RU-Info",
                            @"body" : @[@"Email RU-Info with your question:",
                                        @"Email Colonel Henry"]
                            },
                          
                          @{@"header" :@"Visit Website",
                            @"body" : @[@"For hours and additional info, visit us online:",
                                        @"Visit Website"]
                            }];
        self.phoneIndex = [NSIndexPath indexPathForRow:1 inSection:0];
        self.textIndexes = @[[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1]];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *)itemForIndexPath:(NSIndexPath *)indexPath{
    return self.infoData[indexPath.section][@"body"][indexPath.row];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.infoData count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.infoData[section][@"body"] count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.infoData[section][@"header"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (indexPath.row % 2 == 0) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
    } else {
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        if (([self.phoneIndex isEqual:indexPath] && ![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"telprompt://732-445-INFO"]]) ||
            ([self.textIndexes containsObject:indexPath] && ![MFMessageComposeViewController canSendText])) {
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
        } else {
            cell.userInteractionEnabled = YES;
            cell.textLabel.textColor = cell.tintColor;
        }
    }
    cell.textLabel.text = [self itemForIndexPath:indexPath];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row % 2 == 0) {
        NSString *string = [self itemForIndexPath:indexPath];
        NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:18] forKey: NSFontAttributeName];
        
        CGSize labelStringSize = [string boundingRectWithSize:CGSizeMake(self.view.bounds.size.width-30, 9999)
                                                      options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:stringAttributes context:nil].size;
        return round(labelStringSize.height+24.0);
    } else {
        return 44.0;
    }

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
            PBWebViewController *webBrowser = [[PBWebViewController alloc] init];
            webBrowser.URL = [NSURL URLWithString:@"http://m.rutgers.edu/ruinfo.html"];
            webBrowser.title = self.title;
            [self.navigationController pushViewController:webBrowser animated:YES];
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

