//
//  RUReaderTableViewRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//


/**
 The class models a single item in the rureader data source
 */
@interface RUReaderItem : NSObject
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithItem:(NSDictionary *)item NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithAtom:(NSDictionary *)item NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithGame:(NSDictionary *)game NS_DESIGNATED_INITIALIZER;
+(NSDateFormatter *) dateFormatter;
+(NSDateFormatter *) timeFormatter;
+(NSDateFormatter *) utcDateFormatter;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *descriptionText;

#warning TODO : Poor design create specialized sub class for game item , rather than adding it on to this generic item

@property (readonly) int ruScore;
@property (readonly) int otherScore;
@property (readonly) bool isRuHome; // determine is ru is home , then display the ru score first , else otherwise
@property (readonly) bool ruWin;
@property (readonly) bool imagePresent;
@end
