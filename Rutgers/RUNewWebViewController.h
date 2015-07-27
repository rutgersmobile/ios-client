//
//  RUNewWebViewController.h
//  Rutgers
//
//  Created by Open Systems Solutions on 7/8/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RUNewWebViewController : UIViewController <RUChannelProtocol>
@property (nonatomic,assign) BOOL showActionButton;

@property (nonatomic) NSDictionary *buttonThemeAttributes;

@property (nonatomic,assign) BOOL navigationButtonsHidden;

@property (nonatomic,assign) BOOL hideWebViewBoundaries;
@end
