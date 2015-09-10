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

//We need to load if we arent in the middle of loading, and arent finished loading without any errors
-(BOOL)needsLoad{
    return !(self.loading || self.finishedLoading);
}

-(void)performWhenLoaded:(void (^)(NSError *error))block{
    @synchronized(self) {
        //If we need to load, trigger the load
        if ([self needsLoad]) [self load];
        //Call the block when the loading is complete
        dispatch_group_notify(self.loadingGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            block(self.loadingError);
        });
    }
}

//Subclasses will call this to start loading, and cause blocks submitted by performWhenLoaded: to wait for completion
-(void)willBeginLoad{
    @synchronized(self) {
        dispatch_group_enter(self.loadingGroup);
        
        self.loading = YES;
        self.finishedLoading = NO;
        self.loadingError = nil;
    }
}

//When loading is done, call this and this will cause everything submitted to performWhenLoaded: to happen
//The loaded parameter concerns whether or not the loading completed successfully
//If loading isnt successful, the next performWhenLoaded: will try to load again
-(void)didEndLoad:(BOOL)loaded withError:(NSError *)error{
    @synchronized(self) {
        self.loading = NO;
        self.finishedLoading = loaded;
        self.loadingError = error;
        
        dispatch_group_leave(self.loadingGroup);
    }
}

//For subclasses
-(void)load{
    
}

@end
