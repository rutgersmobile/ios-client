//
//  RURecCenterDataSource.m
//  Rutgers
//
//  Created by Open Systems Solutions on 1/16/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RURecCenterDataSource.h"
#import "TupleDataSource.h"
#import "DataTuple.h"
#import "StringDataSource.h"
#import "NSAttributedString+FromHTML.h"

@interface RURecCenterDataSource ()
@property (nonatomic) NSDictionary *recCenter;
@end

@implementation RURecCenterDataSource
-(instancetype)initWithRecCenter:(NSDictionary *)recCenter{
    self = [super init];
    if (self) {
        self.recCenter = recCenter;
        
        NSArray *dailySchedules = self.recCenter[@"daily_schedules"];
        if (dailySchedules.count) {
            RURecCenterHoursSection *hoursSection = [[RURecCenterHoursSection alloc] initWithDailySchedules:dailySchedules];
            [self addDataSource:hoursSection];
            self.hoursSection = hoursSection;
        }
        
        NSString *address = self.recCenter[@"address"];
        if (address.length) {
            
            RUPlace *place = [[RUPlace alloc] initWithTitle:self.title addressString:address];
            DataTuple *placeTuple = [[DataTuple alloc] initWithTitle:address object:place];
            
            TupleDataSource *addressDataSource = [[TupleDataSource alloc] initWithItems:@[placeTuple]];
            addressDataSource.title = @"Address";
            
            [self addDataSource:addressDataSource];
        }
        
        NSString *informationNumber = self.recCenter[@"information_number"];
        if (informationNumber.length) {
            StringDataSource *informationDataSource = [[StringDataSource alloc] initWithItems:@[informationNumber]];
            informationDataSource.title = @"Information Desk";
            [self addDataSource:informationDataSource];
        }
        
        NSString *businessNumber = self.recCenter[@"business_number"];
        if (businessNumber.length) {
            StringDataSource *businessDataSource = [[StringDataSource alloc] initWithItems:@[businessNumber]];
            businessDataSource.title = @"Business Office";
            [self addDataSource:businessDataSource];
        }
        
        NSString *description = self.recCenter[@"full_description"];
        if (description.length) {
            
            NSAttributedString *string = [NSAttributedString attributedStringFromHTMLString:description preferedTextStyle:UIFontTextStyleBody];
            
            StringDataSource *descriptionDataSource = [[StringDataSource alloc] initWithItems:@[string]];
            descriptionDataSource.title = @"Business Office";
            [self addDataSource:descriptionDataSource];
    
        }
    }
    return self;
}
@end
