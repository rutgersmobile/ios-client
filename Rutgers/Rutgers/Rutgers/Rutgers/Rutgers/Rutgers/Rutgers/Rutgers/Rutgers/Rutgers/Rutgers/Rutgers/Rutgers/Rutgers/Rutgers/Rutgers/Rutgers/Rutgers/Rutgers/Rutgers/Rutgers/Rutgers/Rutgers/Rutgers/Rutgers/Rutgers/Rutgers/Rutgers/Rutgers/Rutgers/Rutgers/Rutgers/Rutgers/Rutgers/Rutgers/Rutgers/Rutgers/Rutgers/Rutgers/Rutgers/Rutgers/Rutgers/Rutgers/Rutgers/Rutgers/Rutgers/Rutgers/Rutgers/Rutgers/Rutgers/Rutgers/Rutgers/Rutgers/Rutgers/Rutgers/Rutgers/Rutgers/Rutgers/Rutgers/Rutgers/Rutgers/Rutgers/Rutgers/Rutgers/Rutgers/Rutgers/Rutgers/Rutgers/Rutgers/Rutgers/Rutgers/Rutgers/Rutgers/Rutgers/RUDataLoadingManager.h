//
//  RUDataLoadingManager.h
//  Rutgers
//
//  Created by Open Systems Solutions on 6/17/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

//There is more defined in RUDataLoadingManager_Private.h

//This class defines an abstract interface for loading data asynchronously
//Calling performWhenLoaded will cause the asynchronous load to occur, and call the block upon completion
//Or if the data is already loaded, call it immediately
@interface RUDataLoadingManager : NSObject
-(void)performWhenLoaded:(void (^)(NSError *error))block;
@end
