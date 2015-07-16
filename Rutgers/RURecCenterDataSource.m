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
#import "KeyValueDataSource.h"

@interface RURecCenterDataSource ()
@property (nonatomic) NSDictionary *recCenter;
@property (nonatomic) StringDataSource *descriptionDataSource;
@end

@implementation RURecCenterDataSource
-(instancetype)initWithRecCenter:(NSDictionary *)recCenter{
    self = [super init];
    if (self) {
        self.recCenter = recCenter;
        
        NSArray *dailySchedules = recCenter[@"daily_schedules"];
        if (dailySchedules.count) {
            RURecCenterHoursSection *hoursSection = [[RURecCenterHoursSection alloc] initWithDailySchedules:dailySchedules];
            [self addDataSource:hoursSection];
            self.hoursSection = hoursSection;
        }
        
        NSString *address = recCenter[@"address"];
        NSString *informationNumber = recCenter[@"information_number"];
        NSString *businessNumber = recCenter[@"business_number"];

        if (address.length || informationNumber.length || businessNumber.length) {
            KeyValueDataSource *infoSection = [[KeyValueDataSource alloc] initWithObject:recCenter];
            infoSection.title = @"Info";
            infoSection.items = @[
                                  @{@"keyPath" : @"address", @"label" : @""},
                                  @{@"keyPath" : @"information_number", @"label" : @"Information Desk"},
                                  @{@"keyPath" : @"business_number", @"label" : @"Business Office"},
                                  ];
            
            [self addDataSource:infoSection];
        }

        NSString *description = recCenter[@"full_description"];
        if (description.length) {
            StringDataSource *descriptionDataSource = [[StringDataSource alloc] init];
            self.descriptionDataSource = descriptionDataSource;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDescription) name:UIContentSizeCategoryDidChangeNotification object:nil];
            [self loadDescription];
            
            descriptionDataSource.title = @"Description";
            [self addDataSource:descriptionDataSource];
    
        }
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)loadDescription{
    NSString *description = self.recCenter[@"full_description"];
    NSAttributedString *string = [NSAttributedString attributedStringFromHTMLString:description preferedTextStyle:UIFontTextStyleBody];
    self.descriptionDataSource.items = @[string];
}
@end
