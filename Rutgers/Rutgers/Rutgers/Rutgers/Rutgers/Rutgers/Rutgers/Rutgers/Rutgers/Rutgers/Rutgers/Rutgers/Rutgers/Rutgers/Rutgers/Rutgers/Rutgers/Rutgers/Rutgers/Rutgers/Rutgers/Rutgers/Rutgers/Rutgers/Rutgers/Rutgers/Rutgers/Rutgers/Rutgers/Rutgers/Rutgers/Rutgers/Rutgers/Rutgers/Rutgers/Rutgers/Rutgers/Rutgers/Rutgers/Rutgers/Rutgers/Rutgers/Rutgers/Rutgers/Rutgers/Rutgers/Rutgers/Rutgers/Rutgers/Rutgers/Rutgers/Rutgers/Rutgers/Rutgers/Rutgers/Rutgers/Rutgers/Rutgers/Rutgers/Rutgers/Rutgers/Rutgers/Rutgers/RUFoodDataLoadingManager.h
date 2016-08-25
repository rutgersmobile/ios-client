//
//  RUFoodDataManager.h
//  Rutgers
//
//  Created by Open Systems Solutions on 2/26/16.
//  Copyright © 2016 Rutgers. All rights reserved.
//

#import "RUDataLoadingManager.h"
#import "DataTuple.h"

@interface RUFoodDataLoadingManager : RUDataLoadingManager
+(RUFoodDataLoadingManager *)sharedInstance;

-(void)getDiningHallsWithCompletion:(void (^)(NSArray <DataTuple *> *diningHalls, NSError *error))completionBlock;

-(void)getSerializedDiningHall:(NSString *)serializedDiningHall withCompletion:(void (^)(DataTuple *diningHall, NSError *error))completionBlock;
@end
