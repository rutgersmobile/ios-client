//
//  RUSOCSectionRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

@class RUSOCSectionCell;

@interface RUSOCSectionRow : NSObject
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithSection:(NSDictionary *)section NS_DESIGNATED_INITIALIZER;
@property (nonatomic) NSDictionary *section;

@property (nonatomic) NSString *indexText;
@property (nonatomic) NSString *professorText;
@property (nonatomic) NSString *descriptionText;
@property (nonatomic) NSString *dayText;
@property (nonatomic) NSString *timeText;
@property (nonatomic) NSString *locationText;
@end
