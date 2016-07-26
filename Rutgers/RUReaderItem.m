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
#import <XMLDictionary.h>

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
            _title = [title stringByDecodingHTMLEntities];
        }
       
        //The date may be in one of two fields
        NSString *startDateString = [item[@"pubDate"] firstObject];
        if (!startDateString) startDateString = [item[@"event:beginDateTime"] firstObject];
        
        NSString *endDateString = [item[@"event:endDateTime"] firstObject];
        
        NSDate *startDate = [self dateFromString:startDateString];
        NSDate *endDate = [self dateFromString:endDateString];

        _dateString = [self dateStringWithStartDate:startDate endDate:endDate];
        
        //The image url may be in one of two fields
        NSString *imageUrl;
        
        
        id imageEnclosure = [item[@"enclosure"] firstObject];
        if ([imageEnclosure isKindOfClass:[NSDictionary class]]) {
            imageUrl = imageEnclosure[@"_url"];
        } else if ([imageEnclosure isKindOfClass:[NSString class]]) {
            imageEnclosure = [NSDictionary dictionaryWithXMLString:imageEnclosure];
            imageUrl = imageEnclosure[@"_src"];
        }
        
        if (!imageUrl) imageUrl = [item[@"media:thumbnail"] firstObject][@"_url"];
        
        _imageURL = [NSURL URLWithString:imageUrl];
        _url = [item[@"link"] firstObject];
        
        id description = [item[@"description"] firstObject];
        if ([description isKindOfClass:[NSString class]]) {
            //strip out all the weird characters we can
            _descriptionText = [[description stringByDecodingHTMLEntities] stringByConvertingHTMLToPlainText];
        }
    }
    return self;
}

-(instancetype)initWithGame:(NSDictionary *)game
{
    self = [super init];
    if (self)
    {
        self.item = game;
        _title = game[@"description"];

        // Ensuring compatability with the new server changes
        // get a num prepresentation of the time tag which determines whether a time is present or not
        NSNumber * timePresent =(NSNumber *)game[@"start"][@"time"];

        // formatter for reading date string from server
        NSDateFormatter* dateTimeFormatter = [[NSDateFormatter alloc] init];
        dateTimeFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateTimeFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'";
        dateTimeFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

        // formatter for printing date
        // always used since we should always have a date
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;

        // formatter for printing time
        // only used if we have a time
        NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        timeFormatter.dateStyle = NSDateFormatterNoStyle;
        timeFormatter.timeStyle = NSDateFormatterShortStyle;

        // String from the server that we need to parse
        // Contains a date and a time
        NSString * dateTime = game[@"start"][@"date"];

        // parse the date so we can use it in the UI
        NSDate* date = [dateTimeFormatter dateFromString:dateTime];

        // Use the formatter to transform the date portion of our date/time
        NSString* dateString = [dateFormatter stringFromDate:date];

        // Check if we have a time so we can decide to put it in the UI or not
        if([timePresent boolValue]) {
            // If we do, then format the time and date into one final string
            NSString* timeString = [timeFormatter stringFromDate:date];
            _dateString = [NSString stringWithFormat:@"%@, %@", dateString, timeString]; // set the time
        } else {
            // If we don't have the time, only show date
            _dateString = [NSString stringWithFormat:@"%@, TBD", dateString]; // set the date
        }

        _descriptionText = game[@"location"];
    }
    return self;
}

/**
 *  Parses the given string representation of a date
 *  A variety of different formats are tried, and the first
 *
 *  @param string The string recieved from xml
 *
 *  @return An nsdate object representing the input date and time
 */
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
                                             @"EEE, dd MMM yyyy"]){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = dateFormatString;
            [inputFormatters addObject:dateFormatter];
        }
    });
    
    for (NSDateFormatter *dateFormatter in inputFormatters) {
        NSDate *dateRepresentation = [dateFormatter dateFromString:string];
        if (dateRepresentation) return dateRepresentation;
    }
    return nil;
    
}

/**
 *  This method takes the previously parsed dates and does a sanity check, as well as formats them properly for display
 *
 *  @param startDate The events start date
 *  @param endDate   The events end date
 *
 *  @return A formatted string
 */
-(NSString *)dateStringWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if (!startDate) return nil;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *startComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:startDate];

    //If our start date is very long ago, this is a garbage input
    if (startComponents.year < 2000) return nil;
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateStyle = NSDateFormatterMediumStyle;
    //Display time only if we are not at midnight
    outputFormatter.timeStyle = (startComponents.hour == 0 && startComponents.minute == 0) ? NSDateFormatterNoStyle : NSDateFormatterShortStyle;
    
    NSString *startString = [outputFormatter stringFromDate:startDate];
    if (!endDate) return startString;
    
    NSDateComponents *endComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:endDate];

    //If we are ending this close to midnight, this is an all day event and we only want to show the starting tme
    if (endComponents.hour == 23 && endComponents.minute > 50) return startString;
    
    outputFormatter.dateStyle = (startComponents.day == endComponents.day && startComponents.month == endComponents.month && startComponents.year == endComponents.year) ? NSDateFormatterNoStyle : NSDateFormatterMediumStyle;
    outputFormatter.timeStyle = (endComponents.hour == 0 && endComponents.minute == 0) ? NSDateFormatterNoStyle : NSDateFormatterShortStyle;
    
    NSString *endString = [outputFormatter stringFromDate:endDate];

    if (!endString) return startString;
    
    return [NSString stringWithFormat:@"%@ - %@", startString, endString];

}

//The below methods implement equality checking, so when we refresh our data we can identify which articles are new
-(BOOL)isEqual:(id)object{
    if (object == self) return YES;
    if (![object isMemberOfClass:[self class]]) return NO;
    RUReaderItem *otherItem = object;
    return [otherItem.item isEqualToDictionary:self.item];
}

-(NSUInteger)hash{
    return self.item.hash;
}

@end
