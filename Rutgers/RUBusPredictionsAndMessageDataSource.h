//
//  RUBusPredictionsAndMessageDataSource.h
//  Rutgers
//
//  Created by scm on 7/12/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ComposedDataSource.h"
#import "RUPredictionsDataSource.h"
#import "RUBusMessagesDataSource.h"

/*
    Will Hold both the RuPredictionsData Source and the RUMessages DS .
 */

@interface RUBusPredictionsAndMessageDataSource : ComposedDataSource

- (instancetype)initWithItem:(id)item;
- (instancetype)initWithItem:(id)item busNumber: (NSString*)busNumber;
-(void)toggleExpansionForSection:(NSUInteger)section; // toogle whether the section has been expanded or not .
@property(nonatomic) id item ;
@property(nonatomic) NSString * responseTitle; // the title of the stop/route obtained from the internet response



@end
