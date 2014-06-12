//
//  RUMapsTileOverlay.m
//  Rutgers
//
//  Created by Kyle Bailey on 5/9/14.
//  Copyright (c) 2014 Rutgers. All rights reserved.
//

#import "RUMapsTileOverlay.h"
#import "RUMapsData.h"
#import "iPadCheck.h"

@interface RUMapsTileOverlay ()
@property BOOL retina;
@end

@implementation RUMapsTileOverlay
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.canReplaceMapContent = YES;
        /*
        if ([UIScreen mainScreen].scale == 2.0) {
            self.retina = YES;
            //self.tileSize = CGSizeMake(512, 512);
        } */
    }
    return self;
}
-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *data, NSError *error))result{
    [self.delegate loadTileAtPath:path result:result];
    /*
    [self.delegate loadTileAtPath:path result:^(NSData *data, NSError *error) {
        if (self.retina) {
            result([self doubleImageSizeOfImageData:data],error);
        } else {
            result(data,error);
        }
    }];*/
}

-(NSData *)doubleImageSizeOfImageData:(NSData *)imageData{
    UIImage *originalImage = [UIImage imageWithData:imageData];
    CGRect rect = CGRectMake(0,0,originalImage.size.width*2.0,originalImage.size.height*2.0);
    UIGraphicsBeginImageContext( rect.size );
    [originalImage drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

@end