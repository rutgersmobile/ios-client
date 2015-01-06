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
/*
/// A placeholder view for use in the collection view. This placeholder includes the loading indicator.
@interface AAPLCollectionPlaceholderView : UICollectionReusableView

@end

*/
@interface AAPLPlaceholderCell : ALTableViewAbstractCell
@property (nonatomic) AAPLPlaceholderView *placeholderView;
- (void)showActivityIndicator:(BOOL)show;
- (void)showPlaceholderWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image;
- (void)hidePlaceholder;
@end
