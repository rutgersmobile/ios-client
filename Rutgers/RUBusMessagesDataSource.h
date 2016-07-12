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

-(void)addMessage:(NSString *) message;
-(void)addMessagesForPrediction:(RUBusPrediction *) prediction ;
@end
