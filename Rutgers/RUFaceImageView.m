//
//  RUFaceImageView.m
//  Rutgers
//
//  Created by Kyle Bailey on 7/23/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUFaceImageView.h"

@interface RUFaceImageView ()
@property (nonatomic) UIImageView *realImageView;

@property (nonatomic) NSLayoutConstraint *verticalConstraint;
@property (nonatomic) NSLayoutConstraint *horizontalConstraint;
@end

@implementation RUFaceImageView

-(CGRect)frameOfFaceInImage:(UIImage *)image{
    
    static CIDetector *detector = nil;
    static NSMapTable *cache = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
        cache = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    });
    
    NSValue *cachedRect = [cache objectForKey:image];
    if (cachedRect) {
        return [cachedRect CGRectValue];
    }

    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];
   
    CGRect boundingRect;
    if (features.count) {
        CIFaceFeature *faceFeature = [features firstObject];
        CGRect bounds = faceFeature.bounds;
        boundingRect = CGRectMake(bounds.origin.x/2.0, bounds.origin.y/2.0, bounds.size.width/2.0, bounds.size.height/2.0);
    } else {
        boundingRect = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    [cache setObject:[NSValue valueWithCGRect:boundingRect] forKey:image];
    return boundingRect;
}

#define MULTIPLIER 1.8
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.realImageView = [UIImageView newAutoLayoutView];
        [self addSubview:self.realImageView];
    
        self.verticalConstraint = [self.realImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        self.horizontalConstraint = [self.realImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
     
        [self.realImageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self withMultiplier:MULTIPLIER];
        [self.realImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:MULTIPLIER];
      
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)setImage:(UIImage *)image{
    
    self.realImageView.image = image;
    
    if (!image) return;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

-(void)updateConstraints{

    UIImage *image = self.realImageView.image;
    if (image) {
        CGRect bounds = self.bounds;
        CGFloat scaleFactor = MAX(CGRectGetWidth(bounds)/image.size.width, CGRectGetHeight(bounds)/image.size.height);
        
        CGRect frame = [self frameOfFaceInImage:image];
        
        CGFloat xOffset = CGRectGetMidX(frame)*scaleFactor-CGRectGetMidX(bounds);
        CGFloat yOffset = CGRectGetMidY(frame)*scaleFactor-CGRectGetMidY(bounds);
        
        self.horizontalConstraint.constant = xOffset/MULTIPLIER;
        self.verticalConstraint.constant = yOffset/MULTIPLIER;
    }
    
    [super updateConstraints];
}


-(UIImage *)image{
   // return [super image];
    return self.realImageView.image;
}

-(void)setContentMode:(UIViewContentMode)contentMode{
    self.realImageView.contentMode = contentMode;
}

-(UIViewContentMode)contentMode{
    return self.realImageView.contentMode;
}
@end
