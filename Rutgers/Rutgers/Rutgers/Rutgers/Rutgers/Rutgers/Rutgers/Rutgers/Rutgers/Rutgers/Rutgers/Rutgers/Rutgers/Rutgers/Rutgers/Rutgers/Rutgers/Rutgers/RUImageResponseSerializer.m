//
//  RUImageResponseSerializer.m
//  Rutgers
//
//  Created by Kyle Bailey on 8/20/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUImageResponseSerializer.h"
#import "AFURLResponseSerialization.h"

@implementation UIImage (Cropping)
-(UIImage *)imageInRect:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

@end

@implementation RUImageResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error{
    UIImage *responseObject = [super responseObjectForResponse:response data:data error:error];
   
    CGSize size = responseObject.size;
    CGFloat aspectRatio = size.width/size.height;
   
    if (aspectRatio >= 1.0f) return responseObject;
    
    CGFloat adjustRatio = 0;
    
    CGFloat y = size.height-size.width + adjustRatio * size.height;
    
    CGRect rect = CGRectMake(0, y, size.width, size.width);
    
    UIImage *croppedImage = [responseObject imageInRect:rect];
    
    return croppedImage;
}
@end
