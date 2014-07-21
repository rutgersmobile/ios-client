//
//  NetworkContentLoadingStateMachine.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NetworkContentStateIndicatorView;

NSString *stringFromNetworkContentState;

@protocol NetworkContentLoadingStateMachineDelegate <NSObject>
-(void)loadNetworkData;
@end

@interface NetworkContentLoadingStateMachine : NSObject
@property (nonatomic) BOOL contentLoaded;

-(instancetype)initWithStateIndicatorView:(NetworkContentStateIndicatorView *)stateIndicatorView;

-(void)startNetworking;

@property (nonatomic, weak) id<NetworkContentLoadingStateMachineDelegate> delegate;

-(void)networkLoadSuccessful;
-(void)networkLoadFailedWithNoData;
-(void)networkLoadFailedWithParsingError;

@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NetworkContentStateIndicatorView *overlayStateIndicatorView;

@end
