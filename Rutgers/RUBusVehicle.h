//
//  RUBusVehicle.h
//  Rutgers
//
//  Created by Colin Walsh on 12/4/18.
//  Copyright © 2018 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUBusStop.h"
#import <Mapkit/Mapkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RUBusVehicle : NSObject
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithDictionary: (NSDictionary*) response NS_DESIGNATED_INITIALIZER;
@property (nonatomic, readonly) NSArray* arrivals;
@property (nonatomic, readonly) BOOL doesHaveArrivals;
@property (nonatomic, readonly) int passengerLoad;
@property (nonatomic, readonly) CLLocation* location;
@property (nonatomic) BOOL trackingStatus;
@property (nonatomic) NSString* vehicleId;
@property (nonatomic) NSString* routeId;
@property (nonatomic) RUBusStop* nearbyStop;
@property (nonatomic) NSString* callName;
@end

NS_ASSUME_NONNULL_END
