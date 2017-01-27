//
//  RUBusMessagesDataSource.m
//  Rutgers
//
//  Created by scm on 7/11/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUBusMessagesDataSource.h"
#import "ALTableViewTextCell.h"

#import "RUPredictionsDataSource.h"
#import "RUBusDataLoadingManager.h"
#import "RUBusMessagesDataSource.h"

#import "RUBusMultipleStopsForSingleLocation.h"
#import "RUBusRoute.h"

@interface RUBusMessagesDataSource()
@property (nonatomic) NSMutableArray * arrayMessages;
@end

@implementation RUBusMessagesDataSource



-(void)registerReusableViewsWithTableView:(UITableView *)tableView{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerClass:[ALTableViewTextCell class] forCellReuseIdentifier:NSStringFromClass([ALTableViewTextCell class])];
}

-(NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSStringFromClass([ALTableViewTextCell class]);
}

-(void)configureCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    ALTableViewTextCell *textViewCell = cell;
    
    textViewCell.textLabel.text = (NSString *)[self.items objectAtIndex:indexPath.row];
    
}

/*
    Item refers to the Bus Server that we are currently using . 
    Like Bus A
 
 */

- (instancetype)initWithItem:(id)item
{
    self = [super init];
    if (self)
    {
        self.item = item;
        _arrayMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addMessage:(NSString *) message
{
    if( ![_arrayMessages containsObject:message])
    {
        [_arrayMessages addObject:message];
        
    }
}

- (NSInteger)numberOfItems
{
    return  [_arrayMessages count];
}

-(void)addMessagesForPrediction:(NSArray *) response
{
    for (RUBusPrediction *prediction in response)
    {
        for( NSString * message in prediction.messages)
        {
            [self addMessage:message];
        }
    }
}

-(BOOL)isMessageAvaliable
{
        if([_arrayMessages count])
        {
            return YES;
        }
        else
        {
            return NO;
        }
}

-(void) updateContent
{
    [self setItems:_arrayMessages];
}


@end
