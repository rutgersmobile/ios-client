//
//  RUMOTDManager.h
//  Rutgers
//
//  Created by Open Systems Solutions on 7/8/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUMOTDManager : NSObject
+(instancetype)sharedManager;
-(void)showMOTD;
@property (nonatomic) NSString *serverInfoString;
@end
