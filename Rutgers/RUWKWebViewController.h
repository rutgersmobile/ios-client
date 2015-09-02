//
//  RUWKWebViewController.h
//  Rutgers
//
//  Created by Open Systems Solutions on 8/3/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "RUChannelProtocol.h"

@interface RUWKWebViewController : UIViewController <RUChannelProtocol>

- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithURLString:(NSString *)urlString;

@property (nonatomic,strong)    NSURL *url;

@property (nonatomic,strong)    NSMutableURLRequest *urlRequest;

@property (nonatomic,readonly)  WKWebView *webView;

@property (nonatomic,assign)    BOOL showLoadingBar;

@property (nonatomic,assign)    BOOL showUrlWhileLoading;

@property (nonatomic,copy)      UIColor *loadingBarTintColor;


@property (nonatomic,assign)    BOOL navigationButtonsHidden;

@property (nonatomic,assign)    BOOL showActionButton;

@property (nonatomic,assign)    BOOL showDoneButton;

@property (nonatomic,assign)    BOOL showPageTitles;


@property (nonatomic,assign)    BOOL disableContextualPopupMenu;

@property (nonatomic,assign)    BOOL hideWebViewBoundaries;

@property (nonatomic,strong)    UIColor *buttonTintColor;

@end
