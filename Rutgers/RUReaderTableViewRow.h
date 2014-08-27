//
//  RUReaderTableViewRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

@interface RUReaderTableViewRow : NSObject
-(instancetype)initWithItem:(NSDictionary *)item;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *date;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *descriptionText;
@end
