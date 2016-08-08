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

#import "RUBusMultipleStopsForSingleLocation.h"
#import "RUBusRoute.h"
#import "RUBusPrediction.h"

// To Handle the place holder business
#import "DataSource.h"
#import "DataSource_Private.h"

@interface RUBusPredictionsAndMessageDataSource()

@property (nonatomic) RUPredictionsDataSource * busPredictionsDS;
@property (nonatomic) RUBusMessagesDataSource * busMessagesDS;

-(void)getTitleFromInternetResponse:(NSArray  *)prediction;

@end

@implementation RUBusPredictionsAndMessageDataSource

- (instancetype)initWithItem:(id)item
{
    self = [super init];
    if (self)
    {
        self.item = item;
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

/*
    Load the content and pass it to the prediction and messgaes data source
 
 */
-(void)loadContent
{
    [self loadContentWithBlock:^
     (AAPLLoading *loading)
     {
         void (^getPredictions)(id item) = ^(id item)
         {
            
             if([AFNetworkReachabilityManager sharedManager].reachable)
             {
                 [self.busPredictionsDS beginLoading]; // show loading state
             }
             
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
                               // update the predictions
                               [self.busPredictionsDS updateSectionsForResponse:predictions]; // add the obtained prediction to self (data source)
                               [self.busPredictionsDS endLoadingWithState:AAPLLoadStateContentLoaded error:nil update:nil];
                               
                               // update the messages
                               [self.busMessagesDS addMessagesForPrediction:predictions]; // add the obtained prediction to self (data source)
                               if( [self.busMessagesDS isMessageAvaliable])
                               {
                                   [self.busMessagesDS updateContent];
                               }
                               
                               [self getTitleFromInternetResponse:predictions];
                               
                               
                           }];
                      }
                      else
                      {
                          [loading updateWithNoContent:^(typeof(self) me)
                           {
                               [self.busPredictionsDS updateSectionsForResponse:nil]; // add the obtained prediction to self (data source)
                               [self.busPredictionsDS endLoadingWithState:AAPLLoadStateNoContent error:nil update:nil];
                           }];
                      }
                      
                  }
                  else
                  {
                      [loading doneWithError:error];
                      
                      // makes ui changes: Shows the network error cell : Has to be done on the main thread
                      dispatch_sync(dispatch_get_main_queue(),^
                     {
                         [self.busPredictionsDS loadContentWithBlock:^(AAPLLoading *loading)
                         {
                             [loading doneWithError:error];
                         }];
                     });
      
                      
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
                      self.busPredictionsDS.item = item ;
                      self.busMessagesDS.item = item;
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

/*
    Get the title from the internet resposne. 
 
        We do this so that the title can be properly set , when the bus prediction is created from a favourite or a deep link.
        In these both cases we do not have access to the proper expanded title , we just have access to the tag.
 
 */
-(void)getTitleFromInternetResponse:(NSArray  *)prediction
{
    if([self.item isKindOfClass:[RUBusMultipleStopsForSingleLocation class]]) // if prediction for a stop , then get title from stopTitle of RUBusPredictiosn
    {
        self.responseTitle = ((RUBusPrediction *)prediction[0]).stopTitle; // the stop title will be the same for all items of the stop prediction
    }
    else if ([self.item isKindOfClass:[RUBusRoute class]])
    {
        self.responseTitle = ((RUBusPrediction*)prediction[0]).routeTitle;
    }
    else if ([self.item isKindOfClass:[NSArray class]]) // initliazed from the deep url or favourite ..
    {
        // determine if the favourite / link is a route / stop . then take out the required info based on this
        if([(NSString *)self.item[0] isEqualToString:@"stop"])
        {
                self.responseTitle = ((RUBusPrediction *)prediction[0]).stopTitle; // the stop title will be the same for all items of the stop prediction
        }
        else if([(NSString *)self.item[0] isEqualToString:@"route"])
         {
                self.responseTitle = ((RUBusPrediction*)prediction[0]).routeTitle;
         }
        
        
    }
    
    
}

@end
