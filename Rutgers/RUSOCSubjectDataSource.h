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
-(instancetype)initWithSubjectCode:(NSString *)subjectCode dataLoadingManager:(RUSOCDataLoadingManager *)dataLoadingManager NS_DESIGNATED_INITIALIZER;
@end
