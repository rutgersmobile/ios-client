//
//  FAQSectionDataSource.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/31/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "FAQSectionDataSource.h"
#import "ALTableViewTextCell.h"
#import "DataSource_Private.h"

@interface FAQSectionDataSource ()
@end

@implementation FAQSectionDataSource


-(instancetype)initWithItem:(NSDictionary *)item{
    self = [super init];
    if (self) {
        NSArray *items;
        id answer = item[@"answer"];
        
        if (answer) {
            items = @[item[@"title"],answer];
        } else {
            items = @[item];
        }
        
        self.items = items;

    }
    return self;
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(void)configureCell:(ALTableViewTextCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [super configureCell:cell forRowAtIndexPath:indexPath];
    
    NSString *stringForIndex;
    id itemForIndex = [self itemAtIndexPath:indexPath];
    
    if ([itemForIndex isKindOfClass:[NSString class]]) {
        stringForIndex = itemForIndex;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else if ([itemForIndex isKindOfClass:[NSDictionary class]]) {
        stringForIndex = [itemForIndex channelTitle];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = stringForIndex;
    
    if (indexPath.row == 0){
        cell.textLabel.font =  [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
        if (self.expanded) {
            cell.textLabel.textColor = cell.tintColor;
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
    } else {
        cell.textLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
}

@end
