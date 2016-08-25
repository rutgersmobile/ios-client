//
//  RUSOCSubjectViewController.h
//  Rutgers
//
//  Created by Kyle Bailey on 5/29/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "TableViewController.h"
#import "RUSOCDataLoadingManager.h"

@interface RUSOCSubjectViewController : TableViewController
-(instancetype)initWithSubject:(NSDictionary *)subject;
@property (nonatomic) RUSOCDataLoadingManager *dataLoadingManager;
@end
