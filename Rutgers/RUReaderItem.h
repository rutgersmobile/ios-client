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
-(instancetype)initWithGame:(NSDictionary *)game NS_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *descriptionText;
@end
