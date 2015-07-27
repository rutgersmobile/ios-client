//
//  RUWebView.h
//  Rutgers
//
//  Created by Open Systems Solutions on 7/22/15.
//  Copyright (c) 2015 Rutgers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RUWebView <NSObject>
-(void)loadRequest:(NSURLRequest *)request;

@property (nullable, nonatomic, readonly, copy) NSString *title;
@property (nullable, nonatomic, readonly, copy) NSURL *URL;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly) double estimatedProgress;

- (void)goBack;
- (void)goForward;
- (void)reload;
- (void)stopLoading;

@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
@end


@protocol RUWebViewDelegate <NSObject>

@end

@interface RUWebView : UIView <RUWebView>
@property (nonatomic, weak) id <RUWebViewDelegate> delegate;
@end

