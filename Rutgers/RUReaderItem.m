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

@end

@implementation RUReaderItem
-(instancetype)initWithItem:(NSDictionary *)item{
    self = [super init];
    if (self) {
        id title = [item[@"title"] firstObject];
        if ([title isKindOfClass:[NSString class]]) {
            self.title = [title stringByDecodingHTMLEntities];
        }
       
        NSString *date = [item[@"pubDate"] firstObject];
        if (!date) {
            date = [item[@"event:beginDateTime"] firstObject];
        }
        self.date = [self formatDateString:date];
        
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

/**
 *  Tries to parse a date string with many different formats untill it is successful
 *
 *  @param dateString The string representing the date as retrieved from the internet
 *
 *  @return A string representing the same date, in a human readable format. If parsing is unsuccessful, returns the input string
 */
-(NSString *)formatDateString:(NSString *)dateString{
    static NSDateFormatter *outputFormatter;
    static NSMutableArray *inputFormatters;
  
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //ex Wednesday, July 2, 2014
        outputFormatter = [[NSDateFormatter alloc] init];
        outputFormatter.dateStyle = NSDateFormatterMediumStyle;
        outputFormatter.timeStyle = NSDateFormatterNoStyle;
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
        dateRepresentation = [dateFormatter dateFromString:dateString];
        if (dateRepresentation) break;
    }
    
    if (dateRepresentation) {
        return [outputFormatter stringFromDate:dateRepresentation];
    } else {
        return dateString;
    }
}




@end
