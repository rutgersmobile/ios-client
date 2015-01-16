//
//  RUSOCSectionRow.h
//  Rutgers
//
//  Created by Kyle Bailey on 6/18/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

@class RUSOCSectionCell;

@interface RUSOCSectionRow : NSObject
-(instancetype)initWithSection:(NSDictionary *)section;
@property (nonatomic) NSDictionary *section;

@property (nonatomic) NSString *indexText;
@property (nonatomic) NSString *professorText;
@property (nonatomic) NSString *descriptionText;
@property (nonatomic) NSString *dayText;
@property (nonatomic) NSString *timeText;
@property (nonatomic) NSString *locationText;
@end
