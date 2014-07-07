//
//  RUReaderTableViewRow.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUReaderTableViewRow.h"
#import <NSString+HTML.h>
#import "RUReaderTableViewCell.h"
#import <AFNetworking.h>
#import <UIKit+AFNetworking.h>
#import <NSDate+InternetDateTime.h>

@interface RUReaderTableViewRow ()
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *date;
@property (nonatomic) NSURL *imageURL;
@end

@implementation RUReaderTableViewRow
-(instancetype)initWithItem:(NSDictionary *)item{
    self = [super initWithIdentifier:@"RUReaderTableViewCell"];
    if (self) {
        self.title = [[item[@"title"] firstObject] stringByDecodingHTMLEntities];
        self.date = [item[@"pubDate"] firstObject];
        if (!self.date) {
            self.date = [item[@"event:beginDateTime"] firstObject];
        }
        self.date = [self formatDateString:self.date];
        self.imageURL = [NSURL URLWithString:[item[@"enclosure"] firstObject][@"_url"]];
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
        outputFormatter.dateFormat = @"EEEE, MMMM d, yyyy";
        
        /*
         
         Wednesday, July 2, 2014
         EEEE, MMM d, yyyy
         
         Fri, 30 May 2014 16:51:02 GMT
         EEE, d MMM yyyy HH:mm:ss zzz
         
         Mon, 07 Jul 2014 -0400
         EEE, dd MMM yyyy -HHmm
         
         2014-07-11 07:30:00 Fri
         yyyy-MM-dd HH:mm:ss EEE
         
         Sun, 29 Jun 2014
         EEE, dd MMM yyyy
         */

        inputFormatters = [NSMutableArray array];
        for (NSString *dateFormatString in @[@"EEEE, MMMM d, yyyy", @"EEE, d MMM yyyy HH:mm:ss zzz", @"EEE, dd MMM yyyy -HHmm", @"yyyy-MM-dd HH:mm:ss EEE", @"EEE, dd MMM yyyy"]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = dateFormatString;
            [inputFormatters addObject:dateFormatter];
        }
    });
    
    NSDate *dateRepresentation = [NSDate date];
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

-(void)setupCell:(RUReaderTableViewCell *)cell{
    cell.titleLabel.text = self.title;
    cell.timeLabel.text = self.date;
    
    cell.hasImage = self.imageURL ? YES : NO;
    cell.imageDisplayView.image = nil;
    cell.imageDisplayView.backgroundColor = [UIColor lightGrayColor];
    if (self.imageURL) {
        [cell.imageDisplayView setImageWithURL:self.imageURL];
    }
}



@end
