//
//  RUReaderTableViewRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/27/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "EZTableViewRightDetailRow.h"

@interface RUReaderTableViewRow : EZTableViewRightDetailRow
-(instancetype)initWithItem:(NSDictionary *)item;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *date;
@property (nonatomic) NSURL *url;
@end
