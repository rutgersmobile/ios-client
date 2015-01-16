/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  Various placeholder views.
  
 */

#import "AAPLPlaceholderView.h"
#import "RULabel.h"

#define CORNER_RADIUS 3.0
#define VERTICAL_ELEMENT_SPACING 35.0
#define CONTINUOUS_CURVES_SIZE_FACTOR (1.528665)
#define BUTTON_WIDTH 124
#define BUTTON_HEIGHT 29

@interface AAPLPlaceholderView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) NSArray *constraints;
@end

@implementation AAPLPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"-[AAPLPlaceholderView initWithFrame:] will not return a usable view");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)buttonTitle buttonAction:(dispatch_block_t)buttonAction
{
    self = [super initWithFrame:frame];
    if (!self)
        return self;

    _title = [title copy];
    _message = [message copy];
    _image = image;
    if (buttonTitle && buttonAction) {
        NSAssert(message != nil, @"a message must be provided when using a button");
        _buttonTitle = [buttonTitle copy];
        _buttonAction = [buttonAction copy];
    }

    _containerView = [[UIView alloc] initForAutoLayout];

    UIColor *textColor = [UIColor colorWithWhite:172/255.0 alpha:1];

    _imageView = [[UIImageView alloc] initWithImage:_image];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_imageView];

    _titleLabel = [[RULabel alloc] initForAutoLayout];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = nil;
    _titleLabel.opaque = NO;
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = textColor;
    [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    _messageLabel = [[RULabel alloc] initForAutoLayout];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.opaque = NO;
    _messageLabel.backgroundColor = nil;

    _messageLabel.numberOfLines = 0;
    _messageLabel.textColor = textColor;
    [_messageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [_messageLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    _actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_actionButton addTarget:self action:@selector(_actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_actionButton setFrame:CGRectMake(0, 0, 124, 29)];
    _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    _actionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [_actionButton setBackgroundImage:[self _buttonBackgroundImageWithColor:textColor] forState:UIControlStateNormal];
    [_actionButton setTitleColor:textColor forState:UIControlStateNormal];

    [self addSubview:_containerView];

    [self updateFonts];
    [self _updateViewHierarchy];

    // Constrain the container to the host view. The height of the container will be determined by the contents.
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets];
    [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
    [self.containerView autoCenterInSuperview];
    
    if (iPad()) {
        // _containerView should be no more than 418pt and the left and right padding should be no less than 30pt on both sides
        [self.containerView autoSetDimension:ALDimensionWidth toSize:418 relation:NSLayoutRelationLessThanOrEqual];
        [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:30 relation:NSLayoutRelationGreaterThanOrEqual];
        [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30 relation:NSLayoutRelationGreaterThanOrEqual];
    } else {
        [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:30];
        [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30];
    }
    
    return self;
}

- (UIImage *)_buttonBackgroundImageWithColor:(UIColor *)color
{
    static UIImage *backgroundImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        CGFloat cornerRadius = CORNER_RADIUS;

        CGFloat capSize = ceilf(cornerRadius * CONTINUOUS_CURVES_SIZE_FACTOR);
        CGFloat rectSize = 2.0 * capSize + 1.0;
        CGRect rect = CGRectMake(0.0, 0.0, rectSize, rectSize);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);

        // pull in the stroke a wee bit
        CGRect pathRect = CGRectInset(rect, 0.5, 0.5);
        cornerRadius -= 0.5;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:cornerRadius];

        [color set];
        [path stroke];

        backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(capSize, capSize, capSize, capSize)];
    });

    return backgroundImage;
}

- (void)_updateViewHierarchy
{
    if (_image) {
        [_containerView addSubview:_imageView];
        _imageView.image = _image;
    }
    else
        [_imageView removeFromSuperview];

    if (_title) {
        [_containerView addSubview:_titleLabel];
        _titleLabel.text = _title;
    }
    else
        [_titleLabel removeFromSuperview];

    if (_message) {
        [_containerView addSubview:_messageLabel];
        _messageLabel.text = _message;
    }
    else
        [_messageLabel removeFromSuperview];

    if (_buttonTitle) {
        [_containerView addSubview:_actionButton];
        [_actionButton setTitle:_buttonTitle forState:UIControlStateNormal];
    }
    else {
        [_actionButton removeFromSuperview];
    }

    if (_constraints)
        [_containerView removeConstraints:_constraints];
    _constraints = nil;
    [self setNeedsUpdateConstraints];
}

-(void)updateFonts{
    self.titleLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontByScalingPointSize:1.3];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.actionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

