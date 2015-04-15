//
//  RUReaderTableViewRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderItem.h"
#import <NSString+HTML.h>
#import "RUReaderTableViewCell.h"

@interface RUReaderItem ()
@property (nonatomic) NSDictionary *item;
@end

@implementation RUReaderItem
-(instancetype)initWithItem:(NSDictionary *)item{
    self = [super init];
    if (self) {
        self.item = item;
        id title = [item[@"title"] firstObject];
        if ([title isKindOfClass:[NSString class]]) {
            self.title = [title stringByDecodingHTMLEntities];
        }
       
        NSString *dateString = [item[@"pubDate"] firstObject];
        if (!dateString) {
            dateString = [item[@"event:beginDateTime"] firstObject];
        }
        NSDate *date = [self dateFromString:dateString];
        self.dateString = [self formatDate:date];
        
        NSString *urlString = [item[@"enclosure"] firstObject][@"_url"];
        if (!urlString) urlString = [item[@"media:thumbnail"] firstObject][@"_url"];
        
        self.imageURL = [NSURL URLWithString:urlString];
        self.url = [item[@"link"] firstObject];
        
        id description = [item[@"description"] firstObject];
        if ([description isKindOfClass:[NSString class]]) {
            self.descriptionText = [[description stringByDecodingHTMLEntities] stringByConvertingHTMLToPlainText];
        }
    }
    return self;
}


-(NSDate *)dateFromString:(NSString *)string{
    static NSMutableArray *inputFormatters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        /*
         Wednesday, July 2, 2014
         EEEE, MMMM d, yyyy
         
         Fri, 30 May 2014b 16:51:02 GMT
         EEE, d MMM yyyy HH:mm:ss zzz
         
         Mon, 07 Jul 2014 -0400
         EEE, dd MMM yyyy -HHmm
         
         2014-07-11 07:30:00 Fri
         yyyy-MM-dd HH:mm:ss EEE
         
         Sun, 29 Jun 2014
         EEE, dd MMM yyyy
         */
        
        inputFormatters = [NSMutableArray array];
        for (NSString *dateFormatString in @[@"EEEE, MMMM d, yyyy",
                                             @"EEE, d MMM yyyy HH:mm:ss zzz",
                                             @"EEE, dd MMM yyyy -HHmm",
                                             @"yyyy-MM-dd HH:mm:ss EEE",
                                             @"EEE, dd MMM yyyy"])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = dateFormatString;
            [inputFormatters addObject:dateFormatter];
        }
    });
    
    NSDate *dateRepresentation;
    for (NSDateFormatter *dateFormatter in inputFormatters) {
        dateRepresentation = [dateFormatter dateFromString:string];
        if (dateRepresentation) break;
    }
    return dateRepresentation;
    
}

-(NSString *)formatDate:(NSDate *)date{
    if (!date) return nil;
    

    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:date];
    
    if (components.year < 2000) return nil;
    
    NSDateFormatterStyle timeStyle = NSDateFormatterShortStyle;
    if (components.hour == 0 && components.minute == 0) timeStyle = NSDateFormatterNoStyle;
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateStyle = NSDateFormatterMediumStyle;
    outputFormatter.timeStyle = timeStyle;

    return [outputFormatter stringFromDate:date];
}

-(BOOL)isEqual:(id)object{
    if (object == self) return YES;
    if (![object isMemberOfClass:[self class]]) return NO;
    RUReaderItem *otherItem = object;
    return [otherItem.item isEqualToDictionary:self.item];
}

@end
