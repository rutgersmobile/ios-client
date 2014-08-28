//
//  ButtonDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/28/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "StringDataSource.h"

@interface ButtonDataSource : StringDataSource
-(id)initWithTitle:(NSString *)title;
@property (nonatomic) BOOL on;
@end
