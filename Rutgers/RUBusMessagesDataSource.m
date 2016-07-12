//
//  RUBusMessagesDataSource.m
//  Rutgers
//
//  Created by scm on 7/11/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUBusMessagesDataSource.h"
#import "ALTableViewTextCell.h"

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

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _arrayMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addMessage:(NSString *) message
{
    [_arrayMessages addObject:message];
    
}

-(void)loadContent
{
     [self loadContentWithBlock:^(AAPLLoading *loading)
    {
           if (!loading.current)
           {
            //If we have started another load, we should ignore this one
            [loading ignore];
            return;
           }
    
        [loading updateWithContent:^(typeof(self) me)
        {
            me.items = _arrayMessages;
        }];
    }];
}


-(void)addMessagesForPrediction:(RUBusPrediction *) prediction
{
    for( NSString * message in prediction.messages)
    {
        [self addMessage:message];
    }
    
}






@end