- (void)setImage:(UIImage *)image
{
    if ([image isEqual:_image])
        return;

    _image = image;
    [self _updateViewHierarchy];
}

- (void)setTitle:(NSString *)title
{
    NSAssert(title && [title length], @"Title cannot be nil or empty");

    if ([title isEqualToString:_title])
        return;

    _title = [title copy];

    [self _updateViewHierarchy];
}

- (void)setMessage:(NSString *)message
{
    if ([message isEqualToString:_message])
        return;

    _message = [message copy];

    [self _updateViewHierarchy];
}

- (void)setButtonTitle:(NSString *)buttonTitle
{
    if ([buttonTitle isEqualToString:_buttonTitle])
        return;

    _buttonTitle = [buttonTitle copy];

    [self _updateViewHierarchy];
}

- (void)_actionButtonPressed:(id)sender
{
    if (self.buttonAction)
        self.buttonAction();
}

- (void)updateConstraints
{
    if (_constraints) {
        [super updateConstraints];
        return;
    }

    NSMutableArray *constraints = [NSMutableArray array];

    NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _titleLabel, _messageLabel, _actionButton);
    UIView *last = _containerView;
    NSLayoutAttribute lastAttr = NSLayoutAttributeTop;
    CGFloat constant = 0;

    if (_imageView.superview) {
        // Force the container to be at least as wide as the image
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_imageView]-(>=0)-|" options:0 metrics:nil views:views]];
        // horizontally center the image
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        // aligned with the top of the container
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];

        last = _imageView;
        lastAttr = NSLayoutAttributeBottom;
        constant = 15; // spec calls for 20pt space, but when set to 20pt, there's 25pts of space between the bottom of the image and the top of the text.
    }

    if (_titleLabel.superview) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]|" options:0 metrics:nil views:views]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:last attribute:lastAttr multiplier:1.0 constant:constant]];

        last = _titleLabel;
        lastAttr = NSLayoutAttributeBaseline;
        constant = 15; // spec calls for 20pt space, but when set to 20pt, there's 25pts of space between the baseline of the title and the message.
    }

    if (_messageLabel.superview) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_messageLabel]|" options:0 metrics:nil views:views]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_messageLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:last attribute:lastAttr multiplier:1.0 constant:constant]];

        last = _messageLabel;
        lastAttr = NSLayoutAttributeBaseline;
        constant = 20;
    }

    if (_actionButton.superview) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_actionButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:last attribute:lastAttr multiplier:1.0 constant:constant]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_actionButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_actionButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BUTTON_WIDTH]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_actionButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:BUTTON_HEIGHT]];

        last = _actionButton;
    }

    // link the bottom of the last view with the bottom of the container to provide the size of the container
    [constraints addObject:[NSLayoutConstraint constraintWithItem:last attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];

    [_containerView addConstraints:constraints];
    _constraints = constraints;

    [super updateConstraints];
}

@end

@interface ALPlaceholderCell ()
@end

@implementation ALPlaceholderCell

-(void)initializeSubviews{
    self.placeholderView = [[AAPLPlaceholderView alloc] initWithFrame:self.contentView.bounds title:nil message:nil image:nil buttonTitle:nil buttonAction:nil];
    self.placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:self.placeholderView];
}

-(void)initializeConstraints{
    [self.placeholderView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

-(void)updateFonts{
    [self.placeholderView updateFonts];
}

-(NSString *)title{
    return self.placeholderView.title;
}

-(void)setTitle:(NSString *)title{
    self.placeholderView.title = title;
}

-(NSString *)message{
    return self.placeholderView.message;
}

-(void)setMessage:(NSString *)message{
    self.placeholderView.message = message;
}

-(UIImage *)image{
    return self.placeholderView.image;
}

-(void)setImage:(UIImage *)image{
    self.placeholderView.image = image;
}

-(NSString *)buttonTitle{
    return self.placeholderView.buttonTitle;
}

-(void)setButtonTitle:(NSString *)buttonTitle{
    self.placeholderView.buttonTitle = buttonTitle;
}

-(void (^)(void))buttonAction{
    return self.placeholderView.buttonAction;
}

-(void)setButtonAction:(void (^)(void))buttonAction{
    self.placeholderView.buttonAction = buttonAction;
}

@end

@interface ALActivityIndicatorCell ()
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation ALActivityIndicatorCell

-(void)initializeSubviews{
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicatorView.color = [UIColor lightGrayColor];

    [self.contentView addSubview:self.activityIndicatorView];
}

-(void)initializeConstraints{
    [self.activityIndicatorView autoCenterInSuperview];
    [self.activityIndicatorView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
    [self.activityIndicatorView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
}

@end
