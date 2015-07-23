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
@end

@protocol RUWebViewDelegate <NSObject>

@end

@interface RUWebView : UIView <RUWebView>
@property (nonatomic, weak) id <RUWebViewDelegate> delegate;
@end

