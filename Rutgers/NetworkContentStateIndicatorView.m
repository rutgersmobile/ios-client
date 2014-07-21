//
//  NetworkContentStateIndicatorView.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "NetworkContentStateIndicatorView.h"
#import "NetworkContentStateNoDataView.h"
#import "NetworkContentStateLoadingView.h"
#import "NetworkContentStateNoNetworkConnectionView.h"
#import "NetworkContentStateNetworkConnectedView.h"

@interface NetworkContentStateIndicatorView ()
@property (nonatomic) UIView *overlayView;
@property (nonatomic) MSWeakTimer *hidingTimer;
@end

@implementation NetworkContentStateIndicatorView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        [self autoSetDimensionsToSize:CGSizeMake(200, 200)];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        self.layer.cornerRadius = 8.0;
        self.alpha = 0;
    }
    return self;
}

-(void)setOverlayState:(NetworkContentOverlayState)overlayState{
    _overlayState = overlayState;
    
    UIView *oldView = self.overlayView;
    UIView *newView = [self viewForOverlayState:overlayState];
    self.overlayView = newView;
    
    [self addSubview:newView];
    [newView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    newView.alpha = 0;
    
    dispatch_block_t animations = ^{
        oldView.alpha = 0;
        newView.alpha = 1;
        self.alpha = (overlayState == NetworkContentOverlayStateHidden) ? 0 : 1;
    };
    
    void(^completion)(BOOL finished) = ^(BOOL finished){
        [oldView removeFromSuperview];
    };
    
    [UIView animateWithDuration:0.5 delay:(overlayState == NetworkContentOverlayStateHidden) ? 0 : 0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
}

-(void)setOverlayState:(NetworkContentOverlayState)overlayState autoHiding:(BOOL)autoHiding{
    [self setOverlayState:overlayState];
    [self.hidingTimer invalidate];
    if (autoHiding) {
        self.hidingTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(hideTimerFired) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
    }
}

-(void)hideTimerFired{
    [self setOverlayState:NetworkContentOverlayStateHidden];
}


-(UIView *)viewForOverlayState:(NetworkContentOverlayState)overlayState{
    switch (overlayState) {
        case NetworkContentOverlayStateLoading:
            return [[NetworkContentStateLoadingView alloc] init];
            break;
        case NetworkContentOverlayStateNoData:
        case NetworkContentOverlayStateParsingError:
            return [[NetworkContentStateNoDataView alloc] init];
            break;
        case NetworkContentOverlayStateNetworkConnected:
            return [[NetworkContentStateNetworkConnectedView alloc] init];
            break;
        case NetworkContentOverlayStateNoNetworkConnection:
            return [[NetworkContentStateNoNetworkConnectionView alloc] init];
            break;
        default:
            return [[UIView alloc] init];
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
