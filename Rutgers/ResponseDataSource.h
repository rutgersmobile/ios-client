//
//  ResponseDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 8/22/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "StringDataSource.h"

@interface ResponseDataSource : StringDataSource
@property (nonatomic) BOOL on;
@property (nonatomic) NSString *toggleLabel;
@property (nonatomic) NSString *textFieldLabel;
@property (nonatomic) NSString *textFieldPlaceholder;
@property (nonatomic) NSString *textFieldText;
@end
