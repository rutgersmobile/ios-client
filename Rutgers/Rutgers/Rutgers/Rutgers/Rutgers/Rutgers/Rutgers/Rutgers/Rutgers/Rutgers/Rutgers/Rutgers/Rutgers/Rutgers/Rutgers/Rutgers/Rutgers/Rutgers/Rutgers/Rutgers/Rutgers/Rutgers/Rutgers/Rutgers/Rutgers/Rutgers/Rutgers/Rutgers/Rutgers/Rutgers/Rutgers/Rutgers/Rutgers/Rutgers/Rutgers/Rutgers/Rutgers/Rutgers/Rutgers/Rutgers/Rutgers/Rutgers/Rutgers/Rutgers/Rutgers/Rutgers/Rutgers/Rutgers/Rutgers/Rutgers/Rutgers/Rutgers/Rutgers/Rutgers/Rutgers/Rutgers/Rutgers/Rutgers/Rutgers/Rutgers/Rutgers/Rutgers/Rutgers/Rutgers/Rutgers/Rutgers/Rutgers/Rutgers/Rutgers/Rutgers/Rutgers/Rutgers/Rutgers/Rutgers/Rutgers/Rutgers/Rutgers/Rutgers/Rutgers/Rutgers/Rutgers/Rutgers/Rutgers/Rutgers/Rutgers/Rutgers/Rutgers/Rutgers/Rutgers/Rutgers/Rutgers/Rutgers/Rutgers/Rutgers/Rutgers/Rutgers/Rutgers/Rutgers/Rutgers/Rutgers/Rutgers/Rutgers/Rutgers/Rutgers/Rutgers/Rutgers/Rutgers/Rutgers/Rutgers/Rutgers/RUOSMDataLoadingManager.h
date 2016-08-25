//
//  RUOSMDataLoadingManager.h
//  Rutgers
//
//  Created by Open Systems Solutions on 7/31/15.
//  Copyright © 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUOSMDataLoadingManager : NSObject
+(instancetype)sharedManager;
-(void)get;
@end
