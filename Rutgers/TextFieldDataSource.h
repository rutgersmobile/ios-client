//
//  ResponseDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "StringDataSource.h"

@interface TextFieldDataSource : BasicDataSource
@property (nonatomic) NSString *textFieldLabel;
@property (nonatomic) NSString *textFieldPlaceholder;
@property (nonatomic) NSString *textFieldText;
@end
