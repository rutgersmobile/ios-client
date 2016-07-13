//
//  RUBusPredictionsAndMessageDataSource.m
//  Rutgers
//
//  Created by scm on 7/12/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUBusPredictionsAndMessageDataSource.h"
#import "RUPredictionsDataSource.h"
#import "RUBusDataLoadingManager.h"
#import "RUBusMessagesDataSource.h"


@interface RUBusPredictionsAndMessageDataSource()

@property (nonatomic) RUPredictionsDataSource * busPredictionsDS;
@property (nonatomic) RUBusMessagesDataSource * busMessagesDS;
@property id item ;

@end

@implementation RUBusPredictionsAndMessageDataSource

- (instancetype)initWithItem:(id)item
{
    self = [super init];
    if (self)
    {
        self.busMessagesDS = [[RUBusMessagesDataSource alloc]initWithItem:item];
        self.busPredictionsDS = [[RUPredictionsDataSource alloc] initWithItem:item];
        
        [self addDataSource:self.busMessagesDS];
        [self addDataSource:self.busPredictionsDS];
    }
    return self;
}

/*
    This message is only relevant for the RUPredictionDataSource
 */
-(void)toggleExpansionForSection:(NSUInteger)section
{
   if(section == 0)
   {
        // No message to pass
   }
   else
    {
        [self.busPredictionsDS toggleExpansionForSection: section - 1];
    }
}


@end
