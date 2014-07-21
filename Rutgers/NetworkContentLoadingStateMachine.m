//
//  NetworkContentLoadingStateMachine.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NetworkContentLoadingStateMachine.h"
#import "NetworkContentStateIndicatorView.h"


@interface NetworkContentLoadingStateMachine ()
@property (nonatomic) BOOL reachable;
@property (nonatomic) BOOL retryLoad;

@end

@implementation NetworkContentLoadingStateMachine
- (instancetype)initWithStateIndicatorView:(NetworkContentStateIndicatorView *)stateIndicatorView
{
    self = [super init];
    if (self) {
        self.overlayStateIndicatorView = stateIndicatorView;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusDidChange) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        self.reachable = [AFNetworkReachabilityManager sharedManager].reachable;
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reachabilityStatusDidChange{
    ASSERT_MAIN_THREAD;
    BOOL reachable = [AFNetworkReachabilityManager sharedManager].reachable;
    if (self.reachable == reachable) return;
    self.reachable = reachable;
    
    if (self.retryLoad && reachable) {
        [self startNetworking];
    } else if (reachable) {
        [self networkConnected];
    } else {
        [self networkDisconnected];
    }
}

-(void)setRefreshControl:(UIRefreshControl *)refreshControl{
    _refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(startNetworking) forControlEvents:UIControlEventValueChanged];
}

-(void)startNetworking{
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        [self networkLoadStarted];
        [self.delegate loadNetworkData];
    } else {
        [self networkLoadFailedWithNoNetworkConnection];
    }
}

-(void)networkLoadStarted{
    [self updateOverlayState:NetworkContentOverlayStateLoading];
    if (!self.refreshControl.refreshing) [self.refreshControl beginRefreshing];
}

-(void)networkLoadSuccessful{
    [self networkingEnded];
    self.contentLoaded = YES;
    [self updateOverlayState:NetworkContentOverlayStateHidden];
}

-(void)networkLoadFailedWithNoData{
    if (!self.reachable) {
        self.retryLoad = YES;
        [self networkLoadFailedWithNoNetworkConnection];
    } else {
        [self networkingEnded];
        [self updateOverlayState:NetworkContentOverlayStateNoData];
    }

}

-(void)networkLoadFailedWithParsingError{
    [self networkingEnded];
    [self updateOverlayState:NetworkContentOverlayStateParsingError];
}

-(void)networkLoadFailedWithNoNetworkConnection{
    [self networkingEnded];
    [self updateOverlayState:NetworkContentOverlayStateNoNetworkConnection];
    self.retryLoad = YES;
}

-(void)networkingEnded{
    [self.refreshControl endRefreshing];
}

-(void)networkConnected{
    [self updateOverlayState:NetworkContentOverlayStateNetworkConnected];
}

-(void)networkDisconnected{
    [self updateOverlayState:NetworkContentOverlayStateNoNetworkConnection];
}

-(void)updateOverlayState:(NetworkContentOverlayState)overlayState{
    [self.overlayStateIndicatorView setOverlayState:overlayState autoHiding:self.contentLoaded];
}
@end
