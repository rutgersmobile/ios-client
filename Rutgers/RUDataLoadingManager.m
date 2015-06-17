//
//  RUDataLoadingManager.m
//  Rutgers
//
//  Created by Open Systems Solutions on 6/17/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import "RUDataLoadingManager.h"
#import "RUDataLoadingManager_Private.h"

@interface RUDataLoadingManager ()
@property BOOL loading;
@property BOOL finishedLoading;
@property NSError *loadingError;

@property dispatch_group_t loadingGroup;
@end

@implementation RUDataLoadingManager
-(instancetype)init{
    self = [super init];
    if (self) {
        self.loadingGroup = dispatch_group_create();
    }
    return self;
}

-(BOOL)needsLoad{
    return !(self.loading || self.finishedLoading);
}

-(void)performWhenLoaded:(void (^)(NSError *error))block{
    @synchronized(self) {
        if ([self needsLoad]) [self load];
        dispatch_group_notify(self.loadingGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            block(self.loadingError);
        });
    }
}


-(void)willBeginLoad{
    @synchronized(self) {
        dispatch_group_enter(self.loadingGroup);
        
        self.loading = YES;
        self.finishedLoading = NO;
        self.loadingError = nil;
    }
}

-(void)didEndLoad:(BOOL)loaded withError:(NSError *)error{
    @synchronized(self) {
        self.loading = NO;
        self.finishedLoading = loaded;
        self.loadingError = error;
        
        dispatch_group_leave(self.loadingGroup);
    }
}


-(void)load{
    
}

@end
