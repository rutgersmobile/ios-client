//
//  RUPrediction.m
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import "RUBusPrediction.h"
#import "RUBusArrival.h"
#import "RUDefines.h"

@implementation RUBusPrediction
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self)
    {
        //Fill up fields from the dictionary
        _routeTag = dictionary[@"routeTag"];
        _stopTag = dictionary[@"stopTag"];
        
        _routeTitle = dictionary[@"routeTitle"];
        _stopTitle = dictionary[@"stopTitle"];
        
        //Check if there is a direction
        NSDictionary *direction = dictionary[@"direction"];
        if (direction)
        {
            //Get its title
            _directionTitle = direction[@"title"];
            
            //Parse the arrivals
            NSMutableArray *arrivals = [NSMutableArray array];
            for (NSDictionary *arrival in direction[@"prediction"]) // go through each prediction .. In XML objects with same name are mapped to a dictionary
            {
                [arrivals addObject:[[RUBusArrival alloc] initWithDictionary:arrival]];
            }
            _arrivals = arrivals;
        }
        else
        {
            //Otherwise the direciton title is in this field
            _directionTitle = dictionary[@"dirTitleBecauseNoPredictions"];
        }
        
       // Check if message exit : if so add them to array ..
        NSMutableArray * messages = [NSMutableArray array];
        
        for (NSDictionary * message in dictionary[@"message"]) // if not tag then the message will be nil
        {
            [messages addObject:message[@"text"]]; // there are two tags text and priority . We ignore the priority.
        }
        
        _messages = messages;
        
        if(DEV) NSLog(@"%@",_messages);
    }
    return self;
}

/**
 *  Whether the prediction is active
 *
 *  @return Yes if there are some number of arrivals, no otherwise
 */
-(BOOL)active
{
    return self.arrivals.count > 0;
}
@end
