//
//  NetworkContentStateIndicatorView.h
//  Rutgers
//
//  Created by Kyle Bailey on 7/16/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    NetworkContentOverlayStateHidden = 0,
    NetworkContentOverlayStateLoading,
    NetworkContentOverlayStateNoData,
    NetworkContentOverlayStateParsingError,
    NetworkContentOverlayStateNetworkConnected,
    NetworkContentOverlayStateNoNetworkConnection
} NetworkContentOverlayState;

@interface NetworkContentStateIndicatorView : UIView
@property (nonatomic) NetworkContentOverlayState overlayState;
-(void)setOverlayState:(NetworkContentOverlayState)overlayState autoHiding:(BOOL)autoHiding;
@end
