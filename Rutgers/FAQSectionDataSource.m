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
        id answer = item[@"answer"];

        if (answer) {
            //If theres an answer, show the question and answer
            self.items = @[item[@"title"],answer];
        } else {
            //If no answer, this is just an item that will lead to another view
            self.items = @[item];
        }
        
    }
    return self;
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(void)configureCell:(ALTableViewTextCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //ExpandingTableViewSection configures some general appearance
    [super configureCell:cell forRowAtIndexPath:indexPath];
    
    NSString *stringForIndex;
    id itemForIndex = [self itemAtIndexPath:indexPath];
    
    if ([itemForIndex isKindOfClass:[NSString class]]) {
        //If just text
        stringForIndex = itemForIndex;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else if ([itemForIndex isKindOfClass:[NSDictionary class]]) {
        //If this will segue to another view
        stringForIndex = [itemForIndex channelTitle];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = stringForIndex;
    
    if (indexPath.row == 0){
        //The top 'header' row is stylized in one way
        cell.textLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleBody];
        if (self.expanded) {
            cell.textLabel.textColor = cell.tintColor;
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
    } else {
        //And the answer in another
        cell.textLabel.font = [UIFont ruPreferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
}

@end
