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
@property (nonatomic) id item ; // holds the name of the item
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

-(void)loadContent
{
    
    [self loadContentWithBlock:^
     (AAPLLoading *loading)
     {
         
         void (^getPredictions)(id item) = ^(id item)
         {
             
             [[RUBusDataLoadingManager sharedInstance] getPredictionsForItem:item completion:^
              (NSArray *predictions, NSError *error)
              {
                  if (!loading.current) // state chanage <?>
                  {
                      [loading ignore];
                      return;
                  }
                  
                  if (!error)
                  {
                      if (predictions.count) // If content was loaded
                      {
                          [loading updateWithContent:^(typeof(self) me)
                           {
                               [me addMessagesForPrediction:predictions]; // add the obtained prediction to self (data source)
                               
                               [self setItems:_arrayMessages];
                           }];
                      }
                      else
                      {
                          [loading updateWithNoContent:^(typeof(self) me)
                           {
                               [me addMessagesForPrediction:nil];
                               [self setItems:_arrayMessages];
                           }];
                      }
                      
                  }
                  else
                  {
                      [loading doneWithError:error];
                  }
              }
              ];
         };
         
         
         if ([self.item isKindOfClass:[RUBusMultipleStopsForSingleLocation class]] || [self.item isKindOfClass:[RUBusRoute class]])
         {
             getPredictions(self.item);
         }
         else if ([self.item isKindOfClass:[NSArray class]] && [self.item count] >= 2)
         {
             [
              [RUBusDataLoadingManager sharedInstance] getSerializedItemWithName:self.item[1] type:self.item[0] completion:^
              (id item, NSError *error)
              {
                  if (item)
                  {
                      self.item = item;
                      getPredictions(item);
                  }
                  else
                  {
                      [loading doneWithError:error];
                  }
              }
              ];
         }
         else
         {
             [loading doneWithError:nil];
         }
     }];
}





@end
