//
//  RUSOCSubjectDataSource.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/30/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "BasicDataSource.h"
#import "RUSOCDataLoadingManager.h"

@interface RUSOCSubjectDataSource : BasicDataSource
-(instancetype)initWithSubjectCode:(NSString *)subjectCode NS_DESIGNATED_INITIALIZER;
@property (nonatomic) NSString *subjectCode;
@property (nonatomic) RUSOCDataLoadingManager *dataLoadingManager;
@end
