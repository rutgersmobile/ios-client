//
//  RUPrediction.h
//  Rutgers
//
//  Created by Open Systems Solutions on 8/12/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUBusVehicle.h"

/**
 The bus prediction object holds the predictions for a singlular route and stop combination.
 Also holds any message associated with a stop and route:w
 */
@interface RUBusPrediction : NSObject
-(instancetype)initWithDictionary:(NSDictionary *)dictionary vehicleArray: (NSDictionary*)vehicleArray;
-(instancetype)initWithArrivalArray:(NSString*)stopId arrivalArray:(NSArray*)arrivalArray;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL stopActive;
@property (nonatomic) NSString* routeTitle;
@property (nonatomic) NSString* stopTitle;
@property (nonatomic , readonly) NSString* stop_id;
@property (nonatomic) NSArray* messages;
@property (nonatomic) NSArray* arrivals;
@property (nonatomic) RUBusVehicle* vehicle;
@end
