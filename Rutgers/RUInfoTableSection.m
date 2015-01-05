//
//  RUInfoTableSection.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUInfoTableSection.h"
#import "ALTableViewTextCell.h"
#import "RUInfoDataSource.h"

@implementation RUInfoTableSection
-(void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *item = [self itemAtIndexPath:indexPath];
    cell.textLabel.text = item[@"text"];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.separatorInset = UIEdgeInsetsZero;
    
    NSString *type = item[@"type"];
    
    if ([type isEqualToString:@"text"]) {
        cell.textLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.font = [UIFont ruPreferredBoldFontForTextStyle:UIFontTextStyleBody];
        cell.textLabel.textColor = [RUInfoDataSource buttonTypeEnabled:type] ? cell.tintColor : [UIColor grayColor];
    }
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

@end
