//
//  RUBusMessagesDataSource.h
//  Rutgers
//
//  Created by scm on 7/11/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

/*
    Have to show multiple messages : Keep each of the message in an array . Then show the items
 */

#import <Foundation/Foundation.h>
#import "BasicDataSource.h"
#import "RUBusPrediction.h"

@interface RUBusMessagesDataSource : BasicDataSource

- (instancetype)initWithItem:(id)item;
-(void)addMessage:(NSString *) message;
-(void)addMessagesForPrediction:(NSArray *) response;
-(BOOL)isMessageAvaliable;
-(void) updateContent;

@property (nonatomic) id item ; // holds the name of the item
@end
