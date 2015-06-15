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
-(instancetype)initWithItem:(NSDictionary *)item NS_DESIGNATED_INITIALIZER;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *descriptionText;
@end
