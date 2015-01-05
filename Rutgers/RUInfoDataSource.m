//
//  RUInfoDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUInfoDataSource.h"
#import "RUInfoTableSection.h"
#import "ALTableViewTextCell.h"
#import <MessageUI/MessageUI.h>

@implementation RUInfoDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *infoData = @[@{@"header" : @"Call RU-Info",
                                @"body" : @[@{@"type" : @"text" , @"text" : @"Contact a helpful Information Assistant at RU-info with your Rutgers questions by calling, texting, or email."},
                                            @{@"type" : @"callButton", @"text" : @"Call RU-Info (732-445-INFO)", @"number" : @"telprompt://732-445-INFO"}],
                                },
                              
                              @{@"header" : @"Text RU-Info",
                                @"body" : @[@{@"type" : @"text" , @"text" : @"Text RU-info with your question. To sign up for RU-info text 'Rutgers' to 66746:"},
                                            @{@"type" : @"textButton", @"text" : @"Text 'Rutgers' to 66746", @"number" : @"66746", @"body" : @"Rutgers"},
                                            @{@"type" : @"text" , @"text" : @"Or, if you have already signed up:"},
                                            @{@"type" : @"textButton" , @"text" : @"Text your question to 66746", @"number" : @"66746"}],
                                },
                              
                              @{@"header" : @"Email RU-Info",
                                @"body" : @[@{@"type" : @"text" , @"text" : @"Email RU-Info with your question:"},
                                            @{@"type" : @"emailButton", @"text" : @"Email Colonel Henry", @"email" : @"colhenry@rci.rutgers.edu", @"body" : @""}],
                                @"footer" : @"colhenry@rci.rutgers.edu"
                                },
                              
                              @{@"header" : @"Visit Website",
                                @"body" : @[@{@"type" : @"text" , @"text" : @"For hours and additional info, visit us online"},
                                            @{@"type" : @"webButton", @"text" : @"Visit Website", @"url" : @"http://m.rutgers.edu/ruinfo.html"}]
                                }];
      
        for (NSDictionary *sectionDictionary in infoData) {
            RUInfoTableSection *section = [[RUInfoTableSection alloc] init];
            section.title = sectionDictionary[@"header"];
            section.items = sectionDictionary[@"body"];
            section.footer = sectionDictionary[@"footer"];
            [self addDataSource:section];
        }

    }
    return self;
}

-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

+(BOOL)buttonTypeEnabled:(NSString *)type{
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
@end
