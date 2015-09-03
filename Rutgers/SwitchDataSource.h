//
//  SwitchDataSource.h
//  Rutgers
//
//  Created by OSS on 9/3/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"

@interface SwitchDataSource : BasicDataSource
@property (nonatomic) NSString *textLabelText;
@property (nonatomic, getter=isOn) BOOL on;
@end
