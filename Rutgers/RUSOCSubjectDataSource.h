//
//  RUSOCSubjectDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"

@interface RUSOCSubjectDataSource : BasicDataSource
-(id)initWithSubjectCode:(NSString *)subjectCode;
@property NSString *subjectCode;
@end
