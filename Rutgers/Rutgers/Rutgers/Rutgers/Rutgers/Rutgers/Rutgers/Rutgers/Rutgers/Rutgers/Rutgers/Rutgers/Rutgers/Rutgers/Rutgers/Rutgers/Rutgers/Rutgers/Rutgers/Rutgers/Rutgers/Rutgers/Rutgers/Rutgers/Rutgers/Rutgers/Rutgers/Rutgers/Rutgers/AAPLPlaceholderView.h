/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Various placeholder views.
  
 */

#import <UIKit/UIKit.h>
#import "ALTableViewAbstractCell.h"

/// A placeholder view that approximates the standard iOS no content view.
@interface AAPLPlaceholderView : UIView

@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
@property (nonatomic) NSString *buttonTitle;
@property (nonatomic, copy) void (^buttonAction)(void);

/// Initialize a placeholder view. A message is required in order to display a button.
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)buttonTitle buttonAction:(dispatch_block_t)buttonAction;
@end

@interface ALPlaceholderCell : ALTableViewAbstractCell

@property (nonatomic) AAPLPlaceholderView *placeholderView;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
@property (nonatomic) NSString *buttonTitle;
@property (nonatomic, copy) void (^buttonAction)(void);

@end

@interface ALActivityIndicatorCell : ALTableViewAbstractCell
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@end