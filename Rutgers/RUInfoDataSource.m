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
#import "DataSource_Private.h"

@implementation RUInfoDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RUInfo" ofType:@"json"]];
        NSArray *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
      
        for (NSDictionary *sectionDictionary in info) {
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
